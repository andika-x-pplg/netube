import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/netube_content_model.dart';
import 'storage_upload.dart';

class NetubeContentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get currentUid => _auth.currentUser?.uid ?? '';

  static Future<void> upload({
    required XFile thumbnailFile,
    required String thumbnailExtension,
    required XFile videoFile,
    required String videoExtension,
    required String title,
    required String description,
    required String category,
    required String visibility,
    required Duration duration,
    void Function(double progress)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Pengguna belum login');
    final document = _firestore.collection('netubeContent').doc();
    final basePath = 'netube_content/${user.uid}/${document.id}';
    final thumbnailReference = _storage.ref(
      '$basePath/thumbnail.$thumbnailExtension',
    );
    final videoReference = _storage.ref('$basePath/video.$videoExtension');

    try {
      final thumbnailSnapshot = await uploadXFile(
        thumbnailReference,
        thumbnailFile,
        'image/$thumbnailExtension',
      );
      final videoSnapshot = await uploadXFile(
        videoReference,
        videoFile,
        'video/$videoExtension',
        onProgress: onProgress,
      );
      final thumbnailUrl = await _getDownloadUrl(thumbnailSnapshot.ref);
      final videoUrl = await _getDownloadUrl(videoSnapshot.ref);
      final ownerName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : user.email?.split('@').first ?? 'Creator';
      await document.set({
        'ownerUid': user.uid,
        'ownerName': ownerName,
        'title': title.trim(),
        'description': description.trim(),
        'category': duration <= const Duration(minutes: 3)
            ? 'Shorts'
            : category,
        'visibility': visibility,
        'durationSeconds': duration.inSeconds,
        'isShort': duration <= const Duration(minutes: 3),
        'thumbnailUrl': thumbnailUrl,
        'videoUrl': videoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _deleteIfPresent(thumbnailReference);
      await _deleteIfPresent(videoReference);
      rethrow;
    }
  }

  static Future<void> _deleteIfPresent(Reference reference) async {
    try {
      await reference.delete();
    } catch (_) {
      // The object may not have been created before the upload failed.
    }
  }

  static Future<String> _getDownloadUrl(Reference reference) async {
    FirebaseException? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await reference.getDownloadURL();
      } on FirebaseException catch (error) {
        lastError = error;
        if (error.code != 'object-not-found' || attempt == 2) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
    throw lastError!;
  }

  static Stream<List<NetubeContent>> publicContent() => _firestore
      .collection('netubeContent')
      .where('visibility', isEqualTo: 'public')
      .snapshots()
      .map(_sortedContent);

  static Stream<List<NetubeContent>> publicShorts() => publicContent().map(
    (items) => items.where((item) => item.isShort).toList(),
  );

  static Stream<List<NetubeContent>> myContent() {
    final uid = currentUid;
    if (uid.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('netubeContent')
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map(_sortedContent);
  }

  static Future<List<NetubeContent>> searchPublic(String query) async {
    final snapshot = await _firestore
        .collection('netubeContent')
        .where('visibility', isEqualTo: 'public')
        .get();
    final needle = query.trim().toLowerCase();
    final results = _sortedContent(snapshot).where((content) {
      return content.title.toLowerCase().contains(needle) ||
          content.description.toLowerCase().contains(needle) ||
          content.category.toLowerCase().contains(needle) ||
          content.ownerName.toLowerCase().contains(needle);
    }).toList();
    return results;
  }

  static List<NetubeContent> _sortedContent(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final content = snapshot.docs.map(NetubeContent.fromDocument).toList();
    content.sort((a, b) {
      final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });
    return content;
  }
}

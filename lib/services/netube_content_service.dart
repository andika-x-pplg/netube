import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/netube_content_model.dart';

class NetubeContentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get currentUid => _auth.currentUser?.uid ?? '';

  static Future<void> upload({
    required Uint8List thumbnailBytes,
    required String thumbnailExtension,
    required Uint8List videoBytes,
    required String videoExtension,
    required String title,
    required String description,
    required String category,
    required String visibility,
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

    await thumbnailReference.putData(thumbnailBytes);
    final uploadTask = videoReference.putData(videoBytes);
    final subscription = uploadTask.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });
    try {
      await uploadTask;
    } finally {
      await subscription.cancel();
    }
    final thumbnailUrl = await thumbnailReference.getDownloadURL();
    final videoUrl = await videoReference.getDownloadURL();
    final ownerName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email?.split('@').first ?? 'Creator';
    await document.set({
      'ownerUid': user.uid,
      'ownerName': ownerName,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'visibility': visibility,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<NetubeContent>> publicContent() => _firestore
      .collection('netubeContent')
      .where('visibility', isEqualTo: 'public')
      .snapshots()
      .map(_sortedContent);

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

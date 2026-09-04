import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notification_service.dart';

class VideoCommentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User get _user {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Pengguna belum login');
    return user;
  }

  static CollectionReference<Map<String, dynamic>> _comments(String videoId) =>
      _firestore
          .collection('videoComments')
          .doc(videoId)
          .collection('comments');

  static String get currentUid => _auth.currentUser?.uid ?? '';

  static Stream<QuerySnapshot<Map<String, dynamic>>> comments(String videoId) =>
      _comments(videoId).snapshots();

  static Future<void> add({
    required String videoId,
    required String text,
    String? parentId,
  }) async {
    final user = _user;
    final value = text.trim();
    if (value.isEmpty) return;
    String? parentOwnerUid;
    if (parentId != null) {
      final parent = await _comments(videoId).doc(parentId).get();
      parentOwnerUid = parent.data()?['uid'] as String?;
    }
    final comment = await _comments(videoId).add({
      'uid': user.uid,
      'username': user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : user.email?.split('@').first ?? 'User',
      'text': value,
      'parentId': parentId,
      'likeCount': 0,
      'dislikeCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (parentOwnerUid != null) {
      await NotificationService.addVideoCommentReplyNotification(
        videoId: videoId,
        commentId: comment.id,
        commentOwnerUid: parentOwnerUid,
      );
    }
  }

  static bool canEdit(Map<String, dynamic> data) {
    if (data['uid'] != currentUid) return false;
    final createdAt = data['createdAt'];
    if (createdAt is! Timestamp) return true;
    return DateTime.now().difference(createdAt.toDate()) <
        const Duration(hours: 24);
  }

  static Future<void> edit({
    required String videoId,
    required String commentId,
    required String text,
  }) async {
    final ref = _comments(videoId).doc(commentId);
    final snapshot = await ref.get();
    final data = snapshot.data();
    if (data == null || !canEdit(data)) {
      throw StateError('Komentar tidak dapat diedit');
    }
    final value = text.trim();
    if (value.isEmpty) return;
    await ref.update({
      'text': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> delete({
    required String videoId,
    required String commentId,
  }) async {
    final ref = _comments(videoId).doc(commentId);
    final snapshot = await ref.get();
    if (snapshot.data()?['uid'] != currentUid) {
      throw StateError('Hanya pemilik yang dapat menghapus komentar');
    }
    await ref.delete();
  }

  static Future<void> toggleReaction({
    required String videoId,
    required String commentId,
    required String reaction,
  }) async {
    final user = _user;
    final commentRef = _comments(videoId).doc(commentId);
    final reactionRef = commentRef.collection('reactions').doc(user.uid);
    String? ownerToNotify;
    await _firestore.runTransaction((transaction) async {
      final comment = await transaction.get(commentRef);
      final previous = await transaction.get(reactionRef);
      if (!comment.exists) return;
      if (reaction == 'dislike' && comment.data()?['uid'] == user.uid) return;
      final commentOwnerUid = comment.data()?['uid'] as String?;
      final oldReaction = previous.data()?['reaction'] as String?;
      final updates = <String, dynamic>{};
      if (oldReaction != null) {
        updates['${oldReaction}Count'] = FieldValue.increment(-1);
      }
      if (oldReaction == reaction) {
        transaction.delete(reactionRef);
      } else {
        updates['${reaction}Count'] = FieldValue.increment(1);
        transaction.set(reactionRef, {
          'uid': user.uid,
          'reaction': reaction,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (reaction == 'like' && commentOwnerUid != user.uid) {
          ownerToNotify = commentOwnerUid;
        }
      }
      if (updates.isNotEmpty) transaction.update(commentRef, updates);
    });
    if (ownerToNotify != null) {
      await NotificationService.addVideoCommentLikeNotification(
        videoId: videoId,
        commentId: commentId,
        commentOwnerUid: ownerToNotify!,
      );
    }
  }

  static Stream<String?> myReaction(String videoId, String commentId) {
    final uid = currentUid;
    if (uid.isEmpty) return Stream.value(null);
    return _comments(videoId)
        .doc(commentId)
        .collection('reactions')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data()?['reaction'] as String?);
  }
}

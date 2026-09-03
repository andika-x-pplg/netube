import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NestedReplyLikeService {
  static final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth auth =
      FirebaseAuth.instance;

  // ==========================
  // LIKE NESTED REPLY
  // ==========================
  static Future<void> likeNestedReply({
    required int movieId,
    required String reviewOwnerUid,
    required String parentReplyId,
    required String nestedReplyId,
  }) async {
    final user = auth.currentUser;

    if (user == null) return;

    final uid = user.uid;
    final username =
        user.email?.split("@").first ?? "User";

    final likeRef = firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(parentReplyId)
        .collection("replies")
        .doc(nestedReplyId)
        .collection("likes")
        .doc(uid);

    final doc = await likeRef.get();

    // Sudah like → jangan buat lagi
    if (doc.exists) return;

    await likeRef.set({
      "uid": uid,
      "username": username,
      "likedAt": FieldValue.serverTimestamp(),
    });
  }

  // ==========================
  // UNLIKE NESTED REPLY
  // ==========================
  static Future<void> unlikeNestedReply({
    required int movieId,
    required String reviewOwnerUid,
    required String parentReplyId,
    required String nestedReplyId,
  }) async {
    final user = auth.currentUser;

    if (user == null) return;

    final likeRef = firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(parentReplyId)
        .collection("replies")
        .doc(nestedReplyId)
        .collection("likes")
        .doc(user.uid);

    final doc = await likeRef.get();

    if (!doc.exists) return;

    await likeRef.delete();
  }

  // ==========================
  // CEK USER SUDAH LIKE?
  // ==========================
  static Future<bool> isLiked({
    required int movieId,
    required String reviewOwnerUid,
    required String parentReplyId,
    required String nestedReplyId,
  }) async {
    final user = auth.currentUser;

    if (user == null) return false;

    final doc = await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(parentReplyId)
        .collection("replies")
        .doc(nestedReplyId)
        .collection("likes")
        .doc(user.uid)
        .get();

    return doc.exists;
  }

  // ==========================
  // JUMLAH LIKE REALTIME
  // ==========================
  static Stream<QuerySnapshot> getLikes({
    required int movieId,
    required String reviewOwnerUid,
    required String parentReplyId,
    required String nestedReplyId,
  }) {
    return firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(parentReplyId)
        .collection("replies")
        .doc(nestedReplyId)
        .collection("likes")
        .snapshots();
  }
}
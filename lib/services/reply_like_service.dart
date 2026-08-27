import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyLikeService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final FirebaseAuth auth = FirebaseAuth.instance;

  // ==========================
  // LIKE REPLY
  // ==========================
  static Future<void> likeReply({
    required int movieId,
    required String reviewOwnerUid,
    required String replyId,
  }) async {
    final user = auth.currentUser;

    if (user == null) return;

    final uid = user.uid;

    final username = user.email?.split("@").first ?? "User";

    final likeRef = firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(replyId)
        .collection("likes")
        .doc(uid);

    final doc = await likeRef.get();

    if (doc.exists) return;

    await likeRef.set({
      "uid": uid,
      "username": username,
      "likedAt": FieldValue.serverTimestamp(),
    });
  }
                                                                                         
  // ==========================
  // UNLIKE REPLY
  // ==========================
  static Future<void> unlikeReply({
    required int movieId,
    required String reviewOwnerUid,
    required String replyId,
  }) async {
    final user = auth.currentUser;

    if (user == null) return;

    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(replyId)
        .collection("likes")
        .doc(user.uid)
        .delete;
  }

  // ==========================
  // CEK SUDAH LIKE
  // ==========================
  static Future<bool> isLiked({
    required int movieId,
    required String reviewOwnerUid,
    required String replyId,
  }) async {
    final user = auth.currentUser;

    if (user == null) return false;

    final doc = await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(replyId)
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
    required String replyId,
  }) {
    return firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(replyId)
        .collection("likes")
        .snapshots();
  }
}

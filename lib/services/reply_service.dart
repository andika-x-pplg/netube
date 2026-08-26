import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  // ==========================
  // ADD REPLY
  // ==========================
  static Future<void> addReply({
    required int movieId,
    required String reviewOwnerUid,
    required String reply,
  }) async {
    final user = auth.currentUser!;

    final username = user.email?.split("@").first ?? "User";

    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .add({
          "uid": user.uid,
          "username": username,
          "reply": reply,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  // ==========================
  // GET REPLIES
  // ==========================
  static Stream<QuerySnapshot> getReplies({
    required int movieId,
    required String reviewOwnerUid,
  }) {
    return firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .orderBy("createdAt")
        .snapshots();
  }

  // ==========================
  // DELETE REPLY
  // ==========================
  static Future<void> deleteReply({
    required int movieId,
    required String reviewOwnerUid,
    required String replyId,
  }) async {
    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("replies")
        .doc(replyId)
        .delete();
  }
}

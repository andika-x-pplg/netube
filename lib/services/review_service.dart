import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  static final firestore = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;

  // ==========================
  // ADD / UPDATE REVIEW
  // ==========================

  static Future<void> addReview({
    required int movieId,
    required double rating,
    required String review,
  }) async {
    final uid = auth.currentUser!.uid;

    final username = auth.currentUser?.email?.split('@').first ?? "User";

    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(uid)
        .set({
          "uid": uid,
          "username": username,
          "rating": rating,
          "review": review,
          "likeCount": 0,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  // ==========================
  // DELETE REVIEW
  // ==========================

  static Future<void> deleteReview(int movieId) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(uid)
        .delete();
  }

  // ==========================
  // STREAM REVIEW
  // ==========================

  static Stream<QuerySnapshot> getReviews(int movieId) {
    return firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .orderBy("likeCount", descending: true)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  static Future<DocumentSnapshot?> getMyReview(int movieId) async {
    final uid = auth.currentUser!.uid;

    final result = await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    return result.docs.first;
  }

  static Future<void> updateReview({
    required int movieId,
    required double rating,
    required String review,
  }) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(uid)
        .update({
          "rating": rating,

          "review": review,

          "updatedAt": FieldValue.serverTimestamp(),
        });
  }
}

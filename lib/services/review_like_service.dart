import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class ReviewLikeService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  // ==========================
  // LIKE REVIEW
  // ==========================
  static Future<void> likeReview({
    required int movieId,
    required String reviewOwnerUid,
  }) async {
    final uid = auth.currentUser!.uid;

    final username = auth.currentUser?.email?.split("@").first ?? "User";

    final likeRef = firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("likes")
        .doc(uid);

    final doc = await likeRef.get();

    if (doc.exists) return;

    await likeRef.set({
      "uid": uid,
      "username": username,
      "likedAt": FieldValue.serverTimestamp(),
    });

    print("LIKE DOCUMENT CREATED");

    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .update({"likeCount": FieldValue.increment(1)});

    print("LIKE COUNT UPDATED");

    // ==========================
    // BUAT NOTIFIKASI
    // ==========================
    await NotificationService.addReviewLikeNotifications(
      movieId: movieId,
      reviewOwnerUid: reviewOwnerUid,
    );
  }

  // ==========================
  // UNLIKE REVIEW
  // ==========================
  static Future<void> unlikeReview({
    required int movieId,
    required String reviewOwnerUid,
  }) async {
    final uid = auth.currentUser!.uid;

    final likeRef = firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("likes")
        .doc(uid);

    final doc = await likeRef.get();

    if (!doc.exists) return;

    await likeRef.delete();

    await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .update({"likeCount": FieldValue.increment(-1)});
  }

  // ==========================
  // SUDAH LIKE?
  // ==========================
  static Future<bool> isLiked({
    required int movieId,
    required String reviewOwnerUid,
  }) async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("likes")
        .doc(uid)
        .get();

    return doc.exists;
  }

  // ==========================
  // JUMLAH LIKE (Realtime)
  // ==========================
  static Stream<QuerySnapshot> getLikes({
    required int movieId,
    required String reviewOwnerUid,
  }) {
    return firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("likes")
        .snapshots();
  }

  // ==========================
  // NAMA USER YANG LIKE
  // ==========================
  static Stream<QuerySnapshot> getLikerNames({
    required int movieId,
    required String reviewOwnerUid,
  }) {
    return firestore
        .collection("movieReviews")
        .doc(movieId.toString())
        .collection("users")
        .doc(reviewOwnerUid)
        .collection("likes")
        .orderBy("likedAt", descending: false)
        .snapshots();
  }
}

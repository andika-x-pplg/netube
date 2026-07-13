import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  static final firestore = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;

  // ==========================
  // SAVE RATING
  // ==========================

  static Future<void> rateMovie({
    required int movieId,
    required double rating,
  }) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("movieRatings")
        .doc(movieId.toString())
        .collection("users")
        .doc(uid)
        .set({
          "rating": rating,
          "uid": uid,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  // ==========================
  // GET USER RATING
  // ==========================

  static Future<double> getUserRating(int movieId) async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore
        .collection("movieRatings")
        .doc(movieId.toString())
        .collection("users")
        .doc(uid)
        .get();

    if (!doc.exists) return 0;

    return (doc["rating"] as num).toDouble();
  }

  // ==========================
  // GET COMMUNITY RATING
  // ==========================

  static Future<Map<String, dynamic>> getCommunityRating(int movieId) async {
    final snapshot = await firestore
        .collection("movieRatings")
        .doc(movieId.toString())
        .collection("users")
        .get();

    if (snapshot.docs.isEmpty) {
      return {"average": 0.0, "count": 0};
    }

    double total = 0;

    for (var doc in snapshot.docs) {
      total += (doc["rating"] as num).toDouble();
    }

    return {
      "average": total / snapshot.docs.length,
      "count": snapshot.docs.length,
    };
  }
}

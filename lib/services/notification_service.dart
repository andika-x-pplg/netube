import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final FirebaseAuth auth = FirebaseAuth.instance;

  // ==========================
  // ADD REVIEW LIKE NOTIFICATION
  // ==========================
  static Future<void> addReviewLikeNotifications({
    required int movieId,
    required String reviewOwnerUid,
  }) async {
    final user = auth.currentUser;

    if (user == null) return;

    final fromUid = user.uid;

    // Jangan buat notifikasi kalau like review sendiri
    if (fromUid == reviewOwnerUid) {
      return;
    }

    final fromUsername = user.email?.split("@").first ?? "User";

    await firestore
        .collection("notifications")
        .doc(reviewOwnerUid)
        .collection("items")
        .add({
          "type": "review_like",
          "fromUid": "fromUid",
          "fromUsername": "fromUsername",
          "movieId": "movieId",
          "message": "$fromUsername menyukai review kamu",
          "isRead": false,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  // ==========================
  // GET NOTIFICATIONS REALTIME
  // ==========================
  static Stream<QuerySnapshot> getNotifications() {
    final uid = auth.currentUser!.uid;

    return firestore
        .collection("notifications")
        .doc(uid)
        .collection("items")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // ==========================
  // MARK AS READ
  // ==========================
  static Future<void> markAsRead(String notificationId) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("notifications")
        .doc(uid)
        .collection("items")
        .doc(notificationId)
        .update({"isRead": true});
  }

  // ==========================
  // UNREAD NOTIFICATION COUNT
  // ==========================
  static Stream<int> getUnreadCount() {
    final uid = auth.currentUser!.uid;

    return firestore
    .collection("notifications")
    .doc(uid)
    .collection("items")
    .where("isRead", isEqualTo: false)
    .snapshots()
    .map((snapshot) => snapshot.docs.length);
  }
}

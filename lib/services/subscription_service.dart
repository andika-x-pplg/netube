import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {

  static final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth auth =
      FirebaseAuth.instance;

  static Future<void> subscribe({
    required String channelId,
    required String channelName,
  }) async {

    final uid =
        auth.currentUser!.uid;

    await firestore
        .collection('subscriptions')
        .doc(uid)
        .collection('channels')
        .doc(channelId)
        .set({

      'channelId': channelId,
      'channelName': channelName,
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  static Future<void> unsubscribe(
    String channelId,
  ) async {

    final uid =
        auth.currentUser!.uid;

    await firestore
        .collection('subscriptions')
        .doc(uid)
        .collection('channels')
        .doc(channelId)
        .delete();
  }

  static Future<bool> isSubscribed(
    String channelId,
  ) async {

    final uid =
        auth.currentUser!.uid;

    final doc = await firestore
        .collection('subscriptions')
        .doc(uid)
        .collection('channels')
        .doc(channelId)
        .get();

    return doc.exists;
  }
}
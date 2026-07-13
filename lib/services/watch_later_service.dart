import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchLaterService {
  static final firestore = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;

  // ===========================
  // MOVIE
  // ===========================

  static Future<void> addMovie(Map movie) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("watchlater")
        .doc(uid)
        .collection("movies")
        .doc(movie['id'].toString())
        .set({...movie, "savedAt": FieldValue.serverTimestamp()});
  }

  static Future<void> removeMovie(int id) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("watchlater")
        .doc(uid)
        .collection("movies")
        .doc(id.toString())
        .delete();
  }

  static Future<bool> isMovieSaved(int id) async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore
        .collection("watchlater")
        .doc(uid)
        .collection("movies")
        .doc(id.toString())
        .get();

    return doc.exists;
  }

  // ===========================
  // YOUTUBE
  // ===========================

  static Future<void> addVideo({
  required String videoId,
  required String title,
  required String thumbnail,
  required String channelId,
  required String channelTitle,
}) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("watchlater")
        .doc(uid)
        .collection("videos")
        .doc(videoId)
        .set({
          "videoId": videoId,
          "title": title,
          "thumbnail": thumbnail,
          "channelId": channelId,
          "channelTitle": channelTitle,
          "savedAt": FieldValue.serverTimestamp(),
        });
  }

  static Future<void> removeVideo(String videoId) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection("watchlater")
        .doc(uid)
        .collection("videos")
        .doc(videoId)
        .delete();
  }

  static Future<bool> isVideoSaved(String videoId) async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore
        .collection("watchlater")
        .doc(uid)
        .collection("videos")
        .doc(videoId)
        .get();

    return doc.exists;
  }
}

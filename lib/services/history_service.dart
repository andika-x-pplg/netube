import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final FirebaseAuth auth = FirebaseAuth.instance;

  // ==========================
  // MOVIE HISTORY
  // ==========================
  static Future<void> addMovieHistory({required Map movie}) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('history')
        .doc(uid)
        .collection('movies')
        .doc(movie['id'].toString())
        .set({...movie, 'watchedAt': FieldValue.serverTimestamp()});
  }

  // ==========================
  // VIDEO HISTORY
  // ==========================
  static Future<void> addVideoHistory({
    required String videoId,
    required String title,
    required String thumbnail,
    required String channelId,
    required String channelTitle,
  }) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('history')
        .doc(uid)
        .collection('videos')
        .doc(videoId)
        .set({
          'videoId': videoId,
          'title': title,
          'thumbnail': thumbnail,
          'channelId': channelId,
          'channelTitle': channelTitle,
          'watchedAt': FieldValue.serverTimestamp(),
        });
  }

  // ==========================
  // SAVE MOVIE PROGRESS
  // ==========================
  static Future<void> saveMovieProgress({
    required String movieId,
    required int seconds,
  }) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('history')
        .doc(uid)
        .collection('progress')
        .doc(movieId)
        .set({'seconds': seconds}, SetOptions(merge: true));
  }

  // ==========================
  // GET MOVIE PROGRESS
  // ==========================
  static Future<int> getMovieProgress(String movieId) async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore
        .collection('history')
        .doc(uid)
        .collection('progress')
        .doc(movieId)
        .get();

    if (!doc.exists) return 0;

    return (doc.data()?['seconds'] ?? 0) as int;
  }

  // ==========================
  // SAVE VIDEO PROGRESS
  // ==========================
  static Future<void> saveVideoProgress({
    required String videoId,
    required int seconds,
  }) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('history')
        .doc(uid)
        .collection('video_progress')
        .doc(videoId)
        .set({'seconds': seconds}, SetOptions(merge: true));
  }

  // ==========================
  // GET VIDEO PROGRESS
  // ==========================
  static Future<int> getVideoProgress(String videoId) async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore
        .collection('history')
        .doc(uid)
        .collection('video_progress')
        .doc(videoId)
        .get();

    if (!doc.exists) return 0;

    return (doc.data()?['seconds'] ?? 0) as int;
  }
}

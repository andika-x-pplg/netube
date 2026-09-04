import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoReactionService {
  // Menghubungkan service dengan firebase auth
  static final FirebaseAuth auth = FirebaseAuth.instance;

  // Menghubungkan service dengan cloud firestore
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ==========================
  // MENGAMBIL STATUS REAKSI
  // ==========================
  static Future<String?> getReaction(String videoId) async {
    final user = auth.currentUser;

    // Jika pengguna belum login
    if (user == null) {
      return null;
    }

    final document = await firestore
        .collection('video_reactions')
        .doc(user.uid)
        .collection('videos')
        .doc(videoId)
        .get();

    // Kalau video belum pernah diberi reaksi
    if (!document.exists) {
      return null;
    }

    return document.data()?['reaction'] as String?;
  }

  // ==========================
  // MEMBERIKAN LIKE / DISLIKE
  // ==========================
  static Future<String?> toggleReaction({
    required String videoId,
    required String title,
    required String thumbnail,
    required String channelId,
    required String channelTitle,
    required String reaction,
  }) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login');
    }

    final documentReference = firestore
        .collection('videoReactions')
        .doc(user.uid)
        .collection('videos')
        .doc(videoId);

    final document = await documentReference.get();

    final currentReaction = document.data()?['reaction'] as String?;

    // Kalau tombol yang sama ditekan lagi ,
    // reaksi akan dibatalkan
    if (currentReaction == reaction) {
      await documentReference.delete();

      return null;
    }

    // Menyimpan atau mengganti reaksi video
    await documentReference.set({
      'videoId': videoId,
      'title': title,
      'thumbnail': thumbnail,
      'channelId': channelId,
      'channelTitle': channelTitle,
      'reaction': reaction,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reaction;
  }

  // ==========================
  // MENGAMBIL DAFTAR VIDEO
  // ==========================
  static Stream<List<Map<String, dynamic>>> getReactionVideos(String reaction) {
    final user = auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('videoReactions')
        .doc(user.uid)
        .collection('videos')
        .where('reaction', isEqualTo: reaction)
        .snapshots()
        .map((snapshot) {
          final videos = snapshot.docs
              .map((document) => document.data())
              .toList();

          // Mengurutkan video terbaru di bagian atas
          videos.sort((videoA, videoB) {
            final timeA = videoA['updatedAt'] as Timestamp?;
            final timeB = videoB['updatedAt'] as Timestamp?;

            final millisecondsA = timeA?.millisecondsSinceEpoch ?? 0;

            final millisecondsB = timeB?.millisecondsSinceEpoch ?? 0;

            return millisecondsB.compareTo(millisecondsA);
          });

          return videos;
        });
  }
}

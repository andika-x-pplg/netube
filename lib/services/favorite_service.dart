import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<void> addFavorite(Map movie) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('favorites')
        .doc(uid)
        .collection('movies')
        .doc(movie['id'].toString())
        .set({
          'id': movie['id'],
          'title': movie['title'],
          'poster_path': movie['poster_path'],
          'overview': movie['overview'],
          'vote_average': movie['vote_average'],
          'release_date': movie['release_date'],
        });
  }

  static Future<void> removeFavorite(int movieId) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('favorites')
        .doc(uid)
        .collection('movies')
        .doc(movieId.toString())
        .delete();
  }

  static Future<bool> isFavorite(int movieId) async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore
        .collection('favorites')
        .doc(uid)
        .collection('movies')
        .doc(movieId.toString())
        .get();

    return doc.exists;
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final uid = auth.currentUser!.uid;

    final snapshot = await firestore
        .collection('favorites')
        .doc(uid)
        .collection('movies')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}

import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import 'movie_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final data = await FavoriteService.getFavorites();

    setState(() {
      favorites = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "Favorite Movies",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorite movies yet",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,

              itemBuilder: (context, index) {
                final movie = favorites[index];

                final imageUrl =
                    "https://image.tmdb.org/t/p/w500${movie['poster_path']}";

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),

                    child: Image.network(
                      imageUrl,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),

                  title: Text(
                    movie['title'] ?? "",
                    style: const TextStyle(color: Colors.white),
                  ),

                  subtitle: Text(
                    movie['release_date'] ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(movie: movie),
                      ),
                    ).then((_) {
                      loadFavorites();
                    });
                  },
                );
              },
            ),
    );
  }
}

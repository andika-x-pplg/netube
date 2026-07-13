import 'package:flutter/material.dart';
import '../widgets/movie_card.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> movies = [
      {
        "title": "Interstellar",
        "genre": "Sci-Fi",
        "image": "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba",

        "movieUrl": "https://youtu.be/zSWdZVtXT7E",

        "downloadUrl": "https://www.netflix.com",
      },

      {
        "title": "Batman",
        "genre": "Action",
        "image": "https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c",

        "movieUrl": "https://youtu.be/mqqft2x_Aa4",

        "downloadUrl": "https://www.hbomax.com",
      },

      {
        "title": "Joker",
        "genre": "Thriller",
        "image": "https://images.unsplash.com/photo-1440404653325-ab127d49abc1",

        "movieUrl": "https://youtu.be/zAGVQLHvwOY",

        "downloadUrl": "https://www.netflix.com",
      },

      {
        "title": "Avengers",
        "genre": "Superhero",
        "image": "https://images.unsplash.com/photo-1478720568477-152d9b164e26",

        "movieUrl": "https://youtu.be/TcMBFSGVi1c",

        "downloadUrl": "https://www.disneyplus.com",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text("Movies", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: GridView.builder(
          itemCount: movies.length,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 20,
            childAspectRatio: 0.58,
          ),

          itemBuilder: (context, index) {
            final movie = movies[index];

            return MovieCard(movie: movie);
          },
        ),
      ),
    );
  }
}

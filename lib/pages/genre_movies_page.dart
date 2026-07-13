import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/movie_card.dart';

class GenreMoviesPage extends StatelessWidget {
  final String title;
  final int genreId;

  const GenreMoviesPage({
    super.key,
    required this.title,
    required this.genreId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050B18),

        title: Text(
          title,

          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder(
        future: ApiService.getMoviesByGenre(genreId),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: movies.length,

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,

              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              childAspectRatio: 0.58,
            ),

            itemBuilder: (context, index) {
              final movie = movies[index];

              return MovieCard(movie: movie);
            },
          );
        },
      ),
    );
  }
}

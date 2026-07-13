import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/movie_card.dart';

class TrendingNowPage extends StatelessWidget {
  const TrendingNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050B18),
        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Trending Now",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: FutureBuilder(
        future: ApiService.getTrendingMovies(),

        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Failed to load movies",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // DATA FILM
          final movies = snapshot.data as List;

          return GridView.builder(
            padding: const EdgeInsets.all(12),

            itemCount: movies.length,

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,

              crossAxisSpacing: 10,
              mainAxisSpacing: 10,

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

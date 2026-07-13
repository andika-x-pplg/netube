import 'package:flutter/material.dart';
import '../pages/movie_detail_page.dart';

class MovieCard extends StatelessWidget {
  final Map movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        "https://image.tmdb.org/t/p/w500${movie['poster_path']}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, animation, __) =>
                    MovieDetailPage(movie: movie),

            transitionsBuilder:
                (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,

                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.95,
                    end: 1.0,
                  ).animate(animation),

                  child: child,
                ),
              );
            },

            transitionDuration:
                const Duration(milliseconds: 400),
          ),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        width: 170,
        margin: const EdgeInsets.only(right: 18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // MOVIE IMAGE
            Hero(
              tag: movie['id'].toString(),

              child: Container(
                height: 230,

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.4),

                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(24),

                  child: Image.network(
                    imageUrl,

                    fit: BoxFit.cover,

                    loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        color: const Color(
                          0xFF111827,
                        ),

                        child: const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    },

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        color:
                            const Color(0xFF111827),

                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // TITLE
            Text(
              movie['title'] ??
                  "No Title",

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // OVERVIEW
            Text(
              movie['overview'] ??
                  "No Description",

              maxLines: 2,

              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                color:
                    Colors.grey.shade400,

                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
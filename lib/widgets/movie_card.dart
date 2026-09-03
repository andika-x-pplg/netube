import 'package:flutter/material.dart';
import '../pages/movie_detail_page.dart';
import '../theme/netube_theme.dart';

class MovieCard extends StatelessWidget {
  final Map movie;
  final int? rank;
  final double width;

  const MovieCard({
    super.key,
    required this.movie,
    this.rank,
    this.width = 148,
  });

  @override
  Widget build(BuildContext context) {
    final poster = movie['poster_path'];
    final imageUrl = poster is String && poster.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500$poster'
        : movie['image'] as String?;
    final rating = movie['vote_average'];
    final heroTag = movie['id']?.toString() ?? movie['title'].toString();

    return SizedBox(
      width: rank == null ? width : width + 42,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: MovieDetailPage(movie: movie),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: rank == null ? 0 : 38,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Hero(
                      tag: heroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl == null
                            ? const _PosterFallback()
                            : Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _PosterFallback(),
                              ),
                      ),
                    ),
                  ),
                  if (rank != null)
                    Positioned(
                      left: 0,
                      bottom: -12,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 88,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: rank == null ? 0 : 38),
              child: Text(
                movie['title'] ?? 'Untitled',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (rating is num || movie['genre'] != null)
              Padding(
                padding: EdgeInsets.only(left: rank == null ? 0 : 38, top: 3),
                child: Text(
                  rating is num
                      ? '★ ${rating.toStringAsFixed(1)}'
                      : '${movie['genre']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: NetubeColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: NetubeColors.surfaceHigh,
    child: Center(
      child: Icon(Icons.movie_outlined, color: Colors.white38, size: 42),
    ),
  );
}

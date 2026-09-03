import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/netube_theme.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';
import 'search_page.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  static const _genres = <(String, int?)>[
    ('All', null),
    ('Action', 28),
    ('Drama', 18),
    ('Comedy', 35),
    ('Sci-Fi', 878),
    ('Animation', 16),
    ('Horror', 27),
    ('Romance', 10749),
  ];

  int? _selectedGenre;
  late Future<List<dynamic>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = ApiService.getFeaturedMovies();
  }

  void _selectGenre(int? genreId) {
    if (_selectedGenre == genreId) return;
    setState(() {
      _selectedGenre = genreId;
      _moviesFuture = genreId == null
          ? ApiService.getFeaturedMovies()
          : ApiService.getMoviesByGenre(genreId);
    });
  }

  void _retry() {
    setState(() {
      _moviesFuture = _selectedGenre == null
          ? ApiService.getFeaturedMovies()
          : ApiService.getMoviesByGenre(_selectedGenre!);
    });
  }

  void _openSearch() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SearchPage()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildGenreChips()),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(child: _ExploreLoading())
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: _ExploreMessage(
                      icon: Icons.cloud_off_rounded,
                      title: 'Movies are taking a break',
                      subtitle: 'Check your connection and try again.',
                      actionLabel: 'Try again',
                      onAction: _retry,
                    ),
                  )
                else if (!snapshot.hasData || snapshot.data!.isEmpty)
                  const SliverFillRemaining(
                    child: _ExploreMessage(
                      icon: Icons.movie_filter_outlined,
                      title: 'No movies found',
                      subtitle: 'Try another category.',
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _FeaturedMovie(movie: snapshot.data!.first as Map),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedGenre == null
                                ? 'Popular Movies'
                                : '${_genres.firstWhere((item) => item.$2 == _selectedGenre).$1} Movies',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${snapshot.data!.length} titles',
                            style: const TextStyle(
                              color: NetubeColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.crossAxisExtent >= 700
                            ? 4
                            : constraints.crossAxisExtent >= 500
                            ? 3
                            : 2;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 20,
                                childAspectRatio: .57,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                MovieCard(movie: snapshot.data![index]),
                            childCount: snapshot.data!.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore',
          style: TextStyle(
            fontSize: 32,
            letterSpacing: -.7,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Discover movies you'll love",
          style: TextStyle(color: NetubeColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          readOnly: true,
          onTap: _openSearch,
          decoration: InputDecoration(
            hintText: 'Search movies...',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF98A1B2),
            ),
            suffixIcon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF687284),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFF111827),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: Color(0xFF1B2638)),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildGenreChips() => SizedBox(
    height: 42,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: _genres.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final genre = _genres[index];
        final selected = genre.$2 == _selectedGenre;
        return ChoiceChip(
          label: Text(genre.$1),
          selected: selected,
          onSelected: (_) => _selectGenre(genre.$2),
          showCheckmark: false,
          side: BorderSide.none,
          backgroundColor: NetubeColors.surfaceHigh,
          selectedColor: Colors.redAccent,
          labelStyle: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          shape: const StadiumBorder(),
        );
      },
    ),
  );
}

class _FeaturedMovie extends StatelessWidget {
  final Map movie;
  const _FeaturedMovie({required this.movie});

  @override
  Widget build(BuildContext context) {
    final backdrop = movie['backdrop_path'];
    final rating = movie['vote_average'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Today',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Material(
              color: NetubeColors.surface,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailPage(movie: movie),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (backdrop != null)
                      Image.network(
                        'https://image.tmdb.org/t/p/w780$backdrop',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(color: NetubeColors.surfaceHigh),
                      ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE6050B18)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie['title'] ?? 'Featured',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '★ ${rating is num ? rating.toStringAsFixed(1) : '—'}  •  ${(movie['release_date'] ?? '').toString().split('-').first}',
                            style: const TextStyle(
                              color: Color(0xFFD8DCE4),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreLoading extends StatelessWidget {
  const _ExploreLoading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: Colors.redAccent));
}

class _ExploreMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _ExploreMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF687284)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: NetubeColors.textSecondary),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel ?? 'Retry'),
            ),
          ],
        ],
      ),
    ),
  );
}

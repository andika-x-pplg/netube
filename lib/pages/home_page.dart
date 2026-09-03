import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/watch_later_service.dart';
import '../theme/netube_theme.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<dynamic>> popular = ApiService.getFeaturedMovies();
  late final Future<List<dynamic>> trending = ApiService.getTrendingMovies();
  late final Future<List<dynamic>> action = ApiService.getMoviesByGenre(28);
  late final Future<List<dynamic>> sciFi = ApiService.getMoviesByGenre(878);
  late final Future<List<dynamic>> animation = ApiService.getMoviesByGenre(16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text(
              'NETUBE',
              style: TextStyle(
                color: NetubeColors.accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Search',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                ),
                icon: const Icon(Icons.search_rounded),
              ),
              StreamBuilder<int>(
                stream: NotificationService.getUnreadCount(),
                builder: (context, snapshot) => Badge(
                  isLabelVisible: (snapshot.data ?? 0) > 0,
                  label: Text('${snapshot.data ?? 0}'),
                  child: IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  ),
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _Billboard(future: trending)),
          SliverToBoxAdapter(
            child: _MovieSection(
              title: 'Trending Now',
              future: trending,
              ranked: true,
            ),
          ),
          SliverToBoxAdapter(
            child: _MovieSection(title: 'Popular on Netube', future: popular),
          ),
          SliverToBoxAdapter(
            child: _MovieSection(title: 'Action', future: action),
          ),
          SliverToBoxAdapter(
            child: _MovieSection(title: 'Sci-Fi Worlds', future: sciFi),
          ),
          SliverToBoxAdapter(
            child: _MovieSection(
              title: 'Recommended For You',
              future: animation,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _Billboard extends StatelessWidget {
  final Future<List<dynamic>> future;
  const _Billboard({required this.future});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
    future: future,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const AspectRatio(
          aspectRatio: 1.05,
          child: ColoredBox(color: NetubeColors.surface),
        );
      }
      final movie = snapshot.data!.first as Map;
      final backdrop = movie['backdrop_path'];
      return AspectRatio(
        aspectRatio: 1.05,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (backdrop != null)
              Image.network(
                'https://image.tmdb.org/t/p/w1280$backdrop',
                fit: BoxFit.cover,
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x55050505),
                    NetubeColors.background,
                  ],
                  stops: [0, .52, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'] ?? 'Featured',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(movie['release_date'] ?? '').toString().split('-').first}  •  ★ ${(movie['vote_average'] as num?)?.toStringAsFixed(1) ?? '—'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie['overview'] ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NetubeColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(movie: movie),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            await WatchLaterService.addMovie(movie);
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to Watch Later'),
                                ),
                              );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('My List'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _MovieSection extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> future;
  final bool ranked;
  const _MovieSection({
    required this.title,
    required this.future,
    this.ranked = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 248,
          child: FutureBuilder<List<dynamic>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text('Unable to load movies'));
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.take(10).length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) => MovieCard(
                  movie: snapshot.data![index] as Map,
                  rank: ranked ? index + 1 : null,
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

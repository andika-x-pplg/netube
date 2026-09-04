import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/library_widgets.dart';
import 'movie_detail_page.dart';
import 'youtube_player_page.dart';

class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({super.key});
  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: libraryBackground,
      appBar: AppBar(
        backgroundColor: libraryBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Watch History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              child: Column(
                children: [
                  const LibraryHeader(
                    title: 'Watch History',
                    description: 'Continue where you left off.',
                    icon: Icons.history_rounded,
                  ),
                  const SizedBox(height: 24),
                  NetubeSegmentedControl(
                    selectedIndex: _selectedIndex,
                    onChanged: (value) =>
                        setState(() => _selectedIndex = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(.025, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _selectedIndex == 0
                    ? _MovieHistory(key: const ValueKey('movies'), uid: uid)
                    : _VideoHistory(key: const ValueKey('videos'), uid: uid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieHistory extends StatelessWidget {
  const _MovieHistory({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('history')
        .doc(uid)
        .collection('movies')
        .orderBy('watchedAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LibraryLoadingState();
      }
      final movies = snapshot.data?.docs ?? [];
      if (movies.isEmpty) {
        return const SingleChildScrollView(
          child: LibraryEmptyState(
            icon: Icons.history_rounded,
            title: 'No movie history yet',
            description: 'Movies you watch will appear here.',
          ),
        );
      }
      return ListView(
        key: const PageStorageKey('history-movies'),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          LibrarySectionHeader(title: 'Recently Watched', count: movies.length),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final movie = movies[index].data() as Map<String, dynamic>;
                return _HistoryMovieCard(movie: movie);
              },
            ),
          ),
        ],
      );
    },
  );
}

class _HistoryMovieCard extends StatelessWidget {
  const _HistoryMovieCard({required this.movie});
  final Map<String, dynamic> movie;

  @override
  Widget build(BuildContext context) {
    final posterPath = movie['poster_path']?.toString() ?? '';
    return SizedBox(
      width: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: NetworkArtwork(
                  url: posterPath.isEmpty
                      ? ''
                      : 'https://image.tmdb.org/t/p/w500$posterPath',
                  fallbackIcon: Icons.movie_outlined,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              movie['title']?.toString() ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoHistory extends StatelessWidget {
  const _VideoHistory({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('history')
        .doc(uid)
        .collection('videos')
        .orderBy('watchedAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LibraryLoadingState();
      }
      final videos = snapshot.data?.docs ?? [];
      if (videos.isEmpty) {
        return const SingleChildScrollView(
          child: LibraryEmptyState(
            icon: Icons.play_circle_outline_rounded,
            title: 'No video history yet',
            description: 'Videos you watch will appear here.',
          ),
        );
      }
      return ListView.separated(
        key: const PageStorageKey('history-videos'),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        itemCount: videos.length + 1,
        separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 16 : 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return LibrarySectionHeader(
              title: 'Recently Watched',
              count: videos.length,
            );
          }
          final video = videos[index - 1].data() as Map<String, dynamic>;
          return _HistoryVideoTile(video: video);
        },
      );
    },
  );
}

class _HistoryVideoTile extends StatelessWidget {
  const _HistoryVideoTile({required this.video});
  final Map<String, dynamic> video;

  @override
  Widget build(BuildContext context) => Material(
    color: librarySurface,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerPage(
            videoId: video['videoId'],
            title: video['title'],
            thumbnailUrl: video['thumbnail'],
            channelId: video['channelId'],
            channelTitle: video['channelTitle'],
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkArtwork(
                    url: video['thumbnail']?.toString() ?? '',
                    fallbackIcon: Icons.play_circle_outline_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video['channelTitle']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    ),
  );
}

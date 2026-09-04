import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/library_widgets.dart';
import 'movie_detail_page.dart';
import 'youtube_player_page.dart';

class WatchLaterPage extends StatefulWidget {
  const WatchLaterPage({super.key});
  @override
  State<WatchLaterPage> createState() => _WatchLaterPageState();
}

class _WatchLaterPageState extends State<WatchLaterPage> {
  int _selectedIndex = 0;

  Future<void> _showRemoveDialog({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove from Watch Later?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This item will be removed from your saved library.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: libraryAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (result == true) {
      await FirebaseFirestore.instance
          .collection('watchlater')
          .doc(uid)
          .collection(type)
          .doc(id)
          .delete();
    }
  }

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
          'Watch Later',
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
                    title: 'Watch Later',
                    description: 'Everything you saved, ready when you are.',
                    icon: Icons.bookmark_rounded,
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
                    ? _MoviesTab(
                        key: const ValueKey('movies'),
                        uid: uid,
                        onRemove: _showRemoveDialog,
                      )
                    : _VideosTab(
                        key: const ValueKey('videos'),
                        uid: uid,
                        onRemove: _showRemoveDialog,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef RemoveItem =
    Future<void> Function({
      required BuildContext context,
      required String type,
      required String id,
    });

class _MoviesTab extends StatelessWidget {
  const _MoviesTab({super.key, required this.uid, required this.onRemove});
  final String uid;
  final RemoveItem onRemove;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('watchlater')
        .doc(uid)
        .collection('movies')
        .orderBy('savedAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LibraryLoadingState();
      }
      final movies = snapshot.data?.docs ?? [];
      if (movies.isEmpty) {
        return const SingleChildScrollView(
          child: LibraryEmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'Your Watch Later is empty',
            description: 'Movies you save will appear here.',
          ),
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720
              ? 4
              : constraints.maxWidth >= 480
              ? 3
              : 2;
          return CustomScrollView(
            key: const PageStorageKey('watch-later-movies'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                sliver: SliverToBoxAdapter(
                  child: LibrarySectionHeader(
                    title: 'Saved Movies',
                    count: movies.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverGrid.builder(
                  itemCount: movies.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 14,
                    childAspectRatio: .58,
                  ),
                  itemBuilder: (context, index) {
                    final movie = movies[index].data() as Map<String, dynamic>;
                    return _SavedMovieCard(
                      movie: movie,
                      onRemove: () => onRemove(
                        context: context,
                        type: 'movies',
                        id: movie['id'].toString(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _SavedMovieCard extends StatelessWidget {
  const _SavedMovieCard({required this.movie, required this.onRemove});
  final Map<String, dynamic> movie;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final posterPath = movie['poster_path']?.toString() ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
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
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: const Color(0xCC050B18),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: onRemove,
                      tooltip: 'Remove from Watch Later',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.bookmark_rounded,
                        color: libraryAccent,
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ],
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
    );
  }
}

class _VideosTab extends StatelessWidget {
  const _VideosTab({super.key, required this.uid, required this.onRemove});
  final String uid;
  final RemoveItem onRemove;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('watchlater')
        .doc(uid)
        .collection('videos')
        .orderBy('savedAt', descending: true)
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
            title: 'Nothing saved yet',
            description: 'Save videos to watch them later.',
          ),
        );
      }
      return ListView.separated(
        key: const PageStorageKey('watch-later-videos'),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        itemCount: videos.length + 1,
        separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 16 : 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return LibrarySectionHeader(
              title: 'Saved Videos',
              count: videos.length,
            );
          }
          final video = videos[index - 1].data() as Map<String, dynamic>;
          return _SavedVideoTile(
            video: video,
            onRemove: () => onRemove(
              context: context,
              type: 'videos',
              id: video['videoId'].toString(),
            ),
          );
        },
      );
    },
  );
}

class _SavedVideoTile extends StatelessWidget {
  const _SavedVideoTile({required this.video, required this.onRemove});
  final Map<String, dynamic> video;
  final VoidCallback onRemove;

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
              width: 132,
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
            const SizedBox(width: 12),
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
                  const SizedBox(height: 7),
                  Text(
                    video['channelTitle']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: 'Remove from Watch Later',
              icon: const Icon(
                Icons.bookmark_rounded,
                color: libraryAccent,
                size: 21,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

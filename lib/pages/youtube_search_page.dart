import 'package:flutter/material.dart';

import '../models/youtube_video_model.dart';
import '../services/youtube_service.dart';
import '../theme/netube_theme.dart';
import '../widgets/netube_video_card.dart';
import 'youtube_player_page.dart';

class YoutubeSearchPage extends StatefulWidget {
  const YoutubeSearchPage({super.key});

  @override
  State<YoutubeSearchPage> createState() => _YoutubeSearchPageState();
}

class _YoutubeSearchPageState extends State<YoutubeSearchPage> {
  final YoutubeService _youtubeService = YoutubeService();
  final TextEditingController _searchController = TextEditingController();
  List<YoutubeVideo> _videos = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _hasError = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> searchVideos() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _hasError = false;
    });

    try {
      final results = await _youtubeService.fetchVideosByCategory(query);
      if (!mounted) return;
      setState(() {
        _videos = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to search videos')));
    }
  }

  void _openVideo(YoutubeVideo video) {
    if (video.id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Video ID tidak ditemukan')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubePlayerPage(
          videoId: video.id,
          title: video.title,
          thumbnailUrl: video.thumbnailUrl,
          channelId: video.channelId,
          channelTitle: video.channelTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NetubeColors.background,
    appBar: AppBar(
      title: const Text(
        'Search Videos',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => searchVideos(),
              decoration: InputDecoration(
                hintText: 'Search videos...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9B9B9B),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _videos = [];
                            _hasSearched = false;
                          });
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    IconButton(
                      tooltip: 'Search',
                      onPressed: searchVideos,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF242424)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: Colors.redAccent,
            ),
          Expanded(child: _buildResults()),
        ],
      ),
    ),
  );

  Widget _buildResults() {
    if (_isLoading) return const SizedBox.shrink();
    if (_hasError) {
      return _SearchState(
        icon: Icons.cloud_off_rounded,
        title: 'Search unavailable',
        subtitle: 'Check your connection and try again.',
        action: searchVideos,
      );
    }
    if (!_hasSearched) {
      return const _SearchState(
        icon: Icons.ondemand_video_rounded,
        title: 'Find something to watch',
        subtitle: 'Search videos, music, creators, and live content.',
      );
    }
    if (_videos.isEmpty) {
      return const _SearchState(
        icon: Icons.search_off_rounded,
        title: 'No videos found',
        subtitle: 'Try another search term.',
      );
    }
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      itemCount: _videos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final video = _videos[index];
        return NetubeVideoCard(video: video, onTap: () => _openVideo(video));
      },
    );
  }
}

class _SearchState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  const _SearchState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF656565)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: NetubeColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: action, child: const Text('Try again')),
          ],
        ],
      ),
    ),
  );
}

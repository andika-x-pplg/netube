import 'package:flutter/material.dart';

import '../models/youtube_video_model.dart';
import '../services/youtube_service.dart';
import '../theme/netube_theme.dart';
import '../widgets/netube_video_card.dart';
import 'youtube_player_page.dart';
import 'youtube_search_page.dart';

class YoutubeHomePage extends StatefulWidget {
  const YoutubeHomePage({super.key});

  @override
  State<YoutubeHomePage> createState() => _YoutubeHomePageState();
}

class _YoutubeHomePageState extends State<YoutubeHomePage> {
  final YoutubeService _youtubeService = YoutubeService();
  final List<String> _categories = [
    'Popular',
    'Trending',
    'Live',
    'Music',
    'Gaming',
    'Movies',
    'Anime',
  ];

  String _selectedCategory = 'Popular';
  List<YoutubeVideo> _videos = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<YoutubeVideo> fetchedVideos;
      if (_selectedCategory == 'Popular' || _selectedCategory == 'Trending') {
        fetchedVideos = await _youtubeService.fetchTrendingVideos();
      } else if (_selectedCategory == 'Live') {
        fetchedVideos = await _youtubeService.fetchLiveVideos();
      } else {
        fetchedVideos = await _youtubeService.fetchVideosByCategory(
          _selectedCategory,
        );
      }

      if (!mounted) return;
      setState(() {
        _videos = fetchedVideos;
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
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat video')));
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetubeColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCategories()),
            if (_isLoading)
              const SliverFillRemaining(child: _VideoLoading())
            else if (_hasError)
              SliverFillRemaining(
                child: _VideoState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Unable to load videos',
                  subtitle: 'Check your connection and try again.',
                  onRetry: _loadVideos,
                ),
              )
            else if (_videos.isEmpty)
              const SliverFillRemaining(
                child: _VideoState(
                  icon: Icons.video_library_outlined,
                  title: 'No videos found',
                  subtitle: 'Try another category.',
                ),
              )
            else ...[
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(18, 25, 18, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Featured',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverToBoxAdapter(
                  child: NetubeVideoCard(
                    video: _videos.first,
                    featured: true,
                    isLive: _selectedCategory == 'Live',
                    onTap: () => _openVideo(_videos.first),
                  ),
                ),
              ),
              if (_videos.length > 1) ...[
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(18, 30, 18, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'More Videos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                  sliver: SliverList.separated(
                    itemCount: _videos.length - 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final video = _videos[index + 1];
                      return NetubeVideoCard(
                        video: video,
                        isLive: _selectedCategory == 'Live',
                        onTap: () => _openVideo(video),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 10, 14),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF3045), Color(0xFFFF7417)],
                    ).createShader(bounds),
                    child: const Text(
                      'NETUBE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'VIDEO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Discover videos, music, and live content',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: NetubeColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Search videos',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const YoutubeSearchPage()),
          ),
          icon: const Icon(Icons.search_rounded, size: 27),
        ),
      ],
    ),
  );

  Widget _buildCategories() => SizedBox(
    height: 43,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final selected = category == _selectedCategory;
        return GestureDetector(
          onTap: () {
            if (selected) return;
            setState(() => _selectedCategory = category);
            _loadVideos();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [Color(0xFFE50935), Color(0xFFFF641A)],
                    )
                  : null,
              color: selected ? null : NetubeColors.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              category,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFC1C1C1),
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _VideoLoading extends StatelessWidget {
  const _VideoLoading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: Colors.redAccent));
}

class _VideoState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  const _VideoState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: NetubeColors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    ),
  );
}

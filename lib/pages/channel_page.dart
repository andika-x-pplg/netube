import 'package:flutter/material.dart';

import '../models/youtube_video_model.dart';
import '../services/subscription_service.dart';
import '../services/youtube_service.dart';
import '../widgets/library_widgets.dart';
import 'youtube_player_page.dart';

class ChannelPage extends StatefulWidget {
  final String channelId;
  final String channelName;

  const ChannelPage({
    super.key,
    required this.channelId,
    required this.channelName,
  });

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  final YoutubeService _youtubeService = YoutubeService();
  List<YoutubeVideo> videos = [];
  bool isLoading = true;
  bool hasError = false;
  bool isSubscribed = false;
  bool isUpdatingSubscription = false;

  @override
  void initState() {
    super.initState();
    loadVideos();
    _checkSubscription();
  }

  Future<void> loadVideos() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }
    try {
      final result = await _youtubeService.fetchChannelVideos(widget.channelId);
      if (!mounted) return;
      setState(() {
        videos = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _checkSubscription() async {
    final result = await SubscriptionService.isSubscribed(widget.channelId);
    if (!mounted) return;
    setState(() => isSubscribed = result);
  }

  Future<void> _toggleSubscription() async {
    if (isUpdatingSubscription) return;
    setState(() => isUpdatingSubscription = true);
    try {
      if (isSubscribed) {
        await SubscriptionService.unsubscribe(widget.channelId);
      } else {
        await SubscriptionService.subscribe(
          channelId: widget.channelId,
          channelName: widget.channelName,
        );
      }
      if (!mounted) return;
      setState(() => isSubscribed = !isSubscribed);
    } finally {
      if (mounted) setState(() => isUpdatingSubscription = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: libraryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: libraryBackground,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            expandedHeight: 42,
            title: Text(
              widget.channelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SliverToBoxAdapter(child: _buildChannelHero()),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 26, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(
                    Icons.video_library_rounded,
                    color: libraryAccent,
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Videos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._buildVideoContent(),
        ],
      ),
    );
  }

  Widget _buildChannelHero() {
    final trimmedName = widget.channelName.trim();
    final initial = trimmedName.isEmpty
        ? null
        : trimmedName.characters.first.toUpperCase();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24101A), Color(0xFF111827), Color(0xFF090F1C)],
          stops: [0, .52, 1],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF493E), Color(0xFF941414)],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: .18),
                width: 3,
              ),
            ),
            child: initial == null
                ? const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 34,
                  )
                : Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.channelName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            videos.isEmpty
                ? 'Creator channel'
                : '${videos.length} ${videos.length == 1 ? 'video' : 'videos'}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              gradient: isSubscribed
                  ? null
                  : const LinearGradient(
                      colors: [libraryAccent, Color(0xFFFF6A1A)],
                    ),
              color: isSubscribed ? Colors.white.withValues(alpha: .09) : null,
              borderRadius: BorderRadius.circular(14),
              border: isSubscribed
                  ? Border.all(color: Colors.white.withValues(alpha: .09))
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isUpdatingSubscription ? null : _toggleSubscription,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUpdatingSubscription)
                        const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          isSubscribed
                              ? Icons.check_rounded
                              : Icons.add_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isSubscribed ? 'Subscribed' : 'Subscribe',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVideoContent() {
    if (isLoading) {
      return const [SliverToBoxAdapter(child: LibraryLoadingState())];
    }
    if (hasError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ChannelMessage(
            icon: Icons.error_outline_rounded,
            title: "Couldn't load channel",
            description: 'Please check your connection and try again.',
            action: FilledButton.icon(
              onPressed: loadVideos,
              style: FilledButton.styleFrom(backgroundColor: libraryAccent),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ),
        ),
      ];
    }
    if (videos.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: LibraryEmptyState(
            icon: Icons.video_library_outlined,
            title: 'No videos yet',
            description: 'New uploads from this channel will appear here.',
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        sliver: SliverList.separated(
          itemCount: videos.length,
          separatorBuilder: (_, _) => const SizedBox(height: 18),
          itemBuilder: (context, index) => _ChannelVideoCard(
            video: videos[index],
            onTap: () => _openVideo(videos[index]),
          ),
        ),
      ),
    ];
  }

  void _openVideo(YoutubeVideo video) {
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
}

class _ChannelVideoCard extends StatelessWidget {
  const _ChannelVideoCard({required this.video, required this.onTap});
  final YoutubeVideo video;
  final VoidCallback onTap;

  String get _publishedDate {
    final date = DateTime.tryParse(video.publishedAt)?.toLocal();
    if (date == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Published ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final publishedDate = _publishedDate;
    return Material(
      color: librarySurface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: NetworkArtwork(
                url: video.thumbnailUrl,
                fallbackIcon: Icons.play_circle_outline_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (publishedDate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      publishedDate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .46),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelMessage extends StatelessWidget {
  const _ChannelMessage({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: libraryAccent, size: 38),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, height: 1.4),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    ),
  );
}

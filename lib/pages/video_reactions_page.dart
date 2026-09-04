import 'package:flutter/material.dart';

import '../services/video_reaction_service.dart';
import '../theme/netube_theme.dart';
import 'youtube_player_page.dart';

class VideoReactionsPage extends StatelessWidget {
  const VideoReactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: NetubeColors.background,

        appBar: AppBar(
          title: const Text(
            'Aktivitas Video',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          bottom: const TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.thumb_up), text: 'Disukai'),
              Tab(icon: Icon(Icons.thumb_down), text: 'Tidak Disukai'),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            // Tab video yang disukai
            VideoReactionList(reaction: 'like'),

            // Tab video yang tidak disukai
            VideoReactionList(reaction: 'dislike'),
          ],
        ),
      ),
    );
  }
}

// ======================================
// DAFTAR VIDEO BERDASARKAN REAKSI
// ======================================
class VideoReactionList extends StatelessWidget {
  final String reaction;

  const VideoReactionList({super.key, required this.reaction});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: VideoReactionService.getReactionVideos(reaction),

      builder: (context, snapshot) {
        // Saat data masih dimuat
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        // Jika terjadi error dari Firebase
        if (snapshot.hasError) {
          return const VideoReactionEmpty(
            icon: Icons.cloud_off,
            title: 'Gagal memuat video',
            subtitle: 'Periksa koneksi internet dan Firebase.',
          );
        }

        final videos = snapshot.data ?? <Map<String, dynamic>>[];

        // Jika belum ada video
        if (videos.isEmpty) {
          if (reaction == 'like') {
            return const VideoReactionEmpty(
              icon: Icons.thumb_up_outlined,
              title: 'Belum ada video yang disukai',
              subtitle: 'Video yang kamu sukai akan muncul di sini.',
            );
          }

          return const VideoReactionEmpty(
            icon: Icons.thumb_down_outlined,
            title: 'Belum ada video yang tidak disukai',
            subtitle: 'Video yang tidak kamu sukai akan muncul di sini.',
          );
        }

        // Menampilkan daftar video
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,

          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },

          itemBuilder: (context, index) {
            final video = videos[index];

            return VideoReactionCard(video: video, reaction: reaction);
          },
        );
      },
    );
  }
}

// ======================================
// CARD VIDEO
// ======================================
class VideoReactionCard extends StatelessWidget {
  final Map<String, dynamic> video;
  final String reaction;

  const VideoReactionCard({
    super.key,
    required this.video,
    required this.reaction,
  });

  String getData(String fieldName) {
    return video[fieldName]?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final videoId = getData('videoId');
    final title = getData('title');
    final thumbnail = getData('thumbnail');
    final channelId = getData('channelId');
    final channelTitle = getData('channelTitle');

    return Material(
      color: NetubeColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        // Membuka kembali video ketika card ditekan
        onTap: () {
          if (videoId.isEmpty) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return YoutubePlayerPage(
                  videoId: videoId,
                  title: title,
                  thumbnailUrl: thumbnail,
                  channelId: channelId,
                  channelTitle: channelTitle,
                );
              },
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(10),

          child: Row(
            children: [
              // Thumbnail video
              ClipRRect(
                borderRadius: BorderRadius.circular(10),

                child: Image.network(
                  thumbnail,
                  width: 130,
                  height: 78,
                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 130,
                      height: 78,
                      color: Colors.black26,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Judul dan nama channel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      channelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Ikon status reaksi
              Icon(
                reaction == 'like' ? Icons.thumb_up : Icons.thumb_down,
                color: reaction == 'like' ? Colors.red : Colors.grey,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================
// TAMPILAN KETIKA DATA KOSONG
// ======================================
class VideoReactionEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const VideoReactionEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(icon, color: Colors.grey, size: 55),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

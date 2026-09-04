import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/notification_service.dart';
import '../widgets/library_widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: libraryBackground,
      appBar: AppBar(
        backgroundColor: libraryBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<QuerySnapshot>(
          stream: NotificationService.getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _NotificationMessage(
                icon: Icons.error_outline_rounded,
                title: "Couldn't load notifications",
                description: 'Please try again in a moment.',
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LibraryLoadingState();
            }
            final notifications = snapshot.data?.docs ?? [];
            final unreadCount = notifications.where((document) {
              final data = document.data() as Map<String, dynamic>;
              return data['isRead'] != true;
            }).length;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: _NotificationHeader(unreadCount: unreadCount),
                  ),
                ),
                if (notifications.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NotificationMessage(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications yet',
                      description:
                          'Likes and replies to your activity will appear here.',
                    ),
                  )
                else ...[
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Recent activity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    sliver: SliverList.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final document = notifications[index];
                        return _NotificationCard(
                          documentId: document.id,
                          data: document.data() as Map<String, dynamic>,
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
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.unreadCount});
  final int unreadCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF24101A), Color(0xFF111827), Color(0xFF0B1220)],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: libraryAccent.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            color: libraryAccent,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                unreadCount == 0
                    ? "You're all caught up"
                    : '$unreadCount unread ${unreadCount == 1 ? 'notification' : 'notifications'}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.documentId, required this.data});
  final String documentId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final isRead = data['isRead'] == true;
    final type = data['type']?.toString() ?? '';
    final createdAt = data['createdAt'];
    final timestamp = createdAt is Timestamp
        ? timeago.format(createdAt.toDate())
        : 'Just now';
    final isReply = type == 'video_comment_reply';
    final isVideoActivity = type.startsWith('video_comment_');
    final icon = isReply ? Icons.reply_rounded : Icons.favorite_rounded;
    final label = isVideoActivity ? 'Netube Video' : 'Movie Review';
    return Material(
      color: isRead ? librarySurface : const Color(0xFF21131A),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (!isRead) await NotificationService.markAsRead(documentId);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead
                  ? Colors.white.withValues(alpha: .05)
                  : libraryAccent.withValues(alpha: .18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: libraryAccent.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: libraryAccent, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: libraryAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          timestamp,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      data['message']?.toString() ?? 'Notifikasi baru',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.35,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: libraryAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationMessage extends StatelessWidget {
  const _NotificationMessage({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: libraryAccent.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: libraryAccent, size: 34),
          ),
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
        ],
      ),
    ),
  );
}

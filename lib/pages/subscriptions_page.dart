import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/library_widgets.dart';
import 'channel_page.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

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
          'Subscriptions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('subscriptions')
              .doc(uid)
              .collection('channels')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LibraryLoadingState();
            }
            final channels = snapshot.data?.docs ?? [];
            return CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 26),
                  sliver: SliverToBoxAdapter(
                    child: LibraryHeader(
                      title: 'Your Channels',
                      description: 'Creators you follow, all in one place.',
                      icon: Icons.subscriptions_rounded,
                    ),
                  ),
                ),
                if (channels.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LibraryEmptyState(
                      icon: Icons.subscriptions_outlined,
                      title: 'No subscriptions yet',
                      description:
                          'Channels you subscribe to will appear here.',
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    sliver: SliverToBoxAdapter(
                      child: LibrarySectionHeader(
                        title: 'Subscriptions',
                        count: channels.length,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    sliver: SliverList.separated(
                      itemCount: channels.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final channel =
                            channels[index].data() as Map<String, dynamic>;
                        final channelName =
                            channel['channelName']?.toString() ?? '';
                        return _SubscriptionChannelCard(
                          channelName: channelName,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChannelPage(
                                  channelId: channel['channelId'],
                                  channelName: channel['channelName'],
                                ),
                              ),
                            );
                          },
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

class _SubscriptionChannelCard extends StatelessWidget {
  const _SubscriptionChannelCard({
    required this.channelName,
    required this.onTap,
  });

  final String channelName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = channelName.trim().isEmpty
        ? null
        : channelName.trim().characters.first.toUpperCase();
    return Material(
      color: librarySurface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .06)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF3B30), Color(0xFF9F1717)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .12),
                    width: 2,
                  ),
                ),
                child: initial == null
                    ? const Icon(Icons.person_rounded, color: Colors.white)
                    : Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channelName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: libraryAccent,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Subscribed',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white30,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/netube_theme.dart';
import 'about_policy_page.dart';
import 'account_settings_page.dart';
import 'downloads_page.dart';
import 'feedback_page.dart';
import 'help_support_page.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'subscriptions_page.dart';
import 'video_audio_page.dart';
import 'watch_later_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final email = AuthService.auth.currentUser?.email ?? 'No email';
    final username = email.split('@').first;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: NetubeColors.accent,
                ),
                child: const CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: NetubeColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _Menu(
            icon: Icons.manage_accounts_outlined,
            label: 'Account Settings',
            page: const AccountSettingsPage(),
          ),
          StreamBuilder<int>(
            stream: NotificationService.getUnreadCount(),
            builder: (_, snapshot) => _Menu(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              page: const NotificationsPage(),
              badge: snapshot.data ?? 0,
            ),
          ),
          const _Menu(
            icon: Icons.subscriptions_outlined,
            label: 'Subscriptions',
            page: SubscriptionsPage(),
          ),
          const _Menu(
            icon: Icons.history_rounded,
            label: 'Watch History',
            page: WatchHistoryPage(),
          ),
          const _Menu(
            icon: Icons.bookmark_border_rounded,
            label: 'Watch Later',
            page: WatchLaterPage(),
          ),
          const _Menu(
            icon: Icons.download_outlined,
            label: 'Downloads',
            page: DownloadsPage(),
          ),
          const _Menu(
            icon: Icons.graphic_eq_rounded,
            label: 'Video & Audio',
            page: VideoAudioPage(),
          ),
          const _Menu(
            icon: Icons.support_agent_rounded,
            label: 'Help & Support',
            page: HelpSupportPage(),
          ),
          const _Menu(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Feedback',
            page: FeedbackPage(),
          ),
          const _Menu(
            icon: Icons.policy_outlined,
            label: 'About & Policy',
            page: AboutPolicyPage(),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: NetubeColors.divider),
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget page;
  final int badge;
  const _Menu({
    required this.icon,
    required this.label,
    required this.page,
    this.badge = 0,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: NetubeColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 21),
    ),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: NetubeColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge > 99 ? '99+' : '$badge',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_right_rounded,
          color: NetubeColors.textSecondary,
        ),
      ],
    ),
    onTap: () =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
  );
}

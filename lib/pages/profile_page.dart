import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/netube_theme.dart';
import '../widgets/bottom_navbar.dart';
import 'about_policy_page.dart';
import 'account_settings_page.dart';
import 'downloads_page.dart';
import 'feedback_page.dart';
import 'help_support_page.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'premium_page.dart';
import 'subscriptions_page.dart';
import 'video_audio_page.dart';
import 'video_reactions_page.dart';
import 'watch_later_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.auth.currentUser;
    final email = user?.email ?? 'No email';
    final username = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : email.split('@').first;

    return Scaffold(
      bottomNavigationBar: const BottomNavbar(currentIndex: 4),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            title: Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.list(
              children: [
                _ProfileHeader(username: username, email: email),
                const SizedBox(height: 16),
                const _PremiumBanner(),
                const SizedBox(height: 28),
                const _SectionLabel('Your activity'),
                const SizedBox(height: 10),
                _MenuGroup(
                  children: [
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
                      label: 'Watch history',
                      page: WatchHistoryPage(),
                    ),
                    const _Menu(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Watch later',
                      page: WatchLaterPage(),
                    ),
                    const _Menu(
                      icon: Icons.thumb_up_alt_outlined,
                      label: 'Video activity',
                      page: VideoReactionsPage(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Preferences'),
                const SizedBox(height: 10),
                const _MenuGroup(
                  children: [
                    _Menu(
                      icon: Icons.manage_accounts_outlined,
                      label: 'Account settings',
                      page: AccountSettingsPage(),
                    ),
                    _Menu(
                      icon: Icons.download_outlined,
                      label: 'Downloads',
                      page: DownloadsPage(),
                    ),
                    _Menu(
                      icon: Icons.graphic_eq_rounded,
                      label: 'Video & audio',
                      page: VideoAudioPage(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Support'),
                const SizedBox(height: 10),
                const _MenuGroup(
                  children: [
                    _Menu(
                      icon: Icons.support_agent_rounded,
                      label: 'Help & support',
                      page: HelpSupportPage(),
                    ),
                    _Menu(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Send feedback',
                      page: FeedbackPage(),
                    ),
                    _Menu(
                      icon: Icons.policy_outlined,
                      label: 'About & policy',
                      page: AboutPolicyPage(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: NetubeColors.divider),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.username, required this.email});

  final String username;
  final String email;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: NetubeColors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFFD36A), NetubeColors.accent],
            ),
          ),
          child: CircleAvatar(
            radius: 34,
            backgroundColor: NetubeColors.surfaceHigh,
            child: Text(
              username.isEmpty ? 'N' : username[0].toUpperCase(),
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: NetubeColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Free member',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Account settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
          ),
          icon: const Icon(Icons.settings_outlined, color: Colors.white70),
        ),
      ],
    ),
  );
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumPage()),
    ),
    child: Ink(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A1014), Color(0xFF17100B)],
        ),
        border: Border.all(color: const Color(0x66FFD36A)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x22FFD36A),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFD36A),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Netube Premium',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 5),
                Text(
                  'More freedom. More entertainment.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFFD36A)),
        ],
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      color: Colors.white38,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
  );
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: NetubeColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .05)),
    ),
    child: Column(children: children),
  );
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.icon,
    required this.label,
    required this.page,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final Widget page;
  final int badge;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 62,
    leading: Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        color: NetubeColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: Colors.white70),
    ),
    title: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
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
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, color: Colors.white30),
      ],
    ),
    onTap: () =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
  );
}

import 'package:flutter/material.dart';

import '../pages/about_policy_page.dart';
import '../pages/account_settings_page.dart';
import '../pages/downloads_page.dart';
import '../pages/feedback_page.dart';
import '../pages/help_support_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/movie_page.dart';
import '../pages/video_audio_page.dart';
import '../services/auth_service.dart';
import '../theme/netube_theme.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final email = AuthService.auth.currentUser?.email ?? 'Welcome to Netube';
    final username = email.contains('@')
        ? email.split('@').first
        : 'Movie lover';
    final menuItems = <_DrawerDestination>[
      const _DrawerDestination(
        title: 'Home',
        subtitle: 'Back to featured movies',
        icon: Icons.home_rounded,
        page: HomePage(),
        active: true,
      ),
      const _DrawerDestination(
        title: 'Account Settings',
        subtitle: 'Manage your account',
        icon: Icons.manage_accounts_outlined,
        page: AccountSettingsPage(),
      ),
      const _DrawerDestination(
        title: 'Explore Movies',
        subtitle: 'Discover something new',
        icon: Icons.explore_outlined,
        page: MoviesPage(),
      ),
      const _DrawerDestination(
        title: 'Watch History',
        subtitle: 'Continue your journey',
        icon: Icons.history_rounded,
        page: WatchHistoryPage(),
      ),
      const _DrawerDestination(
        title: 'Video & Audio',
        subtitle: 'Playback preferences',
        icon: Icons.graphic_eq_rounded,
        page: VideoAudioPage(),
      ),
      const _DrawerDestination(
        title: 'Downloads',
        subtitle: 'Your offline content',
        icon: Icons.download_outlined,
        page: DownloadsPage(),
      ),
      const _DrawerDestination(
        title: 'Help & Support',
        subtitle: 'Get assistance',
        icon: Icons.support_agent_rounded,
        page: HelpSupportPage(),
      ),
      const _DrawerDestination(
        title: 'Feedback',
        subtitle: 'Share your thoughts',
        icon: Icons.chat_bubble_outline_rounded,
        page: FeedbackPage(),
      ),
      const _DrawerDestination(
        title: 'About & Policy',
        subtitle: 'Terms and privacy',
        icon: Icons.policy_outlined,
        page: AboutPolicyPage(),
      ),
    ];

    return Drawer(
      width: MediaQuery.sizeOf(context).width * .84,
      backgroundColor: const Color(0xFF050B18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF25101A), Color(0xFF0B1424)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DrawerLogo(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF3045), Color(0xFFFF7417)],
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 29,
                          backgroundColor: NetubeColors.surfaceHigh,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/160',
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: NetubeColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'NAVIGATION',
                      style: TextStyle(
                        color: Color(0xFF717B8D),
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  ...menuItems.map(
                    (item) => _DrawerMenuItem(
                      destination: item,
                      onTap: () {
                        Navigator.pop(context);
                        if (!item.active) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => item.page),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Row(
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.redAccent,
                    size: 17,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enjoy your movies',
                      style: TextStyle(
                        color: NetubeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'v1.0.0',
                    style: TextStyle(color: Color(0xFF687284), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerDestination {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  final bool active;
  const _DrawerDestination({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
    this.active = false,
  });
}

class _DrawerMenuItem extends StatelessWidget {
  final _DrawerDestination destination;
  final VoidCallback onTap;
  const _DrawerMenuItem({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Material(
      color: destination.active ? const Color(0xFF251419) : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: destination.active
                      ? const Color(0x33FF3045)
                      : NetubeColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  destination.icon,
                  size: 20,
                  color: destination.active
                      ? Colors.redAccent
                      : const Color(0xFFC5CAD4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: destination.active
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7F899A),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (destination.active)
                Container(
                  width: 3,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF687284),
                  size: 19,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DrawerLogo extends StatelessWidget {
  const _DrawerLogo();
  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Color(0xFFFF3045), Color(0xFFFF7417)],
    ).createShader(bounds),
    child: const Text(
      'NETUBE',
      style: TextStyle(
        color: Colors.white,
        fontSize: 23,
        letterSpacing: 2.4,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

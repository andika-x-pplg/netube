import 'package:flutter/material.dart';
import '../pages/account_settings_page.dart';
import '../pages/about_policy_page.dart';
import '../pages/downloads_page.dart';
import '../pages/feedback_page.dart';
import '../pages/help_support_page.dart';
import '../pages/video_audio_page.dart';
import '../pages/history_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": "Account Settings",
        "subtitle": "Manage your account",
        "icon": Icons.settings_outlined,
        "page": const AccountSettingsPage(),
      },
      {
        "title": "Watch History",
        "subtitle": "View your history",
        "icon": Icons.history,
        "page": const WatchHistoryPage(),
      },
      {
        "title": "Video & Audio",
        "subtitle": "Playback settings",
        "icon": Icons.volume_up_outlined,
        "page": const VideoAudioPage(),
      },
      {
        "title": "Downloads",
        "subtitle": "Offline content",
        "icon": Icons.download_outlined,
        "page": const DownloadsPage(),
      },
      {
        "title": "Help & Support",
        "subtitle": "Get assistance",
        "icon": Icons.help_outline,
        "page": const HelpSupportPage(),
      },
      {
        "title": "Feedback",
        "subtitle": "Share your thoughts",
        "icon": Icons.chat_bubble_outline,
        "page": const FeedbackPage(),
      },
      {
        "title": "About & Policy",
        "subtitle": "Terms and privacy",
        "icon": Icons.info_outline,
        "page": const AboutPolicyPage(),
      },
    ];

    return Drawer(
      backgroundColor: const Color(0xFF09111F),

      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ListView(
            children: [
              // LOGO NETUBE
              ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [Colors.red, Colors.orange],
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),

                child: const Text(
                  "Netube Menu",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // MENU ITEMS
              ...menuItems.map((item) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(builder: (context) => item['page']),
                    );
                  },

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: const Color(0xFF111B2E),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        Icon(item['icon'], color: Colors.redAccent, size: 28),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(item['title']),

                              Text(item['subtitle']),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              Divider(color: Colors.white.withOpacity(0.1)),

              const SizedBox(height: 20),

              const Center(
                child: Column(
                  children: [
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "© 2026 Netube Inc.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

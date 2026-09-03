import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/shorts_page.dart';
import '../pages/upload_page.dart';
import '../pages/youtube_page.dart';
import '../theme/netube_theme.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  const BottomNavbar({super.key, this.currentIndex = -1});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, Widget)>[
      (Icons.home_rounded, 'Home', const HomePage()),
      (Icons.explore_outlined, 'Explore', const YoutubeHomePage()),
      (Icons.play_circle_outline_rounded, 'Shorts', const ShortsPage()),
      (Icons.add_box_outlined, 'Upload', const UploadPage()),
      (Icons.person_outline_rounded, 'Profile', const ProfilePage()),
    ];
    return SafeArea(
      top: false,
      child: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: Color(0xF2111111),
          border: Border(top: BorderSide(color: NetubeColors.divider)),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final active = currentIndex == index;
            return Expanded(
              child: InkWell(
                onTap: active
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => items[index].$3),
                      ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[index].$1,
                      size: 23,
                      color: active
                          ? NetubeColors.accent
                          : NetubeColors.textSecondary,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[index].$2,
                      style: TextStyle(
                        fontSize: 10,
                        color: active
                            ? Colors.white
                            : NetubeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

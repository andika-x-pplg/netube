import 'package:flutter/material.dart';
import '../pages/shorts_page.dart';
import '../pages/upload_page.dart';
import '../pages/profile_page.dart';
import '../pages/youtube_page.dart'; // Sudah ter-import dengan aman
import '../pages/home_page.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME / YOUTUBE VIDEOS
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: _buildNavItem(icon: Icons.home_outlined, label: "Home"),
          ),

          // SHORTS
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShortsPage()),
              );
            },
            child: _buildNavItem(
              icon: Icons.play_circle_outline,
              label: "Shorts",
            ),
          ),

          // ADD BUTTON
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPage()),
              );
            },
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 15),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 35),
            ),
          ),

          // YOUTUBE
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YoutubeHomePage(),
                ),
              );
            },
            child: _buildNavItem(
              icon: Icons.smart_display_outlined,
              label: "YouTube",
            ),
          ),

          // PROFILE
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: _buildNavItem(icon: Icons.person_outline, label: "Profile"),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isActive = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.redAccent : Colors.grey, size: 28),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.redAccent : Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

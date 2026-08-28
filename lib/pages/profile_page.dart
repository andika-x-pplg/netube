import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'subscriptions_page.dart';
import 'watch_later_page.dart';

import 'notifications_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // PROFILE IMAGE
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                border: Border.all(color: Colors.redAccent, width: 3),
              ),

              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
              ),
            ),

            const SizedBox(height: 20),

            // USERNAME
            Text(
              (AuthService.auth.currentUser?.email ?? "User").split('@').first,

              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // EMAIL
            Text(
              AuthService.auth.currentUser?.email ?? "No Email",

              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),

            const SizedBox(height: 20),

            // PREMIUM BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.orange],
                ),

                borderRadius: BorderRadius.circular(30),
              ),

              child: const Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(Icons.workspace_premium, color: Colors.white),

                  SizedBox(width: 8),

                  Text(
                    "Premium Member",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                _buildStatItem("120", "Movies"),

                _buildStatItem("87", "Favorites"),

                _buildStatItem("24h", "Watch Time"),
              ],
            ),

            const SizedBox(height: 40),

            // MENU ITEMS
            _buildMenuItem(Icons.person_outline, "Edit Profile"),

            _buildMenuItem(
              Icons.subscriptions,
              "Subscriptions",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionsPage()),
                );
              },
            ),

            _buildMenuItem(
              Icons.watch_later_outlined,
              "Watch Later",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WatchLaterPage()),
                );
              },
            ),

            _buildMenuItem(Icons.lock_outline, "Privacy Settings"),

            _buildMenuItem(
              Icons.notifications_outlined,
              "Notifications",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),

            _buildMenuItem(Icons.help_outline, "Help Center"),

            const SizedBox(height: 30),

            // LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                onPressed: () async {
                  await AuthService.logout();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },

                child: const Text(
                  "Logout",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(label, style: TextStyle(color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            Icon(icon, color: Colors.redAccent),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

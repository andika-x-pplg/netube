import 'package:flutter/material.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "Account Settings",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            _buildSettingItem(
              Icons.person_outline,
              "Edit Profile",
            ),

            _buildSettingItem(
              Icons.lock_outline,
              "Change Password",
            ),

            _buildSettingItem(
              Icons.email_outlined,
              "Email Settings",
            ),

            _buildSettingItem(
              Icons.security,
              "Privacy & Security",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
  ) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          // ICON
          Icon(
            icon,
            color: Colors.redAccent,
          ),

          const SizedBox(width: 16),

          // TITLE
          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),

          // ARROW
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }
}
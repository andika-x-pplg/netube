import 'package:flutter/material.dart';

class AboutPolicyPage extends StatelessWidget {
  const AboutPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "About & Policy",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // APP NAME
            const Text(
              "Netube",

              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ABOUT
            Text(
              "Netube is a modern streaming application inspired by YouTube and Netflix. Users can watch movies, videos, and entertainment content in one platform.",

              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 16,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 35),

            // PRIVACY POLICY
            const Text(
              "Privacy Policy",

              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Your personal data is protected and securely stored. Netube will never share your information without your permission.",

              style: TextStyle(
                color: Colors.grey.shade300,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 35),

            // TERMS
            const Text(
              "Terms & Conditions",

              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "By using Netube, users agree to follow all platform rules and community guidelines.",

              style: TextStyle(
                color: Colors.grey.shade300,
                height: 1.7,
              ),
            ),

            const Spacer(),

            // VERSION
            Center(
              child: Column(
                children: [

                  Text(
                    "Version 1.0.0",

                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "© 2026 Netube Inc.",

                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
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
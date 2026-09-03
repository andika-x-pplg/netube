import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import '../theme/netube_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetubeColors.background,

      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            const Text(
              "Create Account",

              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Your next story starts here.",

              style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
            ),

            const SizedBox(height: 40),

            _buildTextField(
              controller: usernameController,
              hint: "Username",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: emailController,
              hint: "Email",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: passwordController,
              hint: "Password",
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: () async {
                  try {
                    await AuthService.register(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Register berhasil")),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },

                child: const Text(
                  "Register",

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.grey.shade500),

        prefixIcon: Icon(icon, color: Colors.grey),

        filled: true,
        fillColor: NetubeColors.surfaceHigh,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

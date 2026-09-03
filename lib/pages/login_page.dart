import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _showLoginForm = false;
  bool _obscurePassword = true;
  bool _isSigningIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Existing Firebase password-reset flow is intentionally preserved.
  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukan email terlebih dahulu')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email reset password telah dikirim. Silahkan cek email kamu.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Gagal mengirim email reset password.'),
        ),
      );
    }
  }

  Future<void> _login() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    try {
      await AuthService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _showLoginForm ? _buildLoginForm() : _buildWelcome(),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return LayoutBuilder(
      key: const ValueKey('cinematic-welcome'),
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 680;
        final collageHeight = (constraints.maxHeight * (compact ? .49 : .57))
            .clamp(310.0, 520.0);

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                SizedBox(
                  height: collageHeight,
                  child: const Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: MoviePosterCollage(),
                      ),
                      _CollageGradient(),
                      Positioned(top: 18, left: 22, child: _NetubeLogo()),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Text(
                          'Unlimited Movies.\nOne Place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            height: 1.08,
                            letterSpacing: -.7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Discover movies, watch trailers, save favorites, and join the community.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9CA6B8),
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: compact ? 20 : 28),
                        _GradientButton(
                          label: 'Enter Netube',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () =>
                              setState(() => _showLoginForm = true),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return LayoutBuilder(
      key: const ValueKey('login-form'),
      builder: (context, constraints) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _showLoginForm = false);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 26),
                const Center(child: _NetubeLogo()),
                const Spacer(),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    letterSpacing: -.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Sign in to continue to Netube',
                  style: TextStyle(color: Color(0xFF9CA6B8), fontSize: 15),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: emailController,
                  hint: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resetPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _GradientButton(
                  label: _isSigningIn ? 'Signing in...' : 'Login',
                  onPressed: _isSigningIn ? null : _login,
                  loading: _isSigningIn,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: Text(
                        "Don't have an account?",
                        style: TextStyle(color: Color(0xFF9CA6B8)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
      onSubmitted: isPassword ? (_) => _login() : null,
      obscureText: isPassword && _obscurePassword,
      autocorrect: false,
      enableSuggestions: !isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7F899B)),
        prefixIcon: Icon(icon, color: const Color(0xFF929CAE), size: 21),
        suffixIcon: isPassword
            ? IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF929CAE),
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF111827),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF1B2638)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    );
  }
}

class MoviePosterCollage extends StatelessWidget {
  const MoviePosterCollage({super.key});

  static const _posters = [
    '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    '/q719jXXEzOoYaps6babgKnONONX.jpg',
    '/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
    '/8UlWHLMpgZm9bx6QYh0NFoq67TZ.jpg',
    '/6oom5QYQ2yQTMJIbnvbkBL9cHo6.jpg',
    '/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnimatedPosterColumn(
            paths: [_posters[0], _posters[3], _posters[5], _posters[1]],
            duration: Duration(seconds: 25),
            startPhase: .12,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _AnimatedPosterColumn(
            paths: [_posters[2], _posters[5], _posters[1], _posters[4]],
            duration: Duration(seconds: 29),
            scrollUp: false,
            startPhase: .38,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _AnimatedPosterColumn(
            paths: [_posters[4], _posters[0], _posters[2], _posters[3]],
            duration: Duration(seconds: 27),
            startPhase: .62,
          ),
        ),
      ],
    );
  }
}

class _AnimatedPosterColumn extends StatefulWidget {
  final List<String> paths;
  final Duration duration;
  final bool scrollUp;
  final double startPhase;

  const _AnimatedPosterColumn({
    required this.paths,
    required this.duration,
    required this.startPhase,
    this.scrollUp = true,
  });

  @override
  State<_AnimatedPosterColumn> createState() => _AnimatedPosterColumnState();
}

class _AnimatedPosterColumnState extends State<_AnimatedPosterColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..value = widget.startPhase
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 7.0;
        final posterHeight = constraints.maxWidth * 1.48;
        final sequenceHeight = (posterHeight + gap) * widget.paths.length;

        Widget sequence(int copy) => Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.paths.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: gap),
              child: SizedBox(
                height: posterHeight,
                width: double.infinity,
                child: _PosterTile(
                  path: widget.paths[index],
                  index: index + copy * widget.paths.length,
                ),
              ),
            );
          }),
        );

        return ClipRect(
          child: RepaintBoundary(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: constraints.maxWidth,
              maxWidth: constraints.maxWidth,
              minHeight: sequenceHeight * 2,
              maxHeight: sequenceHeight * 2,
              child: AnimatedBuilder(
                animation: _controller,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [sequence(0), sequence(1)],
                ),
                builder: (context, child) {
                  final progress = _controller.value;
                  final offset = widget.scrollUp
                      ? -sequenceHeight * progress
                      : -sequenceHeight + sequenceHeight * progress;
                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PosterTile extends StatelessWidget {
  final String path;
  final int index;
  const _PosterTile({required this.path, required this.index});

  @override
  Widget build(BuildContext context) {
    final rotation = index.isEven ? -.012 : .012;
    final scale = index % 3 == 0 ? .985 : 1.0;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, .0008)
      ..rotateY(rotation)
      ..scaleByDouble(scale, scale, 1, 1);

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          'https://image.tmdb.org/t/p/w342$path',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: index.isEven
                    ? const [Color(0xFF4A1119), Color(0xFF111827)]
                    : const [Color(0xFF18213A), Color(0xFF400A15)],
              ),
            ),
            child: const Center(
              child: Icon(Icons.movie_outlined, color: Colors.white24),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollageGradient extends StatelessWidget {
  const _CollageGradient();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x33050B18),
          Colors.transparent,
          Color(0x55050B18),
          Color(0xFF050B18),
        ],
        stops: [0, .44, .72, 1],
      ),
    ),
  );
}

class _NetubeLogo extends StatelessWidget {
  const _NetubeLogo();

  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Color(0xFFFF3545), Color(0xFFFF7A18)],
    ).createShader(bounds),
    child: const Text(
      'NETUBE',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        letterSpacing: 2.2,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 57,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE50935), Color(0xFFFF6A1A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44E50935),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.white, size: 20),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:lost_and_found/utils/app_routes.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo image with text fallback ──────────────────────
                Image.asset(
                  AppConstants.splashLogoPath,
                  width: 300,
                  errorBuilder: (_, __, ___) => const _SplashTextLogo(),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback logo rendered entirely from widgets when
/// splash_screen_logo.png is not yet in assets.
class _SplashTextLogo extends StatelessWidget {
  const _SplashTextLogo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'lost &',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
            height: 1.05,
          ),
        ),
        Text(
          'found',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
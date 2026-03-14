import 'package:flutter/material.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:lost_and_found/utils/app_routes.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/widgets/app_logo_header.dart';
import 'package:lost_and_found/widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _auth = AuthService();

  // Email passed from ForgotPasswordScreen via route arguments
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) _email = arg;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _backToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // ── Success Icon ────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.successGreen.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 32),

              // ── Title ────────────────────────────────────────────────
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────
              Text(
                _email.isNotEmpty
                    ? 'We\'ve sent a password recovery link to:\n\n$_email\n\nPlease check your email to proceed with resetting your password.'
                    : 'We\'ve sent a password recovery link to your registered email.\n\nPlease check your email to proceed with resetting your password.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ── Back to Login button ──────────────────────────────────
              PrimaryButton(
                label: 'Back to Login',
                onPressed: _backToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
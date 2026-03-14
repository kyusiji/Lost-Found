import 'package:flutter/material.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:lost_and_found/utils/app_routes.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/utils/validators.dart';
import 'package:lost_and_found/widgets/app_logo_header.dart';
import 'package:lost_and_found/widgets/auth_text_field.dart';
import 'package:lost_and_found/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _auth = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordReset(_emailCtrl.text.trim());
      if (mounted) {
        // Navigate to reset screen, passing the email so it can be displayed
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resetPassword,
          arguments: _emailCtrl.text.trim(),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: AppTheme.errorRed,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ────────────────────────────────────────────────
                const Center(child: AppLogoHeader()),
                const SizedBox(height: 32),

                // ── Title ────────────────────────────────────────────────
                const Text(
                  'Forgot Your Password?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your valid email address to receive a password recovery link.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Email field ───────────────────────────────────────────
                AuthTextField(
                  controller: _emailCtrl,
                  label: 'NCST Email Account / Student Number',
                  hintText: 'student@ncst.edu.ph or 2021-00001',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    // Allow either email format or student number format
                    if (!value.contains('@') &&
                        !RegExp(r'^\d{4}-\d{5}$').hasMatch(value)) {
                      return 'Enter a valid email or student number (e.g. 2021-00001)';
                    }
                    if (value.contains('@')) {
                      final emailError = Validators.validateEmail(value);
                      if (emailError != null) return emailError;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendCode(),
                ),
                const SizedBox(height: 12),

                // ── Back to login link ────────────────────────────────────
                GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppTheme.linkColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.linkColor,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Send Code button ──────────────────────────────────────
                PrimaryButton(
                  label: 'Send Recovery Link',
                  isLoading: _isLoading,
                  onPressed: _sendCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

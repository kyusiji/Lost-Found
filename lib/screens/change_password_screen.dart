import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/utils/validators.dart';
import 'package:lost_and_found/widgets/auth_text_field.dart';
import 'package:lost_and_found/widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  UserModel? _user;
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is UserModel && _user == null) {
      _user = arg;
    }
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: Re-authenticate with current password, then:
    //   await FirebaseAuth.instance.currentUser!.updatePassword(_newPasswordCtrl.text);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your new password must be different from previous passwords.',
                style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
              ),
              const SizedBox(height: 20),

              // Current password
              AuthTextField(
                controller: _currentPasswordCtrl,
                label: 'Current Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textGrey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),

              // New password
              AuthTextField(
                controller: _newPasswordCtrl,
                label: 'New Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textGrey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),

              // Confirm new password
              AuthTextField(
                controller: _confirmPasswordCtrl,
                label: 'Confirm New Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textGrey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) => Validators.validateConfirmPassword(
                    v, _newPasswordCtrl.text),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Change Password',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
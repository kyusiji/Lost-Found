import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/utils/app_routes.dart';

class ProfileManagementScreen extends StatelessWidget {
  final UserModel? user;
  const ProfileManagementScreen({super.key, this.user});

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
          'Profile Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppTheme.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage details that make Lost & Found work better for you.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Profile Picture (editable) ─────────────────────────────
            _ProfileOption(
              icon: Icons.account_circle_outlined,
              label: 'Profile Picture',
              subtitle: null,
              showAvatar: true,
              user: user,
              isEditable: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editProfilePicture,
                  arguments: user,
                );
              },
            ),

            // ── Name (read-only) ───────────────────────────────────────
            _ProfileOption(
              icon: Icons.badge_outlined,
              label: 'Name',
              subtitle: user?.fullName ?? '[Full Name]',
              isEditable: false,
            ),

            // ── Student Number (read-only) ─────────────────────────────
            _ProfileOption(
              icon: Icons.numbers_outlined,
              label: 'Student Number',
              subtitle: user?.studentNumber ?? '[2024-12345]',
              isEditable: false,
            ),

            // ── NCST Email (read-only) ─────────────────────────────────
            _ProfileOption(
              icon: Icons.email_outlined,
              label: 'NCST Email Account',
              subtitle: user?.ncstEmail ?? '[asd@ncst.edu.ph]',
              isEditable: false,
            ),

            const SizedBox(height: 8),

            // ── Change Password (editable) ─────────────────────────────
            _ProfileOption(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              subtitle: null,
              isEditable: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.changePassword,
                  arguments: user,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PROFILE OPTION TILE
// ════════════════════════════════════════════════════════════════════════════

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool showAvatar;
  final UserModel? user;
  final bool isEditable;
  final VoidCallback? onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.isEditable,
    this.subtitle,
    this.showAvatar = false,
    this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppTheme.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEditable ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isEditable
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : AppTheme.textGrey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isEditable
                        ? AppTheme.primaryBlue
                        : AppTheme.textGrey.withOpacity(0.6),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isEditable
                                  ? AppTheme.textDark
                                  : AppTheme.textGrey.withOpacity(0.7),
                            ),
                          ),
                          if (!isEditable) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: AppTheme.textGrey.withOpacity(0.5),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Right side: avatar or chevron or nothing
                if (showAvatar)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppTheme.primaryBlue,
                      size: 22,
                    ),
                  )
                else if (isEditable)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textGrey.withOpacity(0.5),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
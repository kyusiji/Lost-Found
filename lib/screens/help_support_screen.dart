import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  final UserModel? user;
  const HelpSupportScreen({super.key, this.user});

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
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Campus Policy Section ──────────────────────────────────
            _SectionHeader(title: 'Campus Policy'),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.location_on_outlined,
              title: 'Location Map',
              content:
                  'Physical Lost & Found office is at Room 1109 , 3175 Emilio Aguinaldo Hwy, Salitran, Dasmariñas, Cavite, Philippines.',
            ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.access_time_rounded,
              title: 'Operating Hours',
              content:
                  'You can pick up or surrender the items from 9am - 5pm every Monday-Saturday',
            ),
            const SizedBox(height: 24),

            // ── Terms of Use Section ───────────────────────────────────
            _SectionHeader(title: 'Terms of Use'),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.gavel_rounded,
              title: 'Ethics Guide',
              content:
                  'To maintain a safe community, students must provide honest information and only claim items they truly own. Any attempt to submit false reports or fraudulent claims is a direct violation of the NCST Student Code of Conduct. Such actions will result in an immediate app ban and a formal referral to the Student Affairs Office for disciplinary action.',
            ),
            const SizedBox(height: 24),

            // ── Additional Support Links ───────────────────────────────
            _SectionHeader(title: 'Need More Help?'),
            const SizedBox(height: 12),

            _ActionTile(
              icon: Icons.email_outlined,
              title: 'Contact Support',
              subtitle: 'lostandfound@ncst.edu.ph',
              onTap: () {
                // TODO: Open email app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email app...')),
                );
              },
            ),
            const SizedBox(height: 8),

            _ActionTile(
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '(046) 123-4567',
              onTap: () {
                // TODO: Open phone dialer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening phone dialer...')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// INFO CARD
// ════════════════════════════════════════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textGrey.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ACTION TILE
// ════════════════════════════════════════════════════════════════════════════

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textGrey.withOpacity(0.8),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textGrey.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}
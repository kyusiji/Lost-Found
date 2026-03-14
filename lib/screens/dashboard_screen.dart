import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/screens/notification_preview.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:lost_and_found/utils/app_routes.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/utils/constants.dart';
import 'package:lost_and_found/screens/admin_logs_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel? user;
  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();

  // Which sidebar item is active
  _SidebarItem _activeItem = _SidebarItem.dashboard;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Logout ──────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    // Close the drawer first
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService().signOut();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _onSidebarTap(_SidebarItem item) {
    Navigator.pop(context); // close drawer
    setState(() => _activeItem = item);

    switch (item) {
      case _SidebarItem.search:
        Navigator.pushNamed(context, AppRoutes.searchBrowse,
            arguments: widget.user);
        break;
      case _SidebarItem.report:
        Navigator.pushNamed(context, AppRoutes.reportItem,
            arguments: widget.user);
        break;
      case _SidebarItem.trackMyReport:
        Navigator.pushNamed(context, AppRoutes.trackMyReport,
            arguments: widget.user);
        break;
      case _SidebarItem.helpSupport:
        Navigator.pushNamed(context, AppRoutes.helpSupport,
            arguments: widget.user);
        break;
      case _SidebarItem.adminLogs:
        Navigator.pushNamed(
          context,
          AppRoutes.adminLogs,
          arguments: widget.user, // Keeps the user data consistent
        );
        break;

      default:
        // Dashboard stays on dashboard
        break;
    }
  }

  void _onDashboardCardTap(_SidebarItem item) {
    setState(() => _activeItem = item);

    switch (item) {
      case _SidebarItem.search:
        Navigator.pushNamed(context, AppRoutes.searchBrowse,
            arguments: widget.user);
        break;
      case _SidebarItem.report:
        Navigator.pushNamed(context, AppRoutes.reportItem,
            arguments: widget.user);
        break;
      case _SidebarItem.trackMyReport:
        Navigator.pushNamed(context, AppRoutes.trackMyReport,
            arguments: widget.user);
        break;
      default:
        break;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bgLight,
      drawer: _Sidebar(
        user: widget.user,
        activeItem: _activeItem,
        onItemTap: _onSidebarTap,
        onLogout: _logout,
      ),
      appBar: _DashboardAppBar(
        scaffoldKey: _scaffoldKey,
        user: widget.user,
      ),
      body: _DashboardBody(
        user: widget.user,
        searchCtrl: _searchCtrl,
        onCardTap: _onDashboardCardTap,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// APP BAR
// ════════════════════════════════════════════════════════════════════════════

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final UserModel? user;

  const _DashboardAppBar({required this.scaffoldKey, this.user});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryBlue,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          Image.asset(
            AppConstants.lfNcstLogoPath,
            height: 34,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        // Profile icon
        IconButton(
          icon: const Icon(Icons.person_outline_rounded,
              color: Colors.white, size: 26),
          tooltip: 'Profile',
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.profileManagement,
              arguments: user,
            );
          },
        ),
        // Notification bell with preview
        const NotificationPreview(
          notificationCount: 0, // TODO: Replace with actual count from Firebase
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SIDEBAR DRAWER
// ════════════════════════════════════════════════════════════════════════════

enum _SidebarItem {
  dashboard,
  search,
  report,
  trackMyReport,
  helpSupport,
  adminLogs
}

class _Sidebar extends StatelessWidget {
  final UserModel? user;
  final _SidebarItem activeItem;
  final void Function(_SidebarItem) onItemTap;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.user,
    required this.activeItem,
    required this.onItemTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.primaryBlue,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  Image.asset(
                    AppConstants.lfNcstLogoPath,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),

            // ── Nav items ──────────────────────────────────────────────
            _SidebarTile(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              isActive: activeItem == _SidebarItem.dashboard,
              onTap: () => onItemTap(_SidebarItem.dashboard),
            ),
            _SidebarTile(
              icon: Icons.search_rounded,
              label: 'Search/Browse',
              isActive: activeItem == _SidebarItem.search,
              onTap: () => onItemTap(_SidebarItem.search),
              subtitle: 'I Lost Something',
            ),
            _SidebarTile(
              icon: Icons.add_box_outlined,
              label: 'Report',
              isActive: activeItem == _SidebarItem.report,
              onTap: () => onItemTap(_SidebarItem.report),
              subtitle: 'I Found Something/',
            ),
            _SidebarTile(
              icon: Icons.track_changes_rounded,
              label: 'Track My Report',
              isActive: activeItem == _SidebarItem.trackMyReport,
              onTap: () => onItemTap(_SidebarItem.trackMyReport),
              subtitle: 'History',
            ),
            _SidebarTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              isActive: activeItem == _SidebarItem.helpSupport,
              onTap: () => onItemTap(_SidebarItem.helpSupport),
            ),

            if (user?.isAdmin ?? false) ...[
              const Divider(color: Colors.white24, height: 20),
              _SidebarTile(
                icon: Icons.receipt_long_rounded,
                label: 'Transaction Logs',
                isActive: activeItem == _SidebarItem.adminLogs,
                onTap: () => onItemTap(_SidebarItem.adminLogs),
                subtitle: 'Admin: Proof of Receipt',
              ),
            ],

            const Spacer(),
            const Divider(color: Colors.white24, height: 1),

            // ── Logout ─────────────────────────────────────────────────
            _SidebarTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              isActive: false,
              onTap: onLogout,
              isDestructive: true,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.red[200]!
        : isActive
            ? Colors.white
            : Colors.white70;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive ? Colors.white.withOpacity(0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: color.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                    ],
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

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD BODY
// ════════════════════════════════════════════════════════════════════════════

class _DashboardBody extends StatelessWidget {
  final UserModel? user;
  final TextEditingController searchCtrl;
  final void Function(_SidebarItem) onCardTap;

  const _DashboardBody({
    required this.user,
    required this.searchCtrl,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ────────────────────────────────────────────────────
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quick Search Bar',
            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 10),

          // ── Search bar ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor, width: 1.5),
              ),
              child: TextField(
                controller: searchCtrl,
                style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: 'What are you looking for?',
                  hintStyle:
                      const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.primaryBlue, size: 22),
                  filled: true,
                  fillColor: AppTheme.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Greeting ─────────────────────────────────────────────────
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
              children: [
                const TextSpan(text: 'Hi, '),
                TextSpan(
                  text: '[${user?.firstName ?? 'Student'}]',
                  style: const TextStyle(color: AppTheme.primaryBlue),
                ),
                const TextSpan(text: '!'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Action cards ─────────────────────────────────────────────
          _DashboardCard(
            label: 'Items That are Lost/Found',
            borderColor: AppTheme.errorRed,
            textColor: AppTheme.errorRed,
            icon: Icons.search_rounded,
            onTap: () => onCardTap(_SidebarItem.search),
          ),
          const SizedBox(height: 14),

          _DashboardCard(
            label: 'I Found/Lost Something',
            borderColor: AppTheme.accentGreen,
            textColor: AppTheme.accentGreen,
            icon: Icons.add_box_outlined,
            onTap: () => onCardTap(_SidebarItem.report),
          ),
          const SizedBox(height: 14),

          _DashboardCard(
            label: 'History of My Reports',
            borderColor: const Color(0xFFE67E22),
            textColor: const Color(0xFFE67E22),
            icon: Icons.track_changes_rounded,
            onTap: () => onCardTap(_SidebarItem.trackMyReport),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD CARD
// ════════════════════════════════════════════════════════════════════════════

class _DashboardCard extends StatelessWidget {
  final String label;
  final Color borderColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.label,
    required this.borderColor,
    required this.textColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: borderColor, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: borderColor.withOpacity(0.5), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

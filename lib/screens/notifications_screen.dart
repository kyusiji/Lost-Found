import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  final UserModel? user;
  const NotificationsScreen({super.key, this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock data - replace with Firebase query
  final List<_NotificationItem> _notifications = [];

  Future<void> _deleteNotification(int index) async {
    setState(() {
      _notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Clear All Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _notifications.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNotifications = _notifications.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: hasNotifications
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                  tooltip: 'Clear All',
                  onPressed: _clearAll,
                ),
              ]
            : null,
      ),
      body: hasNotifications
          ? Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: AppTheme.white,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Notifications',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) => _NotificationTile(
                      notification: _notifications[index],
                      onDelete: () => _deleteNotification(index),
                    ),
                  ),
                ),
              ],
            )
          : const _EmptyNotificationsState(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// NOTIFICATION TILE
// ════════════════════════════════════════════════════════════════════════════

class _NotificationTile extends StatelessWidget {
  final _NotificationItem notification;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_rounded,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGrey.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              notification.timestamp,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textGrey.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.errorRed.withOpacity(0.8),
            size: 22,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ════════════════════════════════════════════════════════════════════════════

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bell icon with ringing animation effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Left wave
                Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: AppTheme.textGrey.withOpacity(0.2),
                  ),
                ),
                // Center bell
                Icon(
                  Icons.notifications_none_rounded,
                  size: 80,
                  color: AppTheme.textGrey.withOpacity(0.4),
                ),
                // Right wave
                Transform.rotate(
                  angle: 0.3,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: AppTheme.textGrey.withOpacity(0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notification inbox empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ════════════════════════════════════════════════════════════════════════════

class _NotificationItem {
  final String title;
  final String message;
  final String timestamp;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
  });
}
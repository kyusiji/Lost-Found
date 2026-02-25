import 'package:flutter/material.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/utils/app_routes.dart';

/// Notification preview widget shown in dashboard/app bar
class NotificationPreview extends StatelessWidget {
  final int notificationCount;

  const NotificationPreview({
    super.key,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded,
              color: Colors.white, size: 26),
          if (notificationCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.errorRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) {
        if (notificationCount == 0) {
          // Empty state in popup
          return [
            PopupMenuItem<String>(
              enabled: false,
              child: SizedBox(
                width: 280,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: -0.3,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 60,
                            color: AppTheme.textGrey.withOpacity(0.2),
                          ),
                        ),
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 60,
                          color: AppTheme.textGrey.withOpacity(0.4),
                        ),
                        Transform.rotate(
                          angle: 0.3,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 60,
                            color: AppTheme.textGrey.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Notification inbox empty',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'view_all',
              child: Center(
                child: Text(
                  'View All Notification',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ];
        }

        // Show recent notifications (max 3)
        final recentNotifications = _getMockNotifications().take(3).toList();

        return [
          ...recentNotifications.map((notif) => PopupMenuItem<String>(
                enabled: false,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['title']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              notif['time']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textGrey.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'view_all',
            child: Center(
              child: Text(
                'View All Notification',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ];
      },
      onSelected: (value) {
        if (value == 'view_all') {
          Navigator.pushNamed(context, AppRoutes.notifications);
        }
      },
    );
  }

  // Mock notifications for preview
  List<Map<String, String>> _getMockNotifications() {
    return [
      {
        'title': 'ROLENNE MAY JASPE claimed your found item',
        'time': '02-15 At 03:15 PM',
      },
      {
        'title': 'ROLENNE MAY JASPE found your lost item',
        'time': '02-15 At 03:15 PM',
      },
      {
        'title': 'ROLENNE MAY JASPE claimed your found item',
        'time': '02-15 At 03:15 PM',
      },
    ];
  }
}
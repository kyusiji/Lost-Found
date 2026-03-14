import 'package:flutter/material.dart';
import 'package:lost_and_found/screens/splash_screen.dart';
import 'package:lost_and_found/screens/login_screen.dart';
import 'package:lost_and_found/screens/register_screen.dart';
import 'package:lost_and_found/screens/dashboard_screen.dart';
import 'package:lost_and_found/screens/forgot_password_screen.dart';
import 'package:lost_and_found/screens/reset_password_screen.dart';
import 'package:lost_and_found/screens/profile_management_screen.dart';
import 'package:lost_and_found/screens/edit_profile_picture_screen.dart';
import 'package:lost_and_found/screens/change_password_screen.dart';
import 'package:lost_and_found/screens/search_browse_screen.dart';
import 'package:lost_and_found/screens/report_item_screen.dart';
import 'package:lost_and_found/screens/track_my_report_screen.dart';
import 'package:lost_and_found/screens/help_support_screen.dart';
import 'package:lost_and_found/screens/notifications_screen.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/screens/admin_logs_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profileManagement = '/profile-management';
  static const String editProfilePicture = '/edit-profile-picture';
  static const String changePassword = '/change-password';
  static const String searchBrowse = '/search-browse';
  static const String reportItem = '/report-item';
  static const String trackMyReport = '/track-my-report';
  static const String helpSupport = '/help-support';
  static const String notifications = '/notifications';
  static const String adminLogs = '/admin-logs';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen());

      case login:
        return _fade(const LoginScreen());

      case register:
        return _fade(const RegisterScreen());

      case dashboard:
        final user = settings.arguments as UserModel?;
        return _fade(DashboardScreen(user: user));

      case forgotPassword:
        return _fade(const ForgotPasswordScreen());

      case resetPassword:
        return _fade(const ResetPasswordScreen());

      case profileManagement:
        final user = settings.arguments as UserModel?;
        return _fade(ProfileManagementScreen(user: user));

      case editProfilePicture:
        return _fade(const EditProfilePictureScreen());

      case changePassword:
        return _fade(const ChangePasswordScreen());

      case searchBrowse:
        final user = settings.arguments as UserModel?;
        return _fade(SearchBrowseScreen(user: user));

      case reportItem:
        final user = settings.arguments as UserModel?;
        return _fade(ReportItemScreen(user: user));

      case trackMyReport:
        final user = settings.arguments as UserModel?;
        return _fade(TrackMyReportScreen(user: user));

      case helpSupport:
        final user = settings.arguments as UserModel?;
        return _fade(HelpSupportScreen(user: user));

      case notifications:
        final user = settings.arguments as UserModel?;
        return _fade(NotificationsScreen(user: user));

      case adminLogs:
        // Explicitly cast the argument to UserModel?
        final user = settings.arguments is UserModel
            ? settings.arguments as UserModel
            : null;
        return _fade(AdminLogsScreen(user: user));

      default:
        return _fade(Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ));
    }
  }

  static PageRouteBuilder _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

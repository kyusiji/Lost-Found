import 'package:lost_and_found/utils/constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.emptyFieldError;
    }
    // Accept either NCST email or student number format
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final studentNumRegex = RegExp(r'^\d{4}-\d{5}$');

    if (!emailRegex.hasMatch(value.trim()) &&
        !studentNumRegex.hasMatch(value.trim())) {
      return 'Enter a valid NCST email or student number';
    }
    return null;
  }

  static String? validateNcstEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.emptyFieldError;
    }
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppConstants.invalidEmailError;
    }
    return null;
  }

  static String? validateStudentNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Student number is required';
    if (!RegExp(r'^\d{4}-\d{5}$').hasMatch(value.trim())) {
      return 'Format: YYYY-NNNNN  e.g. 2021-00001';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Item validators
  static String? validateItemTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Item title is required';
    if (value.trim().length < 3) return 'Title must be at least 3 characters';
    if (value.trim().length > 100) return 'Title must be less than 100 characters';
    return null;
  }

  static String? validateItemDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Description is required';
    if (value.trim().length < 10) return 'Description must be at least 10 characters';
    if (value.trim().length > 500) return 'Description must be less than 500 characters';
    return null;
  }

  static String? validateItemLocation(String? value) {
    if (value == null || value.trim().isEmpty) return 'Location is required';
    if (value.trim().length < 3) return 'Location must be at least 3 characters';
    return null;
  }

  static String? validateItemDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Date is required';
    // Basic validation - just check if it's not empty and matches MM/dd/yyyy format
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value.trim())) {
      return 'Date format must be MM/dd/yyyy';
    }
    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) return 'Message cannot be empty';
    if (value.trim().length < 1) return 'Message is too short';
    if (value.trim().length > 1000) return 'Message must be less than 1000 characters';
    return null;
  }
}
import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Gym Manager';

  // Colors - Dark Theme with Blue Accent
  static const Color primaryColor = Color(0xFF1E90FF); // Dodger Blue
  static const Color backgroundColor = Color(0xFF1A1F2E); // Dark Blue Gray
  static const Color surfaceColor = Color(0xFF252B3B); // Lighter Dark
  static const Color cardColor = Color(0xFF2A3142);
  static const Color borderColor = Color(0xFF3A4152);
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B3B8);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color successColor = Color(0xFF4CAF50);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeHeading = 28.0;

  // Button Heights
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;

  // Input Field Heights
  static const double inputHeight = 56.0;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Validation
  static const int minPasswordLength = 8;
  static const int otpLength = 6;

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyIsLoggedIn = 'is_logged_in';
}

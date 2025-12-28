import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'utils/constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Dark theme configuration
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        primaryColor: AppConstants.primaryColor,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.primaryColor,
          surface: AppConstants.surfaceColor,
          background: AppConstants.backgroundColor,
          error: AppConstants.errorColor,
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppConstants.textPrimaryColor),
          titleTextStyle: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Text theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeHeading,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeXXLarge,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeLarge,
          ),
          bodyMedium: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: AppConstants.fontSizeMedium,
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            borderSide: const BorderSide(color: AppConstants.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            borderSide: const BorderSide(color: AppConstants.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            borderSide: const BorderSide(
              color: AppConstants.primaryColor,
              width: 2,
            ),
          ),
        ),

        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.textPrimaryColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
          ),
        ),

        // Card theme
        cardTheme: CardThemeData(
          color: AppConstants.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
        ),
      ),

      // Initial route
      initialRoute: '/login',

      // Routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

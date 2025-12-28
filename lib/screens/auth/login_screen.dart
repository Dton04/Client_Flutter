import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  void _handleGoogleLogin() {
    // TODO: Implement Google login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google login chưa được triển khai'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  void _handleAppleLogin() {
    // TODO: Implement Apple login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple login chưa được triển khai'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Đang đăng nhập...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.paddingXLarge),

                  // App Icon/Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge,
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Title
                  const Center(
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeHeading,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Subtitle
                  const Center(
                    child: Text(
                      'Chào mừng trở lại!',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeXLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Tiếp tục hành trình chính phục bản thân.',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hintText: 'nguoidung@email.com',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Password field
                  CustomTextField(
                    label: 'Mật khẩu',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    validator: Validators.validatePassword,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: AppConstants.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Login button
                  CustomButton(
                    text: 'Đăng nhập',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Divider with text
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppConstants.borderColor,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                        ),
                        child: Text(
                          'Hoặc tiếp tục với',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: AppConstants.fontSizeSmall,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppConstants.borderColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Social login buttons
                  Row(
                    children: [
                      Expanded(
                        child: SocialLoginButton(
                          text: 'Google',
                          iconAsset: 'google',
                          onPressed: _handleGoogleLogin,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Expanded(
                        child: SocialLoginButton(
                          text: 'Apple',
                          iconAsset: 'apple',
                          onPressed: _handleAppleLogin,
                          isApple: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Sign up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToRegister,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: AppConstants.fontSizeMedium,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}

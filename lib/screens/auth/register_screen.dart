import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản dịch vụ'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        // Navigate back to login
        Navigator.pop(context);
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

  void _navigateToLogin() {
    Navigator.pop(context);
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
        message: 'Đang tạo tài khoản...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppConstants.textPrimaryColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Title
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: AppConstants.textPrimaryColor,
                      fontSize: AppConstants.fontSizeHeading,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Subtitle
                  const Text(
                    'Let\'s Get Started',
                    style: TextStyle(
                      color: AppConstants.textPrimaryColor,
                      fontSize: AppConstants.fontSizeXLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Track your workouts and crush your goals.',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: AppConstants.fontSizeMedium,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Full Name field
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    controller: _fullNameController,
                    validator: Validators.validateFullName,
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Email field
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'example@email.com',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Create a strong password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    validator: Validators.validatePassword,
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Terms checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                          activeColor: AppConstants.primaryColor,
                          side: const BorderSide(
                            color: AppConstants.borderColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: AppConstants.textSecondaryColor,
                              fontSize: AppConstants.fontSizeSmall,
                            ),
                            children: [
                              TextSpan(
                                text: 'By signing up, you agree to the ',
                              ),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Register button
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _handleRegister,
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
                          'Or continue with',
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

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already a member? ',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign In',
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

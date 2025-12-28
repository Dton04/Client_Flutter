import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.forgotPassword(email: _emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã OTP đã được gửi đến email của bạn'),
            backgroundColor: AppConstants.successColor,
          ),
        );

        // Navigate to reset password screen
        Navigator.pushNamed(
          context,
          '/reset-password',
          arguments: _emailController.text.trim(),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Đang gửi mã OTP...',
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

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Title
                  const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: AppConstants.textPrimaryColor,
                      fontSize: AppConstants.fontSizeHeading,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Instructions
                  const Text(
                    'Đừng lo lắng. Hãy nhập email đăng ký của bạn, chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: AppConstants.fontSizeMedium,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hintText: 'nhapemail@cuaban.com',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge * 2),

                  // Send OTP button
                  CustomButton(
                    text: 'Gửi mã OTP',
                    onPressed: _handleSendOTP,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Nhớ mật khẩu? ',
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
                            'Đăng nhập',
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

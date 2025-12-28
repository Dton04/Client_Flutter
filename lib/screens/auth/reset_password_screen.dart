import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get email from navigation arguments
    if (_email == null) {
      _email = ModalRoute.of(context)?.settings.arguments as String?;
      if (_email != null) {
        _emailController.text = _email!;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.resetPassword(
        email: _emailController.text.trim(),
        otpCode: _otpController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: AppConstants.successColor,
          ),
        );

        // Navigate back to login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Đang đặt lại mật khẩu...',
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
                    'Đặt lại mật khẩu',
                    style: TextStyle(
                      color: AppConstants.textPrimaryColor,
                      fontSize: AppConstants.fontSizeHeading,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Instructions
                  const Text(
                    'Nhập mã OTP đã được gửi đến email của bạn và tạo mật khẩu mới.',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: AppConstants.fontSizeMedium,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Email field (read-only)
                  CustomTextField(
                    label: 'Email',
                    hintText: 'email@example.com',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    enabled:
                        _email ==
                        null, // Only editable if not passed from previous screen
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // OTP field
                  CustomTextField(
                    label: 'Mã OTP',
                    hintText: 'Nhập mã 6 chữ số',
                    prefixIcon: Icons.lock_clock,
                    controller: _otpController,
                    validator: Validators.validateOTP,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // New Password field
                  CustomTextField(
                    label: 'Mật khẩu mới',
                    hintText: 'Nhập mật khẩu mới',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _newPasswordController,
                    validator: Validators.validatePassword,
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge * 2),

                  // Reset Password button
                  CustomButton(
                    text: 'Đặt lại mật khẩu',
                    onPressed: _handleResetPassword,
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

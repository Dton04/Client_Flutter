import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconAsset;
  final VoidCallback onPressed;
  final bool isApple;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconAsset,
    required this.onPressed,
    this.isApple = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppConstants.borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          backgroundColor: AppConstants.surfaceColor,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon placeholder - using built-in icons for now
            Icon(
              isApple ? Icons.apple : Icons.g_mobiledata_rounded,
              size: AppConstants.iconSizeLarge,
              color: AppConstants.textPrimaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

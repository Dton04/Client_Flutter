import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      height: height ?? AppConstants.buttonHeight,
      width: width ?? double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isDisabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDisabled
                      ? AppConstants.borderColor
                      : (backgroundColor ?? AppConstants.primaryColor),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: _buildChild(),
            )
          : ElevatedButton(
              onPressed: isDisabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? AppConstants.borderColor
                    : (backgroundColor ?? AppConstants.primaryColor),
                foregroundColor: textColor ?? AppConstants.textPrimaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                disabledBackgroundColor: AppConstants.borderColor,
                disabledForegroundColor: AppConstants.textSecondaryColor,
              ),
              child: _buildChild(),
            ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppConstants.textPrimaryColor,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppConstants.iconSizeMedium),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppConstants.textPrimaryColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: textColor ?? AppConstants.textPrimaryColor,
      ),
    );
  }
}

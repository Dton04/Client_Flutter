class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email không đúng định dạng';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    return null;
  }

  // Full name validation
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Họ tên không được để trống';
    }

    if (value.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }

    return null;
  }

  // OTP validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mã OTP không được để trống';
    }

    if (value.length != 6) {
      return 'Mã OTP phải có 6 chữ số';
    }

    // Check if all characters are digits
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Mã OTP chỉ được chứa số';
    }

    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Xác nhận mật khẩu không được để trống';
    }

    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }
}

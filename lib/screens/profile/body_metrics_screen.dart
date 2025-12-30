import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/body_metrics_service.dart';
import '../../utils/constants.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  Future<void> _saveMetrics() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final weight = double.parse(_weightController.text.trim());
      final height = double.parse(_heightController.text.trim());
      final bodyFat = _bodyFatController.text.trim().isNotEmpty
          ? double.parse(_bodyFatController.text.trim())
          : null;

      final response = await BodyMetricsService.addBodyMetrics(
        weight: weight,
        height: height,
        bodyFatPercentage: bodyFat,
      );

      if (mounted) {
        final metricId = response['metric_id'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã ghi nhận chỉ số #$metricId'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Cập nhật chỉ số cơ thể')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppConstants.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ghi lại chỉ số cơ thể để theo dõi tiến trình của bạn',
                              style: TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: AppConstants.fontSizeSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Weight Field
                    const Text(
                      'Cân nặng (kg)',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: 70.5',
                        hintStyle: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        suffixText: 'kg',
                        suffixStyle: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: AppConstants.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppConstants.borderColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppConstants.borderColor,
                          ),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập cân nặng';
                        }
                        final weight = double.tryParse(value.trim());
                        if (weight == null || weight <= 0 || weight > 500) {
                          return 'Cân nặng không hợp lệ (0-500 kg)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Height Field
                    const Text(
                      'Chiều cao (cm)',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: 175',
                        hintStyle: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        suffixText: 'cm',
                        suffixStyle: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: AppConstants.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppConstants.borderColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppConstants.borderColor,
                          ),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập chiều cao';
                        }
                        final height = double.tryParse(value.trim());
                        if (height == null || height <= 0 || height > 300) {
                          return 'Chiều cao không hợp lệ (0-300 cm)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Body Fat Percentage Field
                    const Text(
                      'Tỷ lệ mỡ (%) - Tùy chọn',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bodyFatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: 15.5',
                        hintStyle: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        suffixText: '%',
                        suffixStyle: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: AppConstants.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppConstants.borderColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppConstants.borderColor,
                          ),
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
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final bodyFat = double.tryParse(value.trim());
                          if (bodyFat == null || bodyFat < 0 || bodyFat > 100) {
                            return 'Tỷ lệ mỡ không hợp lệ (0-100%)';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveMetrics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Ghi nhận chỉ số',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_profile_model.dart';
import '../../services/profile_service.dart';
import '../../services/upload_service.dart';
import '../../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileModel userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();

  String? _selectedGender;
  String? _selectedFitnessGoal;
  File? _selectedImage;
  String? _avatarUrl;
  bool _isLoading = false;
  bool _isUploading = false;

  final List<String> _genderOptions = ['MALE', 'FEMALE', 'OTHER'];
  final List<String> _fitnessGoalOptions = [
    'Muscle Gain',
    'Weight Loss',
    'Endurance',
    'Flexibility',
    'General Fitness',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.userProfile.fullName;
    _selectedGender = widget.userProfile.gender;
    _selectedFitnessGoal = widget.userProfile.fitnessGoal;
    _avatarUrl = widget.userProfile.avatarUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppConstants.primaryColor,
                ),
                title: const Text(
                  'Chụp ảnh',
                  style: TextStyle(color: AppConstants.textPrimaryColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppConstants.primaryColor,
                ),
                title: const Text(
                  'Chọn từ thư viện',
                  style: TextStyle(color: AppConstants.textPrimaryColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? uploadedAvatarUrl = _avatarUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        setState(() {
          _isUploading = true;
        });

        uploadedAvatarUrl = await UploadService.uploadImage(_selectedImage!);

        setState(() {
          _isUploading = false;
        });
      }

      // Update profile
      await ProfileService.updateProfile(
        fullName: _fullNameController.text.trim(),
        avatarUrl: uploadedAvatarUrl,
        gender: _selectedGender,
        fitnessGoal: _selectedFitnessGoal,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
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
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isUploading ? 'Đang tải ảnh lên...' : 'Đang lưu...',
                    style: const TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: AppConstants.fontSizeMedium,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppConstants.primaryColor
                                  .withOpacity(0.2),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (_avatarUrl != null
                                            ? NetworkImage(_avatarUrl!)
                                            : null)
                                        as ImageProvider?,
                              child:
                                  _selectedImage == null && _avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppConstants.primaryColor,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppConstants.backgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full Name Field
                    const Text(
                      'Họ và tên',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập họ và tên',
                        hintStyle: const TextStyle(
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
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Gender Field
                    const Text(
                      'Giới tính',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                      ),
                      dropdownColor: AppConstants.cardColor,
                      decoration: InputDecoration(
                        hintText: 'Chọn giới tính',
                        hintStyle: const TextStyle(
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
                      items: _genderOptions.map((gender) {
                        // Map backend values to display labels
                        String displayLabel = gender;
                        switch (gender) {
                          case 'MALE':
                            displayLabel = 'Nam';
                            break;
                          case 'FEMALE':
                            displayLabel = 'Nữ';
                            break;
                          case 'OTHER':
                            displayLabel = 'Khác';
                            break;
                        }
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(displayLabel),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Fitness Goal Field
                    const Text(
                      'Mục tiêu tập luyện',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedFitnessGoal,
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                      ),
                      dropdownColor: AppConstants.cardColor,
                      decoration: InputDecoration(
                        hintText: 'Chọn mục tiêu',
                        hintStyle: const TextStyle(
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
                      items: _fitnessGoalOptions.map((goal) {
                        return DropdownMenuItem(value: goal, child: Text(goal));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFitnessGoal = value;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save Button (Mobile)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Lưu thay đổi',
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

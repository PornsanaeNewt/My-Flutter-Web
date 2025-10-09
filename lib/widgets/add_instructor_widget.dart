import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/styles/font-style.dart';
import 'package:image_picker/image_picker.dart';

class AddInstructorWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController birthdayController;
  final String selectedGender;
  final List<String> genderOptions;
  final XFile? pickedImage;
  final Uint8List? pickedImageBytes;
  final bool isLoading;
  final VoidCallback onSelectDate;
  final VoidCallback onPickImage;
  final Function(String?) onGenderChanged;
  final VoidCallback onSubmitForm;
  final VoidCallback onCancel;

  const AddInstructorWidget({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.birthdayController,
    required this.selectedGender,
    required this.genderOptions,
    required this.pickedImage,
    required this.pickedImageBytes,
    required this.isLoading,
    required this.onSelectDate,
    required this.onPickImage,
    required this.onGenderChanged,
    required this.onSubmitForm,
    required this.onCancel,
  });

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.title.copyWith(
              fontSize: FontStyles.large, 
              fontWeight: FontStyles.semiBold,
              color: AppColors.primaryBlack,
            ),
          ),
          const Divider(color: AppColors.inputBorder, height: 16, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    Widget imageWidget;
    if (pickedImage == null) {
      imageWidget = const Icon(
        Icons.person,
        size: 70, 
        color: AppColors.secondaryText,
      );
    } else if (kIsWeb && pickedImageBytes != null) {
      imageWidget = Image.memory(
        pickedImageBytes!,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.file(
        File(pickedImage!.path),
        fit: BoxFit.cover,
      );
    }

    return Column(
      children: [
        Container(
          width: 140, 
          height: 140, 
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightAccent, 
            border: Border.all(color: AppColors.inputFocusedBorder, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: imageWidget,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.photo_camera, color: AppColors.buttonText, size: 20),
          label: Text(
            'เลือกรูปโปรไฟล์', 
            style: TextStyles.button.copyWith(color: AppColors.buttonText),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.accent, 
            side: const BorderSide(color: AppColors.primaryButton, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), 
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'รองรับ JPG, PNG, GIF',
          style: TextStyles.body.copyWith(
            color: AppColors.secondaryText,
            fontSize: FontStyles.small,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.label.copyWith(color: AppColors.primaryBlack),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightAccent,
            hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เพศ',
          style: TextStyles.label.copyWith(color: AppColors.primaryBlack),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
              onChanged: onGenderChanged,
              isExpanded: true,
              items: genderOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'วันเกิด',
          style: TextStyles.label.copyWith(color: AppColors.primaryBlack),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onSelectDate,
          child: IgnorePointer(
            child: TextFormField(
              controller: birthdayController,
              style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
              decoration: InputDecoration(
                hintText: 'เลือกวันเกิด',
                hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
                ),
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.secondaryText),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาเลือกวันเกิด';
                }
                final selectedDate = DateTime.tryParse(value);
                if (selectedDate != null && selectedDate.isAfter(DateTime.now())) {
                  return 'วันเกิดต้องไม่เป็นวันที่ในอนาคต';
                }

                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isSecondary,
    required bool isLoading,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? AppColors.subtleGray : AppColors.primaryButton,
          foregroundColor: isSecondary ? AppColors.secondaryText : AppColors.buttonText,
          elevation: isSecondary ? 1 : 4,
          shadowColor: AppColors.shadowColor,
          side: isSecondary ? const BorderSide(color: AppColors.inputBorder) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: isSecondary ? AppColors.secondaryText : AppColors.buttonText,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: TextStyles.button.copyWith(
                  color: isSecondary ? AppColors.mutedBrown : AppColors.buttonText,
                  fontWeight: FontStyles.semiBold,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: formKey,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.formBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'เพิ่มข้อมูลผู้สอนใหม่',
                      style: TextStyles.title.copyWith(fontSize: FontStyles.heading, color: AppColors.primaryBlack),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildProfilePictureSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader('ข้อมูลส่วนตัว'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'ชื่อผู้สอน',
                          controller: firstNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\u0e00-\u0e7f\s]')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกชื่อ';
                            }
                            if (!RegExp(r'^[a-zA-Z\u0e00-\u0e7f\s]+$').hasMatch(value)) {
                              return 'ชื่อต้องประกอบด้วยตัวอักษรเท่านั้น';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          label: 'นามสกุลผู้สอน',
                          controller: lastNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\u0e00-\u0e7f\s]')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกนามสกุล';
                            }
                            if (!RegExp(r'^[a-zA-Z\u0e00-\u0e7f\s]+$').hasMatch(value)) {
                              return 'นามสกุลต้องประกอบด้วยตัวอักษรเท่านั้น';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('ข้อมูลการติดต่อ'),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'อีเมล',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      if (!value.endsWith('@gmail.com')) {
                        return 'กรุณากรอกอีเมลที่ลงท้ายด้วย @gmail.com เท่านั้น';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'เบอร์โทร',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10), 
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกเบอร์โทร';
                      }
                      if (value.length != 10) { 
                        return 'เบอร์โทรต้องมี 10 ตัวเลข';
                      }
                      if (!value.startsWith('06') && !value.startsWith('08') && !value.startsWith('09')) {
                        return 'เบอร์โทรต้องขึ้นต้นด้วย 06, 08, หรือ 09 เท่านั้น';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('ข้อมูลเพิ่มเติม'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                       Expanded(
                        child: _buildBirthdayPicker(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderDropdown(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),

                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          text: 'ยกเลิก',
                          onPressed: onCancel,
                          isSecondary: true,
                          isLoading: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildButton(
                          text: 'ยืนยันการเพิ่ม', 
                          onPressed: onSubmitForm,
                          isSecondary: false,
                          isLoading: isLoading,
                        ),
                      ),
                    ],
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
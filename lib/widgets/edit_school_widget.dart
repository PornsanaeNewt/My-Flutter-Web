import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/styles/font-style.dart';

class EditSchoolWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController schoolNameController;
  final TextEditingController schoolTelController;
  final TextEditingController schoolAddressController;
  final TextEditingController schoolDetailController;
  final TextEditingController schoolEmailController;
  final TextEditingController schoolLatitudeController;
  final TextEditingController schoolLongitudeController;
  final TextEditingController schoolPasswordController;
  final bool isLoading;
  final String? currentSchoolPictureFileName;
  final XFile? pickedImage;
  final Uint8List? pickedImageBytes;
  final VoidCallback onPickImage;
  final VoidCallback onClearPicture;
  final VoidCallback onUpdateSchool;
  final VoidCallback onCancel;
  // เพิ่มสำหรับรหัสผ่าน
  final bool obscurePassword;
  final VoidCallback togglePasswordVisibility;

  const EditSchoolWidget({
    super.key,
    required this.formKey,
    required this.schoolNameController,
    required this.schoolTelController,
    required this.schoolAddressController,
    required this.schoolDetailController,
    required this.schoolEmailController,
    required this.schoolLatitudeController,
    required this.schoolLongitudeController,
    required this.schoolPasswordController,
    required this.isLoading,
    required this.currentSchoolPictureFileName,
    required this.pickedImage,
    required this.pickedImageBytes,
    required this.onPickImage,
    required this.onClearPicture,
    required this.onUpdateSchool,
    required this.onCancel,
    // เพิ่มการรับค่าใหม่
    required this.obscurePassword,
    required this.togglePasswordVisibility,
  });

  // สร้างส่วนหัวข้อพร้อมเส้นแบ่ง
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

  // ส่วนจัดการรูปภาพ
  Widget _buildPictureInput() {
    Widget imageWidget;
    String imageUrl = currentSchoolPictureFileName != null && currentSchoolPictureFileName!.isNotEmpty
        ? 'http://localhost:3000/assets/school/$currentSchoolPictureFileName'
        : 'https://placehold.co/250x200/EFE4D6/7A6B4F?text=School+Image';

    if (pickedImage != null) {
      imageWidget = kIsWeb && pickedImageBytes != null
          ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
          : Image.file(File(pickedImage!.path), fit: BoxFit.cover);
    } else if (currentSchoolPictureFileName != null && currentSchoolPictureFileName!.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50, color: AppColors.secondaryText),
      );
    } else {
      imageWidget = const Icon(Icons.image, size: 50, color: AppColors.secondaryText);
    }

    return Column(
      children: [
        Container(
          width: 350,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBackground, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageWidget,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ปุ่มเลือกรูปภาพ
            OutlinedButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.photo_library, color: AppColors.buttonText, size: 20),
              label: Text('เลือกรูปภาพใหม่', style: TextStyles.button.copyWith(color: AppColors.buttonText)),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.primaryButton, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
            const SizedBox(width: 12),
            // ปุ่มล้างรูปภาพ
            TextButton.icon(
              onPressed: currentSchoolPictureFileName != null || pickedImage != null ? onClearPicture : null,
              icon: const Icon(Icons.clear, color: AppColors.errorColor, size: 20),
              label: Text('ล้างรูปภาพ', style: TextStyles.body.copyWith(color: AppColors.errorColor, fontWeight: FontStyles.regular)),
              style: TextButton.styleFrom(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'รองรับ JPG, PNG, GIF (ไม่เกิน 5MB)',
          style: TextStyles.body.copyWith(
            color: AppColors.secondaryText,
            fontSize: FontStyles.small,
          ),
        ),
      ],
    );
  }

  // ปรับปรุง TextField ให้รองรับ validator และปุ่มสลับรหัสผ่าน
  Widget _buildTextField(
    TextEditingController controller, 
    String label,
    {
      String? Function(String?)? customValidator,
      TextInputType keyboardType = TextInputType.text, 
      bool obscure = false, 
      int maxLines = 1, 
      List<TextInputFormatter>? inputFormatters,
      // เพิ่มพารามิเตอร์สำหรับปุ่มสลับรหัสผ่าน
      VoidCallback? onSuffixIconPressed, 
    }
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground,
              // เพิ่ม suffixIcon สำหรับรหัสผ่าน
              suffixIcon: onSuffixIconPressed != null
                ? IconButton(
                    icon: Icon(
                      // ใช้ obscure เพื่อกำหนดไอคอน
                      obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
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
              labelText: null,
            ),
            validator: customValidator,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: formKey,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
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
                  // 1. ส่วนรูปภาพ
                  _buildSectionHeader('รูปภาพโรงเรียน'),
                  Center(child: _buildPictureInput()),
                  const SizedBox(height: 24),
                  
                  // 2. ข้อมูลหลัก
                  _buildSectionHeader('ข้อมูลทั่วไป'),
                  // Validation: ชื่อโรงเรียน (ห้ามว่าง)
                  _buildTextField(
                    schoolNameController, 
                    'ชื่อโรงเรียน', 
                    customValidator: (value) =>
                        value == null || value.isEmpty ? 'กรุณากรอก ชื่อโรงเรียน' : null,
                  ),
                  // Validation: เบอร์โทร (ตัวเลข 10 หลัก)
                  _buildTextField(
                    schoolTelController, 
                    'เบอร์โทร', 
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    customValidator: (value) {
                      if (value == null || value.isEmpty) return 'กรุณากรอก เบอร์โทร';
                      if (value.length != 10) return 'เบอร์โทรต้องมี 10 ตัวเลข';
                      if (!value.startsWith('0')) return 'เบอร์โทรต้องขึ้นต้นด้วย 0';
                      return null;
                    },
                  ),
                  _buildTextField(schoolAddressController, 'ที่อยู่', maxLines: 3),
                  _buildTextField(schoolDetailController, 'รายละเอียด', maxLines: 5),
                  
                  // 3. ข้อมูลติดต่อ
                  _buildSectionHeader('ข้อมูลการติดต่อและบัญชี'),
                  // Validation: อีเมล (ต้องเป็นรูปแบบอีเมลที่ถูกต้อง)
                  _buildTextField(
                    schoolEmailController, 
                    'อีเมล', 
                    keyboardType: TextInputType.emailAddress,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) return 'กรุณากรอก อีเมล';
                      if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return 'รูปแบบอีเมลไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  
                  // 4. ข้อมูลพิกัด
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        // Validation: ละติจูด (รูปแบบตัวเลข)
                        child: _buildTextField(
                          schoolLatitudeController, 
                          'ละติจูด (Latitude)', 
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                          customValidator: (value) {
                            if (value == null || value.isEmpty) return 'กรุณากรอก ละติจูด';
                            if (double.tryParse(value) == null) return 'รูปแบบตัวเลขไม่ถูกต้อง';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        // Validation: ลองจิจูด (รูปแบบตัวเลข)
                        child: _buildTextField(
                          schoolLongitudeController, 
                          'ลองจิจูด (Longitude)', 
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                          customValidator: (value) {
                            if (value == null || value.isEmpty) return 'กรุณากรอก ลองจิจูด';
                            if (double.tryParse(value) == null) return 'รูปแบบตัวเลขไม่ถูกต้อง';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  // Validation: รหัสผ่าน (ถ้ามีการกรอก ต้องมีอย่างน้อย 6 ตัวอักษร)
                  _buildTextField(
                    schoolPasswordController, 
                    'รหัสผ่าน (เว้นว่างหากไม่ต้องการเปลี่ยน)', 
                    obscure: obscurePassword, // ส่งสถานะ Obscure
                    onSuffixIconPressed: togglePasswordVisibility, // ส่ง Callback สลับสถานะ
                    customValidator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // ปุ่มดำเนินการ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.subtleGray,
                              side: const BorderSide(color: AppColors.inputBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                            ),
                            child: Text('ยกเลิก', style: TextStyles.button.copyWith(color: AppColors.mutedBrown)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            // เมื่อกดปุ่ม ให้เรียก validate ก่อน
                            onPressed: isLoading ? null : () {
                              if (formKey.currentState!.validate()) {
                                onUpdateSchool();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.shadowColor.withOpacity(0.5),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: AppColors.buttonText, strokeWidth: 3),
                                  )
                                : Text('บันทึกการแก้ไข', style: TextStyles.button),
                          ),
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
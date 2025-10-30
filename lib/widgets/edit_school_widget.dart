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
  final bool isLoading;
  final String? currentSchoolPictureFileName;
  final XFile? pickedImage;
  final Uint8List? pickedImageBytes;
  final VoidCallback onPickImage;
  final VoidCallback onClearPicture;
  final VoidCallback onUpdateSchool;
  final VoidCallback onCancel;
  final VoidCallback onOpenMap;

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
    required this.isLoading,
    required this.currentSchoolPictureFileName,
    required this.pickedImage,
    required this.pickedImageBytes,
    required this.onPickImage,
    required this.onClearPicture,
    required this.onUpdateSchool,
    required this.onCancel,
    required this.onOpenMap,
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

  Widget _buildTextField(
    TextEditingController controller, 
    String label,
    {
      String? Function(String?)? customValidator,
      TextInputType keyboardType = TextInputType.text, 
      bool obscure = false, 
      int maxLines = 1, 
      List<TextInputFormatter>? inputFormatters,
      Widget? suffixWidget, 
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
              suffixIcon: suffixWidget,
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
                  _buildSectionHeader('รูปภาพโรงเรียน'),
                  Center(child: _buildPictureInput()),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('ข้อมูลทั่วไป'),
                  _buildTextField(
                    schoolNameController, 
                    'ชื่อโรงเรียน', 
                    customValidator: (value) =>
                        value == null || value.isEmpty ? 'กรุณากรอก ชื่อโรงเรียน' : null,
                  ),
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
                  
                  _buildSectionHeader('ข้อมูลการติดต่อและบัญชี'),
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
                  
                  _buildSectionHeader('พิกัดโรงเรียน'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                    child: ElevatedButton.icon(
                      onPressed: onOpenMap,
                      icon: const Icon(Icons.map_outlined, color: AppColors.buttonText),
                      label: Text('เปิดแผนที่เพื่อเลือกพิกัด', style: TextStyles.button.copyWith(color: AppColors.buttonText)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.linkText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

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
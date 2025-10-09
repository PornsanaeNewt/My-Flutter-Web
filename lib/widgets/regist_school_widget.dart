import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/styles/font-style.dart'; 

class RegisterSchoolWidgets {
  
  static Widget _buildSectionHeader(String title) { 
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0), 
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

  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false, 
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, 
    bool isPassword = false, 
    VoidCallback? onSuffixIconPressed, 
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
          obscureText: isPassword ? obscureText : false, 
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint ?? 'กรอก$label',
            hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText),
            filled: true,
            fillColor: AppColors.inputBackground, 
            suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: onSuffixIconPressed,
                  )
                : suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), 
              borderSide: const BorderSide(color: AppColors.inputBorder), 
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder), 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2), 
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
          ),
          validator: validator,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static Widget buildFileUploadArea({
    required XFile? pickedImage,
    required Uint8List? pickedImageBytes,
    required VoidCallback pickImageCallback,
  }) {
    Widget content;
    if (pickedImage == null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 40,
            color: AppColors.secondaryText, 
          ),
          const SizedBox(height: 8),
          Text(
            'คลิกเพื่ออัปโหลดรูปภาพหลักของโรงเรียน',
            style: TextStyles.body.copyWith(color: AppColors.primaryBlack, fontWeight: FontStyles.regular),
          ),
          Text(
            'รองรับ PNG, JPG/JPEG (แนะนำ), หรือ GIF', 
            style: TextStyles.body.copyWith(
              color: AppColors.secondaryText,
              fontSize: FontStyles.small,
            ),
          ),
        ],
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8), 
        child: kIsWeb && pickedImageBytes != null
            ? Image.memory(
                pickedImageBytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Image.file(
                File(pickedImage.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('รูปภาพหลัก'),
        GestureDetector(
          onTap: pickImageCallback,
          child: Container(
            width: double.infinity,
            height: 200, 
            decoration: BoxDecoration(
              color: AppColors.lightAccent, 
              border: Border.all(
                color: AppColors.inputBorder,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: content,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static Widget buildRegistrationFormCard({
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController phoneController,
    required TextEditingController addressController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required TextEditingController detailController,
    required XFile? pickedImage,
    required Uint8List? pickedImageBytes,
    required VoidCallback pickImageCallback,
    required bool agree,
    required ValueChanged<bool?> onAgreeChanged,
    required VoidCallback submitFormCallback,
    required bool isLoading,
    required bool isLoadingLocation,
    required VoidCallback determineAndSetPositionCallback,
    required bool obscurePassword,
    required bool obscureConfirmPassword,
    required VoidCallback togglePasswordVisibility,
    required VoidCallback toggleConfirmPasswordVisibility,
  }) {
    final getLocationButton = Container(
      padding: const EdgeInsets.only(bottom: 20), 
      child: SizedBox(
        height: 54, 
        child: ElevatedButton(
          onPressed: isLoadingLocation ? null : determineAndSetPositionCallback,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkAccent, 
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),
          child: isLoadingLocation
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText)),
              )
            : const Tooltip( 
                message: 'ค้นหาตำแหน่งปัจจุบัน',
                child: Icon(Icons.location_on, size: 24, color: AppColors.buttonText),
              ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(32),
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
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'ลงทะเบียนโรงเรียนใหม่',
                style: TextStyles.title.copyWith(fontSize: FontStyles.heading, color: AppColors.primaryBlack),
              ),
            ),
            const SizedBox(height: 24),
            
            RegisterSchoolWidgets.buildFileUploadArea(
              pickedImage: pickedImage,
              pickedImageBytes: pickedImageBytes,
              pickImageCallback: pickImageCallback,
            ),
            
            _buildSectionHeader('ข้อมูลทั่วไป'),
            RegisterSchoolWidgets.buildTextField(
                controller: nameController, 
                label: 'ชื่อโรงเรียน', 
                validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อ' : null
            ),

            RegisterSchoolWidgets.buildTextField(
                controller: detailController, 
                label: 'รายละเอียดโรงเรียน', 
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'กรุณากรอกรายละเอียด' : null,
            ),
            RegisterSchoolWidgets.buildTextField(
                controller: addressController, 
                label: 'ที่อยู่',
                validator: (v) => v!.isEmpty ? 'กรุณากรอกที่อยู่' : null,
            ),

            _buildSectionHeader('ข้อมูลติดต่อและบัญชี'),
            RegisterSchoolWidgets.buildTextField(
              controller: emailController, 
              label: 'อีเมล', 
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'กรุณากรอกอีเมล';
                if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v)) return 'รูปแบบอีเมลไม่ถูกต้อง';
                return null;
              }, 
            ),
            RegisterSchoolWidgets.buildTextField(
              controller: phoneController, 
              label: 'เบอร์โทร', 
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (v!.isEmpty) return 'กรุณากรอกเบอร์โทร';
                if (v.length != 10) return 'เบอร์โทรต้องมี 10 ตัวเลข';
                if (!v.startsWith('0')) {
                   return 'เบอร์โทรต้องขึ้นต้นด้วย 0 เท่านั้น';
                }
                return null;
              },
            ),

            RegisterSchoolWidgets.buildTextField(
              controller: passwordController, 
              label: 'รหัสผ่าน', 
              obscureText: obscurePassword, 
              isPassword: true,
              onSuffixIconPressed: togglePasswordVisibility, 
              validator: (v) => v!.length < 6 ? 'อย่างน้อย 6 ตัวอักษร' : null,
            ),

            RegisterSchoolWidgets.buildTextField(
              controller: confirmPasswordController, 
              label: 'ยืนยันรหัสผ่าน', 
              obscureText: obscureConfirmPassword, 
              isPassword: true,
              onSuffixIconPressed: toggleConfirmPasswordVisibility, 
              validator: (v) => v != passwordController.text ? 'รหัสผ่านไม่ตรงกัน' : null,
            ),

            _buildSectionHeader('พิกัดทางภูมิศาสตร์'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RegisterSchoolWidgets.buildTextField(
                    controller: latitudeController, 
                    label: 'ละติจูด', 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), 
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                    validator: (v) {
                      if (v!.isEmpty) return 'กรุณากรอกละติจูด';
                      if (double.tryParse(v) == null) return 'รูปแบบไม่ถูกต้อง';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RegisterSchoolWidgets.buildTextField(
                    controller: longitudeController, 
                    label: 'ลองจิจูด',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                    validator: (v) {
                      if (v!.isEmpty) return 'กรุณากรอกลองจิจูด';
                      if (double.tryParse(v) == null) return 'รูปแบบไม่ถูกต้อง';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                getLocationButton,
              ],
            ),
            
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: agree,
                    onChanged: onAgreeChanged,
                    activeColor: AppColors.primaryButton,
                    checkColor: AppColors.buttonText,
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('ยอมรับข้อตกลงและเงื่อนไข', style: TextStyles.body.copyWith(color: AppColors.primaryBlack))),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (agree && !isLoading && !isLoadingLocation) ? submitFormCallback : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: AppColors.buttonText,
                  elevation: 5,
                  shadowColor: AppColors.primaryButton.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.buttonText), 
                          strokeWidth: 3,
                        ),
                      )
                    : Text('ยืนยันการลงทะเบียน', style: TextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildLargeScreenLayout({
    required Widget registrationFormCard,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000), 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(right: 48),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'lib/assets/images/image34.jpg', 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: registrationFormCard,
            ),
          ],
        ),
      ),
    );
  }
}
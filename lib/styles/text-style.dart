import 'package:flutter/material.dart';
import 'app-color.dart';
import 'font-style.dart';

class TextStyles {
  // NavigationActive
  static TextStyle get navigationActive => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryButton, 
  );

  // NavigationInactives
  static TextStyle get navigationInactive => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  // หัวข้อหลัก
  static TextStyle get title => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // ข้อความสำหรับ label
  static TextStyle get label => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
  );

  // ข้อความใน input field
  static TextStyle get input => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  // ข้อความในปุ่ม
  static TextStyle get button => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
  );

  // ข้อความลิงก์
  static TextStyle get link => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.linkText,
    decoration: TextDecoration.underline,
  );

  // ข้อความธรรมดา
  static TextStyle get body => TextStyle(
    fontFamily: FontStyles.primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

   static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Prompt',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );
}

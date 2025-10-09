import 'package:flutter/material.dart';
import 'package:project_web/screens/regis_school_page.dart'; 
import 'package:project_web/styles/app-color.dart'; 
import 'package:project_web/styles/text-style.dart'; 
import 'package:project_web/styles/font-style.dart'; 

class LoginWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool? isChecked;
  final bool isLoading;
  final VoidCallback onLogin;
  final ValueChanged<bool?> onRememberMeChanged;

  const LoginWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isChecked,
    required this.isLoading,
    required this.onLogin,
    required this.onRememberMeChanged,
  });

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  
  Widget _buildTextFormField(
    TextEditingController controller,
    String hintText,
    bool obscureText,
    String validatorMessage,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.inputBackground, 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
      ),
      validator: (value) => value == null || value.isEmpty ? validatorMessage : null,
    );
  }

  Widget _buildLoginFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.3), 
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 70, 
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.accent, 
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 36,
                      color: AppColors.primaryButton,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'เข้าสู่ระบบ', 
                    style: TextStyles.title.copyWith(fontSize: FontStyles.largeHeading, color: AppColors.primaryBlack),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ยินดีต้อนรับเข้าสู่ Thai Cooking Course',
                    style: TextStyles.body.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Text('อีเมล', style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
            const SizedBox(height: 8),
            _buildTextFormField(widget.emailController, 'กรอกอีเมลของคุณ', false, 'กรุณากรอกอีเมล'),
            const SizedBox(height: 20),
            Text('รหัสผ่าน', style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
            const SizedBox(height: 8),
            _buildTextFormField(widget.passwordController, 'กรอกรหัสผ่านของคุณ', true, 'กรุณากรอกรหัสผ่าน'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: widget.isChecked,
                        onChanged: widget.onRememberMeChanged,
                        activeColor: AppColors.darkAccent, 
                        checkColor: AppColors.buttonText,
                        side: BorderSide(color: AppColors.inputBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('จำฉันไว้ในระบบ', style: TextStyles.body.copyWith(color: AppColors.primaryBlack)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('ลืมรหัสผ่าน?', style: TextStyles.link.copyWith(color: AppColors.linkText, fontWeight: FontStyles.semiBold)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50, 
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: AppColors.buttonText,
                  elevation: 5,
                  shadowColor: AppColors.primaryButton.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText), 
                          strokeWidth: 3,
                        ),
                      )
                    : Text('เข้าสู่ระบบ', style: TextStyles.button),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ยังไม่มีบัญชีใช่หรือไม่? ', style: TextStyles.body.copyWith(color: AppColors.primaryBlack)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterSchoolPage()),
                      );
                    },
                    child: Text('ลงทะเบียนเลย', style: TextStyles.link),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450), 
            child: _buildLoginFormCard(),
          ),
        ),
      ),
    );
  }
}
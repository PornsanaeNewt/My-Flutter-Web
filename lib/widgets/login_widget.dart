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
  final bool isSchoolLogin; 
  final VoidCallback onToggleFlip;

  const LoginWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isChecked,
    required this.isLoading,
    required this.onLogin,
    required this.onRememberMeChanged,
    required this.isSchoolLogin,
    required this.onToggleFlip,
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
    final Color inputFillColor =
        widget.isSchoolLogin ? AppColors.inputBackground : Colors.white;
    final Color inputTextColor = AppColors.primaryBlack;
    final Color inputBorderColor =
        widget.isSchoolLogin
            ? AppColors.inputBorder
            : AppColors.darkAccent.withOpacity(0.5);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyles.input.copyWith(color: inputTextColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText),
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.inputFocusedBorder, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator:
          (value) => value == null || value.isEmpty ? validatorMessage : null,
    );
  }

  Widget _buildLoginFormCard() {
    final Color formBackgroundColor =
        widget.isSchoolLogin ? AppColors.formBackground : AppColors.darkAccent;
    final Color primaryColor =
        widget.isSchoolLogin ? AppColors.primaryButton : AppColors.accent;
    final Color textColor =
        widget.isSchoolLogin ? AppColors.primaryBlack : AppColors.buttonText;
    final Color secondaryTextColor =
        widget.isSchoolLogin
            ? AppColors.secondaryText
            : AppColors.buttonText.withOpacity(0.8);
    final String titleText =
        widget.isSchoolLogin ? 'เข้าสู่ระบบ' : 'Admin Login';
    final String subtitleText =
        widget.isSchoolLogin
            ? 'ยินดีต้อนรับเข้าสู่ Thai Cooking Course'
            : 'เข้าสู่ระบบในฐานะผู้ดูแลระบบ';
    final String loginButtonText =
        widget.isSchoolLogin ? 'เข้าสู่ระบบ' : 'Admin Login';
    final Color linkColor =
        widget.isSchoolLogin ? AppColors.linkText : AppColors.buttonText;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: formBackgroundColor,
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
                  GestureDetector(
                    onTap: widget.onToggleFlip,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Icon(
                        widget.isSchoolLogin
                            ? Icons.school
                            : Icons.admin_panel_settings,
                        size: 36,
                        color: AppColors.buttonText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    titleText,
                    style: TextStyles.title.copyWith(
                      fontSize: FontStyles.largeHeading,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    style: TextStyles.body.copyWith(color: secondaryTextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Text('อีเมล', style: TextStyles.label.copyWith(color: textColor)),
            const SizedBox(height: 8),
            _buildTextFormField(
              widget.emailController,
              'กรอกอีเมลของคุณ',
              false,
              'กรุณากรอกอีเมล',
            ),
            const SizedBox(height: 20),
            Text(
              'รหัสผ่าน',
              style: TextStyles.label.copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
            _buildTextFormField(
              widget.passwordController,
              'กรอกรหัสผ่านของคุณ',
              true,
              'กรุณากรอกรหัสผ่าน',
            ),
            const SizedBox(height: 16),

            if (widget.isSchoolLogin)
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'จำฉันไว้ในระบบ',
                        style: TextStyles.body.copyWith(color: textColor),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'ลืมรหัสผ่าน?',
                      style: TextStyles.link.copyWith(
                        color: linkColor,
                        fontWeight: FontStyles.semiBold,
                      ),
                    ),
                  ),
                ],
              ),

            if (!widget.isSchoolLogin) const SizedBox(height: 32),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: AppColors.buttonText,
                  elevation: 5,
                  shadowColor: primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    widget.isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.buttonText,
                            ),
                            strokeWidth: 3,
                          ),
                        )
                        : Text(loginButtonText, style: TextStyles.button),
              ),
            ),
            const SizedBox(height: 24),

            if (widget.isSchoolLogin)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยังไม่มีบัญชีใช่หรือไม่? ',
                      style: TextStyles.body.copyWith(color: textColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterSchoolPage(),
                          ),
                        );
                      },
                      child: Text(
                        'ลงทะเบียนเลย',
                        style: TextStyles.link.copyWith(color: linkColor),
                      ),
                    ),
                  ],
                ),
              ),

            if (!widget.isSchoolLogin)
              Center(
                child: TextButton(
                  onPressed: widget.onToggleFlip,
                  child: Text(
                    'กลับไปหน้าเข้าสู่ระบบโรงเรียน',
                    style: TextStyles.link.copyWith(
                      color: linkColor,
                      fontWeight: FontStyles.semiBold,
                    ),
                  ),
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
      backgroundColor:
          widget.isSchoolLogin
              ? AppColors.primaryBackground
              : Colors.transparent,
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

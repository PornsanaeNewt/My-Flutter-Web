import 'package:flutter/material.dart';
import 'package:project_web/controllers/loginController.dart';
import 'package:project_web/screens/list_course_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/widgets/login_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool? isChecked = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolID = prefs.getString('schoolId');
    if (schoolID != null && mounted) {
      setState(() {
        _isLoggedIn = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListCoursePage()),
      );
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      }); 

      String email = emailController.text.trim();
      String password = passwordController.text;

      try {
        final userData = await LoginController.login(email, password);

        if (userData != null) {
          if (userData['error'] == 'wait_for_approval') {
            _showSnackBar('กรุณารอการตรวจสอบ');
            return;
          } else {
            _showSnackBar('เข้าสู่ระบบสำเร็จ');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ListCoursePage()),
            );
          }
        } else {
          _showSnackBar('ไม่พบผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง');
        }
      } catch (e) {
        _showSnackBar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
        debugPrint('Login error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: isLargeScreen
                ? _buildLargeScreenLayout()
                : LoginWidget(
                    formKey: _formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    isChecked: isChecked,
                    isLoading: _isLoading,
                    onLogin: _login,
                    onRememberMeChanged: (newValue) {
                      setState(() {
                        isChecked = newValue;
                      });
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 600,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "lib/assets/images/image43.jpg",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: LoginWidget(
            formKey: _formKey,
            emailController: emailController,
            passwordController: passwordController,
            isChecked: isChecked,
            isLoading: _isLoading,
            onLogin: _login,
            onRememberMeChanged: (newValue) {
              setState(() {
                isChecked = newValue;
              });
            },
          ),
        ),
      ],
    );
  }
}
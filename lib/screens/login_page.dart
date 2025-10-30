import 'package:flutter/material.dart';
import 'package:project_web/controllers/loginController.dart';
import 'package:project_web/screens/admin_page.dart';
import 'package:project_web/screens/list_course_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/widgets/login_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_web/controllers/adminController.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>(); 
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController(); 
  
  bool? isChecked = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isFlipped = false; 

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    adminEmailController.dispose();
    adminPasswordController.dispose(); 
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolID = prefs.getString('schoolId');
    // Note: ควรตรวจสอบ Admin Token ด้วยหากมีการทำ Admin Login ถาวร
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

  // School Login (การทำงานเดิม)
  void _schoolLogin() async {
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
  
  // [MODIFIED] Admin Login (ใช้ AdminController)
  void _adminLogin() async {
    if (_adminFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      }); 

      String email = adminEmailController.text.trim();
      String password = adminPasswordController.text;

      try {
        // เรียกใช้ AdminController เพื่อตรวจสอบ Email/Password ผ่าน API
        final userData = await AdminController.adminLogin(email, password);

        if (userData != null) {
          // Login สำเร็จ
          _showSnackBar('เข้าสู่ระบบ Admin สำเร็จ: ${userData['name']}');
          
          // TODO: ควรบันทึก Admin data/token ใน SharedPreferences ที่นี่
          
          Navigator.pushReplacement(
            context,
            // นำทางไปยัง SchoolsPage
            MaterialPageRoute(builder: (context) => AdminPage()), 
          );
        } else {
          // ไม่พบผู้ใช้หรือรหัสผ่านไม่ถูกต้อง (ตรวจสอบแล้วใน AdminController)
          _showSnackBar('Admin: อีเมลหรือรหัสผ่านไม่ถูกต้อง');
        }
      } catch (e) {
        _showSnackBar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
        debugPrint('Admin Login error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
      _isLoading = false; 
    });
    emailController.clear();
    passwordController.clear();
    adminEmailController.clear();
    adminPasswordController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSchoolLoginWidget({Key? key}) {
    return LoginWidget(
      key: key,
      formKey: _formKey,
      emailController: emailController,
      passwordController: passwordController,
      isChecked: isChecked,
      isLoading: _isLoading,
      isSchoolLogin: true, 
      onLogin: _schoolLogin,
      onRememberMeChanged: (newValue) {
        setState(() {
          isChecked = newValue;
        });
      },
      onToggleFlip: _toggleFlip, 
    );
  }

  Widget _buildAdminLoginWidget({Key? key}) {
    return LoginWidget(
      key: key,
      formKey: _adminFormKey,
      emailController: adminEmailController,
      passwordController: adminPasswordController,
      isChecked: null,
      isLoading: _isLoading,
      isSchoolLogin: false, 
      onLogin: _adminLogin,
      onRememberMeChanged: (newValue) { /* Admin ไม่ต้องการ Remember Me */ },
      onToggleFlip: _toggleFlip, 
    );
  }

  // ฟังก์ชัน Transition Builder สำหรับแอนิเมชันพลิก 3D ที่ถูกต้อง
  Widget _flipTransitionBuilder(Widget child, Animation<double> animation) {
    final isBack = child.key == const ValueKey('admin') || child.key == const ValueKey('adminLarge');
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        double rotationAngle = _isFlipped 
            ? animation.value * 3.14159 
            : (1.0 - animation.value) * 3.14159; 
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) 
            ..rotateY(rotationAngle), 
          child: Opacity(
            opacity: animation.value < 0.5 ? (1.0 - animation.value * 2).clamp(0.0, 1.0) : (animation.value * 2 - 1.0).clamp(0.0, 1.0),
            child: isBack
                ? Transform(
                    // Mirroring for the back face (Admin) to correct text orientation
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159), 
                    child: child,
                  )
                : child,
          ),
        );
      },
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
                : AnimatedSwitcher( 
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: _flipTransitionBuilder, 
                    child: _isFlipped 
                        ? _buildAdminLoginWidget(key: const ValueKey('admin')) 
                        : _buildSchoolLoginWidget(key: const ValueKey('school')),
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: _flipTransitionBuilder, 
            child: _isFlipped 
                ? _buildAdminLoginWidget(key: const ValueKey('adminLarge')) 
                : _buildSchoolLoginWidget(key: const ValueKey('schoolLarge')),
          ),
        ),
      ],
    );
  }
}
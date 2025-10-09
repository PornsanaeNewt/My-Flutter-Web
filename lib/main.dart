import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_web/screens/regis_school_page.dart';
import 'package:project_web/services/custom_app_bar.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'package:project_web/styles/font-style.dart'; 

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

final List<String> imagePaths = [
  "lib/assets/images/picture3.jpg",
  "lib/assets/images/picture4.jpg",
  "lib/assets/images/picture5.jpg",
  "lib/assets/images/picture6.jpg",
  "lib/assets/images/picture7.jpg",
  "lib/assets/images/picture8.jpg",
  "lib/assets/images/picture9.jpg",
  "lib/assets/images/picture10.jpg",
  "lib/assets/images/picture11.jpg",
  "lib/assets/images/picture12.jpg",
];

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thai Cooking Course',
      theme: ThemeData(
        fontFamily: FontStyles.primaryFont,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String? _schoolID;
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); 
    _pageController = PageController(viewportFraction: 0.8); 
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('schoolID');
    if (mounted) { 
      setState(() {
        _schoolID = id;
      });
    }
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryButton, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: Text(
          'Login',
          style: TextStyles.button.copyWith(color: AppColors.primaryButton), 
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterSchoolPage()),
          );
        },
        child: Text(
          'Register',
          style: TextStyles.button.copyWith(color: Colors.white), 
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.formBackground,
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thai Cooking Course',
            style: TextStyles.title.copyWith(color: AppColors.primaryBlack, fontSize: FontStyles.heading),
          ),
          const SizedBox(height: 20),
          Text(
            'หลักสูตรของเรามีเป้าหมายเพื่อเผยแพร่มรดกทางอาหารไทยที่หลากหลายและลึกซึ้ง ให้ผู้เรียนได้เรียนรู้ตั้งแต่พื้นฐานจนถึงการทำอาหารที่ซับซ้อนภายใต้การดูแลของผู้เชี่ยวชาญ',
            style: TextStyles.body.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Links',
                    style: TextStyles.label.copyWith(color: AppColors.primaryBlack, fontWeight: FontStyles.semiBold),
                  ),
                  const SizedBox(height: 10),
                  Text('หน้าหลัก', style: TextStyles.link.copyWith(decoration: TextDecoration.none)),
                  const SizedBox(height: 5),
                  Text('เกี่ยวกับเรา', style: TextStyles.link.copyWith(decoration: TextDecoration.none)),
                  const SizedBox(height: 5),
                  Text('ติดต่อ', style: TextStyles.link.copyWith(decoration: TextDecoration.none)),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyles.label.copyWith(color: AppColors.primaryBlack, fontWeight: FontStyles.semiBold),
                  ),
                  const SizedBox(height: 10),
                  Text('Email: p4terpor@gmail.com', style: TextStyles.body.copyWith(color: AppColors.secondaryText)),
                  const SizedBox(height: 5),
                  Text('Phone: +66 80 240 3279', style: TextStyles.body.copyWith(color: AppColors.secondaryText)),
                  const SizedBox(height: 5),
                  Text('Address: Chiang mai, Thailand', style: TextStyles.body.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: AppColors.inputBorder, height: 1),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '© 2024 Thai Cooking Course. All rights reserved.',
              style: TextStyles.body.copyWith(fontSize: FontStyles.small, color: AppColors.secondaryText),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Correct usage of defined FontSizes for the title in the AppBar
    final appBarTitleStyle = TextStyles.title.copyWith(
      color: AppColors.primaryButton,
      fontSize: FontStyles.title, 
      fontWeight: FontStyles.semiBold,
    );

    return Scaffold(
      appBar: _schoolID != null
          ? CustomAppBar(activeMenu: 'หน้าหลัก') 
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryButton,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // Use the refined style
            Text(
              'Thai Cooking Course',
              style: appBarTitleStyle,
            ),
          ],
        ),
        actions: [
          _buildLoginButton(context),
          _buildRegisterButton(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 400.0,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.hasContentDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) * 400,
                          width: Curves.easeOut.transform(value) *
                              MediaQuery.of(context).size.width *
                              0.8,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: Image.asset(
                        imagePaths[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'ไม่พบรูปภาพ: ${imagePaths[index]}',
                              style: TextStyles.body.copyWith(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'ยินดีต้อนรับสู่หลักสูตรสอนทำอาหารไทย',
                style: TextStyles.title.copyWith(
                  color: AppColors.primaryButton, 
                  fontSize: FontStyles.heading, 
                  fontWeight: FontStyles.semiBold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'เรียนรู้และสร้างสรรค์เมนูอาหารไทยแท้ ด้วยวัตถุดิบคุณภาพและเทคนิคที่ถูกต้องจากเชฟผู้เชี่ยวชาญ เพื่อให้คุณสามารถนำเสน่ห์ของอาหารไทยไปสู่ครัวของคุณได้',
                style: TextStyles.body.copyWith(
                  fontSize: FontStyles.large,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
}
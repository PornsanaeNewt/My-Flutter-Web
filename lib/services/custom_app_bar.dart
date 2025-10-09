import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_web/screens/create_course_page.dart';
import 'package:project_web/screens/login_page.dart';
import 'package:project_web/screens/school_detail_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/screens/list_course_page.dart';
import 'package:project_web/screens/list_instructor_page.dart';
import 'package:project_web/controllers/appbarController.dart';
import 'package:project_web/services/SharedPreferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String activeMenu;

  const CustomAppBar({super.key, required this.activeMenu});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? _schoolID;
  String? _schoolName;
  String? _schoolEmail;
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    final id = await getSchoolID();
    setState(() {
      _schoolID = id;
    });

    if (_schoolID != null) {
      final schoolData = await AppbarController.fetchSchoolData(_schoolID!);
      if (mounted && schoolData != null) {
        setState(() {
          _schoolName = schoolData['schoolName'] ?? 'School';
          _schoolEmail = schoolData['schoolEmail'] ?? 'N/A';
        });
      }
    }
  }

  void _showProfileDropdown() {
    final RenderBox renderBox =
        _profileKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryButton,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _schoolName?.substring(0, 1) ?? '',
                    style: TextStyles.button.copyWith(
                      color: AppColors.buttonText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _schoolName ?? 'School',
                      style: TextStyles.body,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      _schoolEmail ?? 'N/A',
                      style: TextStyles.body.copyWith(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Text('รายละเอียดโรงเรียน'),
          onTap: () {
            if (_schoolID != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SchoolDetailPage(schoolID: _schoolID!),
                ),
              );
            }
          },
        ),
        PopupMenuItem(child: const Text('ตั้งค่า'), onTap: () {}),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
          onTap: () => AppbarController.logout(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.formBackground,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryButton,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: AppColors.buttonText),
          ),
          const SizedBox(width: 12),
          Text(
            'Thai Cooking Course',
            style: TextStyles.title.copyWith(color: AppColors.primaryButton),
          ),
        ],
      ),
      actions: [
        _buildNavItem(context, 'หลักสูตร'),
        _buildNavItem(context, 'ผู้สอน'),
        if (_schoolID != null) _buildNavItem(context, 'เพิ่มหลักสูตรใหม่'),
        if (_schoolID != null)
          GestureDetector(
            key: _profileKey,
            onTap: _showProfileDropdown,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.formBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  Text(_schoolName ?? 'School', style: TextStyles.body),
                ],
              ),
            ),
          )
        else
          _buildNavItem(context, 'Login'),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String label) {
    final bool isActive = widget.activeMenu == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          if (label == 'หลักสูตร') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ListCoursePage()),
            );
          } else if (label == 'ผู้สอน') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ListInstructorPage(),
              ),
            );
          } else if (label == 'เพิ่มหลักสูตรใหม่') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CreateCoursePage(schoolID: _schoolID ?? ''),
              ),
            );
          } else if (label == 'Login') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
        child: Text(
          label,
          style:
              isActive
                  ? TextStyles.navigationActive
                  : TextStyles.navigationInactive,
        ),
      ),
    );
  }
}

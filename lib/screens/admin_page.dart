import 'package:flutter/material.dart';
import 'package:project_web/controllers/adminController.dart';
import 'package:project_web/model/School.dart'; 
import 'package:project_web/services/admin_bar.dart'; 
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/font-style.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/controllers/schoolController.dart'; 
import 'package:project_web/controllers/courseController.dart'; 
import 'package:project_web/controllers/instructorController.dart'; 
import 'package:project_web/model/Course.dart'; 
import 'package:project_web/model/Instructor.dart'; 

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0); 
  
  List<School> _allSchools = [];
  List<School> _pendingSchools = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSchools(); 
  }

  Future<bool> _hasRelatedData(String schoolId) async {
    try {
      final List<Course> courses = await CourseController.fetchCoursesBySchoolId(schoolId);
      if (courses.isNotEmpty) {
        return true;
      }

      final List<Instructor> instructors = await InstructorController.loadInstructorsBySchool(schoolId);
      if (instructors.isNotEmpty) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking related data for school $schoolId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาดในการตรวจสอบข้อมูลหลักสูตร/ผู้สอน: $e'),
              backgroundColor: AppColors.errorColor, 
            ),
        );
      return true; 
    }
  }

  Future<void> _loadSchools() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final allSchoolsList = await AdminController.fetchSchools();
      
      if (mounted) {
        setState(() {
          _allSchools = allSchoolsList;
          _pendingSchools = allSchoolsList.where((s) => s.schoolStatus == 'wait').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String schoolId, String newStatus) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      await AdminController.updateSchoolStatus(schoolId, newStatus);
      await _loadSchools(); 
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Update failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSchool(String schoolId, String schoolName) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กำลังลบโรงเรียน $schoolName...')),
    );

    try {
      await SchoolController.deleteSchool(schoolId); 
      await _loadSchools();
      
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบโรงเรียน $schoolName สำเร็จแล้ว')),
      );

    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        setState(() {
          _errorMessage = 'Delete failed: $errorMsg';
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ลบโรงเรียน $schoolName ล้มเหลว: $errorMsg'),
              backgroundColor: AppColors.errorColor, 
            ),
        );
      }
      if (mounted) {
         setState(() => _isLoading = false);
      }
      return; 
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, String schoolName, bool hasRelatedData) async {
    final String contentText;
    final Widget deleteButton;
    
    if (hasRelatedData) {
      contentText = 'โรงเรียน $schoolName มีข้อมูลหลักสูตรหรือผู้สอนอยู่ คุณไม่สามารถลบโรงเรียนนี้ได้จนกว่าจะลบข้อมูลที่เกี่ยวข้องออกทั้งหมดก่อน';
      deleteButton = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.subtleGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: null,
        child: Text('ลบ (Disabled)', style: TextStyles.button.copyWith(color: AppColors.secondaryText)),
      );
    } else {
      contentText = 'คุณแน่ใจหรือไม่ว่าต้องการลบโรงเรียน $schoolName อย่างถาวร?';
      deleteButton = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: () => Navigator.of(context).pop(true),
        child: Text('ลบ', style: TextStyles.button.copyWith(color: Colors.white)), 
      );
    }
    
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.formBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            hasRelatedData ? 'ไม่สามารถลบโรงเรียนได้' : 'ยืนยันการลบโรงเรียน', 
            style: TextStyles.title.copyWith(fontSize: FontStyles.title)
          ),
          content: Text(contentText, style: TextStyles.body.copyWith(fontSize: FontStyles.medium)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('ยกเลิก', style: TextStyles.link.copyWith(decoration: TextDecoration.none, color: AppColors.secondaryText)),
            ),
            deleteButton,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground, 
      appBar: CustomAdminBar(
        selectedIndex: _selectedIndex,
        onRefresh: _loadSchools, 
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child) {
          if (_isLoading) { 
            return Center(child: CircularProgressIndicator(
              color: AppColors.primaryButton, 
            ));
          }

          if (_errorMessage.isNotEmpty) { 
            return Center(child: Text(_errorMessage, style: TextStyles.body.copyWith(color: Colors.red)));
          }

          final List<School> schoolsToShow = index == 0 ? _allSchools : _pendingSchools; 
          
          if (schoolsToShow.isEmpty) {
            return Center(child: Text('ไม่พบข้อมูลโรงเรียน', style: TextStyles.body));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12.0), 
            itemCount: schoolsToShow.length,
            itemBuilder: (context, index) {
              final school = schoolsToShow[index];
              
              return _SchoolCard(
                school: school, 
                onUpdateStatus: _updateStatus, 
                onDelete: (schoolId, schoolName) async {
                  final bool hasData = await _hasRelatedData(schoolId);
                  
                  final bool? confirm = await _showDeleteConfirmationDialog(context, schoolName, hasData);
                  
                  if (confirm != null && confirm && !hasData) {
                    _deleteSchool(schoolId, schoolName);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final School school;
  final Future<void> Function(String schoolId, String newStatus) onUpdateStatus; 
  final Future<void> Function(String schoolId, String schoolName) onDelete;

  const _SchoolCard({
    required this.school,
    required this.onUpdateStatus, 
    required this.onDelete, 
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = school.schoolStatus == 'active';
    final String imageUrl = 'http://localhost:3000/assets/school/${school.schoolPicture}';
    
    final String statusText;
    Color statusColor;
    
    if (school.schoolStatus == 'active') {
      statusText = 'ใช้งาน';
      statusColor = Colors.green.shade700;
    } else if (school.schoolStatus == 'wait') {
      statusText = 'รออนุมัติ';
      statusColor = AppColors.linkText;
    } else {
      statusText = 'ปิดใช้งาน'; 
      statusColor = AppColors.mutedBrown;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        color: AppColors.formBackground, 
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        child: InkWell( 
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            print('School ${school.schoolName} tapped.');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SchoolImage(
                  imageUrl: school.schoolPicture != null && school.schoolPicture!.isNotEmpty 
                    ? imageUrl 
                    : 'https://via.placeholder.com/150',
                ),
                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.schoolName ?? 'ไม่มีชื่อ',
                        style: TextStyles.title.copyWith(fontSize: FontStyles.large),
                      ),
                      SizedBox(height: 4),

                      Text(
                        school.schoolDetail ?? 'ไม่มีรายละเอียด',
                        style: TextStyles.body.copyWith(color: AppColors.secondaryText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'สถานะ: $statusText',
                          style: TextStyles.label.copyWith(
                            fontSize: FontStyles.small,
                            fontWeight: FontStyles.semiBold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 16),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusSwitch(
                      isActive: isActive,
                      schoolName: school.schoolName ?? 'นี้',
                      onToggle: (bool newValue) async {
                        if (newValue) {
                          final bool? confirm = await _showConfirmationDialog(context, school.schoolName!);
                          if (confirm != null && confirm) {
                            onUpdateStatus(school.schoolId!, 'active'); 
                          }
                        } else {
                          onUpdateStatus(school.schoolId!, 'wait'); 
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_forever, color: AppColors.errorColor, size: FontStyles.heading),
                      onPressed: () => onDelete(school.schoolId!, school.schoolName!),
                      tooltip: 'ลบโรงเรียน',
                      padding: EdgeInsets.zero, 
                      alignment: Alignment.centerRight,
                      constraints: BoxConstraints(), 
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<bool?> _showConfirmationDialog(BuildContext context, String schoolName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.formBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('ยืนยันการเปิดสถานะ', style: TextStyles.title.copyWith(fontSize: FontStyles.title)),
          content: Text('คุณต้องการเปิดสถานะของโรงเรียน $schoolName หรือไม่?', style: TextStyles.body.copyWith(fontSize: FontStyles.medium)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('ยกเลิก', style: TextStyles.link.copyWith(decoration: TextDecoration.none, color: AppColors.secondaryText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('ยืนยัน', style: TextStyles.button),
            ),
          ],
        );
      },
    );
  }
}

class _SchoolImage extends StatelessWidget {
  final String imageUrl;
  
  const _SchoolImage({required this.imageUrl});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.subtleGray, 
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.school_outlined, 
              color: AppColors.secondaryText, 
              size: 40
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusSwitch extends StatelessWidget {
  final bool isActive;
  final String schoolName;
  final Function(bool) onToggle;

  const _StatusSwitch({
    required this.isActive,
    required this.schoolName,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          isActive ? 'เปิดใช้งาน' : 'รออนุมัติ',
          style: TextStyles.label.copyWith(
            fontSize: FontStyles.small,
            color: isActive ? Colors.green.shade700 : AppColors.mutedBrown,
            fontWeight: FontStyles.semiBold,
          ),
        ),
        SizedBox(height: 4),
        Switch(
          value: isActive,
          activeColor: Colors.green, 
          inactiveThumbColor: AppColors.secondaryText, 
          inactiveTrackColor: AppColors.inputBorder,
          onChanged: onToggle,
        ),
      ],
    );
  }
}
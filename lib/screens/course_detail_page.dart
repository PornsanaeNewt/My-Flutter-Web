import 'package:flutter/material.dart';
import 'package:project_web/controllers/courseController.dart';
import 'package:project_web/controllers/reviewController.dart';
import 'package:project_web/model/Course.dart';
import 'package:project_web/model/CourseDetail.dart';
import 'package:project_web/model/Instructor.dart';
import 'package:project_web/screens/list_course_page.dart';
import 'package:project_web/screens/list_registration_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_web/screens/edit_course_page.dart';
import 'dart:async';

class CourseDetailPage extends StatefulWidget {
  final String courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  // [START] Scroll Control Variables
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  bool _showRightButton = false;
  // [END] Scroll Control Variables

  Course? _course;
  List<String> _imageUrls = [];
  List<CourseDetail> _courseDetails = [];
  List<Instructor> _instructors = [];
  Map<String, String> _instructorNames = {};
  int? schId;

  List<dynamic> _reviews = [];
  bool _isReviewsLoading = true;

  bool _isLoading = true;
  String? _error;
  String? _courseType;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th', null);
    _fetchData();
    _fetchReviews();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollPosition();
    });
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const double tolerance = 0.5;

    bool canScroll = maxScroll > 0;

    setState(() {
      if (!canScroll) {
        _showLeftButton = false;
        _showRightButton = false;
        return;
      }
      _showLeftButton = currentScroll > tolerance;
      _showRightButton = currentScroll < maxScroll - tolerance;
    });
  }

  void _scroll(bool isRight) {
    if (!_scrollController.hasClients) return;

    final currentScroll = _scrollController.offset;
    // เลื่อนทีละ 60% ของความกว้างที่มองเห็นได้
    final scrollAmount = context.size!.width * 0.4;

    double targetScroll;

    if (isRight) {
      targetScroll = currentScroll + scrollAmount;
    } else {
      targetScroll = currentScroll - scrollAmount;
    }

    _scrollController.animateTo(
      targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLeft,
  }) {
    final double horizontalPadding = isLeft ? 10 : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Card(
        elevation: 6,
        shape: const CircleBorder(),
        color: AppColors.formBackground.withOpacity(0.9),
        child: IconButton(
          icon: Icon(icon, color: AppColors.primaryBlack, size: 20),
          onPressed: onPressed,
          padding: const EdgeInsets.all(8),
          splashRadius: 24,
        ),
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _course = await CourseController.fetchCourseById(widget.courseId);

      if (_course == null) {
        _error = 'ไม่พบข้อมูลหลักสูตร';
        return;
      }
      _courseType = await CourseController.fetchCourseTypeName(
        _course!.courseTypeId,
      );

      _imageUrls = await CourseController.fetchCourseImages(widget.courseId);

      _courseDetails = await CourseController.fetchCourseDetails(
        widget.courseId,
      );

      final prefs = await SharedPreferences.getInstance();
      final schoolID = prefs.getString('schoolID');
      if (schoolID != null) {
        _instructors = await CourseController.fetchInstructors(schoolID);
        _instructorNames = {
          for (var inst in _instructors)
            inst.instructorId!:
                '${inst.instructorName} ${inst.instructorLname}',
        };
      } else {
        print('คำเตือน: ไม่พบ School ID, ไม่สามารถโหลดผู้สอนได้');
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _checkScrollPosition(),
      );
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการดึงข้อมูล: $e';
      print('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, [Color backgroundColor = Colors.black]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyles.body.copyWith(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    try {
      await CourseController.deleteSchedule(scheduleId);
      _showSnackBar('กำหนดการถูกลบสำเร็จ', AppColors.primaryBlack);
      _fetchData();
    } catch (e) {
      _showSnackBar(
        'เกิดข้อผิดพลาดในการลบกำหนดการ: $e',
        AppColors.primaryBlack,
      );
    }
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isReviewsLoading = true;
    });
    try {
      final reviewsJson = await ReviewService().fetchReviewsByCourse(
        widget.courseId,
      );
      print("Review Form Json : $reviewsJson");
      setState(() {
        _reviews = reviewsJson;
        _isReviewsLoading = false;
      });
    } catch (e) {
      print('Failed to load reviews: $e');
      setState(() {
        _reviews = [];
        _isReviewsLoading = false;
      });
    }
  }

  void _confirmDeleteSchedule(CourseDetail schedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบกำหนดการ'),
          content: const Text('คุณต้องการลบกำหนดการนี้ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSchedule(schedule.id);
              },
              child: Text(
                'ลบ',
                style: TextStyle(color: AppColors.primaryBlack),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _addOrEditSchedule({CourseDetail? scheduleToEdit}) async {
    final _scheduleFormKey = GlobalKey<FormState>();
    final _capacityController = TextEditingController(
      text: scheduleToEdit?.capacity.toString() ?? '',
    );
    final _studyTimeController = TextEditingController(
      text: scheduleToEdit?.time.toString() ?? '',
    );
    final _regisOpenController = TextEditingController();
    final _regisCloseController = TextEditingController();
    final _startDateController = TextEditingController();
    final _endDateController = TextEditingController();

    if (scheduleToEdit != null) {
      final dateFormat = DateFormat('yyyy-MM-dd');
      _regisOpenController.text = dateFormat.format(
        DateTime.parse(scheduleToEdit.registOpen).toLocal(),
      );
      _regisCloseController.text = dateFormat.format(
        DateTime.parse(scheduleToEdit.registClose).toLocal(),
      );
      _startDateController.text = dateFormat.format(
        DateTime.parse(scheduleToEdit.startDate).toLocal(),
      );
      _endDateController.text = dateFormat.format(
        DateTime.parse(scheduleToEdit.endDate).toLocal(),
      );
    }

    String? _dialogSelectedInstructorId =
        scheduleToEdit?.instructorId ??
        (_instructors.isNotEmpty ? _instructors.first.instructorId : null);

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                scheduleToEdit == null ? 'เพิ่มกำหนดการใหม่' : 'แก้ไขกำหนดการ',
                style: TextStyles.title.copyWith(fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _scheduleFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ผู้สอน', style: TextStyles.label),
                          const SizedBox(height: 8),
                          _instructors.isEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'ไม่พบข้อมูลผู้สอนสำหรับโรงเรียนนี้',
                                  style: TextStyles.body.copyWith(
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              )
                              : DropdownButtonFormField<String>(
                                value: _dialogSelectedInstructorId,
                                style: TextStyles.input,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.formBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.inputFocusedBorder,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                items:
                                    _instructors.map((instructor) {
                                      return DropdownMenuItem<String>(
                                        value: instructor.instructorId,
                                        child: Text(
                                          '${instructor.instructorName} ${instructor.instructorLname}',
                                          style: TextStyles.input,
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? value) {
                                  setDialogState(() {
                                    _dialogSelectedInstructorId = value;
                                  });
                                  _regisOpenController.clear();
                                  _regisCloseController.clear();
                                  _startDateController.clear();
                                  _endDateController.clear();
                                },
                                validator:
                                    (value) =>
                                        value == null
                                            ? 'กรุณาเลือกผู้สอน'
                                            : null,
                              ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _capacityController,
                        label: 'จำนวนที่นั่ง',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null ||
                              int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'กรุณากรอกความจุให้ถูกต้อง (ตัวเลขจำนวนเต็มบวก)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _regisOpenController,
                              label: 'วันที่เปิดลงทะเบียน',
                              readOnly: true,
                              onTap: () async {
                                final DateTime? regisCloseDate =
                                    DateTime.tryParse(
                                      _regisCloseController.text,
                                    );
                                final picked = await _selectDate(
                                  context,
                                  _regisOpenController,
                                  lastSelectableDate: regisCloseDate?.subtract(
                                    const Duration(days: 1),
                                  ),
                                );
                                if (picked != null) {
                                  _regisOpenController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                  setDialogState(() {});
                                }
                              },
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColors.secondaryText,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาเลือกวันที่';
                                }
                                final regisOpenDate = DateTime.tryParse(value);
                                final regisCloseDate = DateTime.tryParse(
                                  _regisCloseController.text,
                                );
                                if (regisOpenDate != null &&
                                    regisCloseDate != null &&
                                    regisOpenDate.isAfter(regisCloseDate)) {
                                  return 'วันที่เปิดลงทะเบียนต้องก่อนวันที่ปิดลงทะเบียน';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _regisCloseController,
                              label: 'วันที่ปิดลงทะเบียน',
                              readOnly: true,
                              onTap: () async {
                                final DateTime? regisOpenDate =
                                    DateTime.tryParse(
                                      _regisOpenController.text,
                                    );
                                final picked = await _selectDate(
                                  context,
                                  _regisCloseController,
                                  firstSelectableDate: regisOpenDate?.add(
                                    const Duration(days: 1),
                                  ),
                                );
                                if (picked != null) {
                                  _regisCloseController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                  setDialogState(() {});
                                }
                              },
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColors.secondaryText,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาเลือกวันที่';
                                }
                                final regisOpenDate = DateTime.tryParse(
                                  _regisOpenController.text,
                                );
                                final regisCloseDate = DateTime.tryParse(value);

                                if (regisOpenDate != null &&
                                    regisCloseDate != null &&
                                    regisCloseDate.isBefore(regisOpenDate)) {
                                  return 'วันที่ปิดลงทะเบียนต้องหลังวันที่เปิดลงทะเบียน';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _startDateController,
                              label: 'วันที่เริ่มเรียน',
                              readOnly: true,
                              onTap: () async {
                                final DateTime? regisCloseDate =
                                    DateTime.tryParse(
                                      _regisCloseController.text,
                                    );
                                final DateTime? endDate = DateTime.tryParse(
                                  _endDateController.text,
                                );
                                final picked = await _selectDate(
                                  context,
                                  _startDateController,
                                  firstSelectableDate: regisCloseDate?.add(
                                    const Duration(days: 1),
                                  ),
                                  lastSelectableDate: endDate?.subtract(
                                    const Duration(days: 1),
                                  ),
                                );
                                if (picked != null) {
                                  _startDateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                  setDialogState(() {});
                                }
                              },
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColors.secondaryText,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาเลือกวันที่';
                                }
                                final regisCloseDate = DateTime.tryParse(
                                  _regisCloseController.text,
                                );
                                final startDate = DateTime.tryParse(value);

                                if (regisCloseDate != null &&
                                    startDate != null &&
                                    startDate.isBefore(regisCloseDate)) {
                                  return 'วันที่เริ่มหลักสูตรต้องหลังวันที่ปิดลงทะเบียน';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _endDateController,
                              label: 'วันที่สิ้นสุดการเรียน',
                              readOnly: true,
                              onTap: () async {
                                final DateTime? startDate = DateTime.tryParse(
                                  _startDateController.text,
                                );
                                final picked = await _selectDate(
                                  context,
                                  _endDateController,
                                  firstSelectableDate: startDate?.add(
                                    const Duration(days: 1),
                                  ),
                                );
                                if (picked != null) {
                                  _endDateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                  setDialogState(() {});
                                }
                              },
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColors.secondaryText,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาเลือกวันที่';
                                }
                                final startDate = DateTime.tryParse(
                                  _startDateController.text,
                                );
                                final endDate = DateTime.tryParse(value);

                                if (startDate != null &&
                                    endDate != null &&
                                    endDate.isBefore(startDate)) {
                                  return 'วันที่สิ้นสุดหลักสูตรต้องหลังวันที่เริ่มหลักสูตร';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _studyTimeController,
                              label: 'เวลาเรียน (ชั่วโมง)',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาใส่เวลาเรียน';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('ยกเลิก'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_scheduleFormKey.currentState!.validate() &&
                        _dialogSelectedInstructorId != null) {
                      if (await CourseController.checkInstructorScheduleOverlap(
                        _dialogSelectedInstructorId!,
                        _startDateController.text,
                        _endDateController.text,
                        scheduleToEdit?.id,
                      )) {
                        _showSnackBar(
                          'ผู้สอนมีกำหนดการทับซ้อนในช่วงเวลานี้',
                          Colors.black,
                        );
                        return;
                      }

                      final scheduleData = CourseDetail(
                        id: scheduleToEdit?.id ?? 0,
                        capacity: int.parse(_capacityController.text),
                        endDate: _endDateController.text,
                        registClose: _regisCloseController.text,
                        registOpen: _regisOpenController.text,
                        scheduleStatus:
                            scheduleToEdit?.scheduleStatus ?? 'open',
                        startDate: _startDateController.text,
                        time: double.parse(_studyTimeController.text),
                        courseId: widget.courseId,
                        instructorId: _dialogSelectedInstructorId!,
                      );
                      try {
                        if (scheduleToEdit == null) {
                          await CourseController.addSchedule(scheduleData);
                        } else {
                          await CourseController.updateSchedule(scheduleData);
                        }
                        Navigator.of(context).pop(true);
                      } catch (e) {
                        _showSnackBar('เกิดข้อผิดพลาด: $e', Colors.red);
                        Navigator.of(context).pop(false);
                      }
                    } else if (_dialogSelectedInstructorId == null &&
                        _instructors.isNotEmpty) {
                      setDialogState(() {});
                    }
                  },
                  child: Text(scheduleToEdit == null ? 'เพิ่ม' : 'บันทึก'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkAccent,
                    foregroundColor: AppColors.buttonText,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openAndCloseSchedule(CourseDetail schedule, bool isOpen) async {
    String newStatus = isOpen ? 'open' : 'close';
    try {
      await CourseController.openAndCloseSchedule(schedule.id, newStatus);
      _showSnackBar(
        'อัปเดตสถานะกำหนดการเป็น "$newStatus" สำเร็จ',
        AppColors.primaryBlack,
      );
      _fetchData();
    } catch (e) {
      _showSnackBar(
        'เกิดข้อผิดพลาดในการอัปเดตสถานะกำหนดการ: $e',
        AppColors.primaryBlack,
      );
    }
  }

  Future<DateTime?> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? firstSelectableDate,
    DateTime? lastSelectableDate,
  }) async {
    DateTime? initialDate = DateTime.tryParse(controller.text);
    if (initialDate == null) {
      initialDate = DateTime.now();
    } else {
      initialDate = initialDate.toLocal();
    }

    if (firstSelectableDate != null &&
        initialDate.isBefore(firstSelectableDate)) {
      initialDate = firstSelectableDate;
    }
    if (lastSelectableDate != null && initialDate.isAfter(lastSelectableDate)) {
      initialDate = lastSelectableDate;
    }

    DateTime effectiveFirstDate = firstSelectableDate ?? DateTime(2000);
    DateTime effectiveLastDate = lastSelectableDate ?? DateTime(2101);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      locale: const Locale('th', 'TH'),
    );
    return picked;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.formBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.inputFocusedBorder,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('รายละเอียดหลักสูตร')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _error!,
              style: TextStyles.body.copyWith(color: AppColors.primaryBlack),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    if (_course == null) {
      return const Scaffold(body: Center(child: Text('ไม่พบข้อมูลหลักสูตร')));
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          'ข้อมูลหลักสูตร',
          style: TextStyles.title.copyWith(
            color: AppColors.primaryBlack,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.formBackground,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ListCoursePage()),
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รูปภาพหลักสูตร',
                  style: TextStyles.title.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 20),
                if (_imageUrls.isNotEmpty)
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          child: Row(
                            children:
                                _imageUrls.map((url) {
                                  return Container(
                                    width: 300,
                                    height: 250,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.inputBorder,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.shadowColor
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(
                                      'http://localhost:3000/assets/course/$url',
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 50,
                                            color: AppColors.secondaryText,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        if (_showLeftButton)
                          Positioned(
                            left: 0,
                            child: _buildScrollButton(
                              icon: Icons.arrow_back_ios_new,
                              onPressed: () => _scroll(false),
                              isLeft: true,
                            ),
                          ),

                        if (_showRightButton)
                          Positioned(
                            right: 0,
                            child: _buildScrollButton(
                              icon: Icons.arrow_forward_ios,
                              onPressed: () => _scroll(true),
                              isLeft: false,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Text(
                    'ไม่มีรูปภาพสำหรับหลักสูตรนี้',
                    style: TextStyles.body.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                const SizedBox(height: 40),

                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppColors.formBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ข้อมูลทั่วไปของหลักสูตร',
                              style: TextStyles.title.copyWith(fontSize: 22),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            EditCoursePage(course: _course!),
                                  ),
                                );
                                if (result == true) {
                                  _fetchData();
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                color: AppColors.buttonText,
                                size: 18,
                              ),
                              label: Text(
                                'แก้ไขหลักสูตร',
                                style: TextStyles.button.copyWith(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30, color: AppColors.inputBorder),
                        _buildInfoField('ชื่อหลักสูตร', _course!.name),
                        _buildInfoField(
                          'รายละเอียด',
                          _course!.description,
                          maxLines: null,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoField(
                                'ราคา',
                                '${_course!.price?.toStringAsFixed(2) ?? 'N/A'} บาท',
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildInfoField(
                                'ประเภทหลักสูตร',
                                _courseType.toString(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'รายการกำหนดการ',
                      style: TextStyles.title.copyWith(fontSize: 22),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await _addOrEditSchedule();
                        if (result == true) {
                          _fetchData();
                        }
                      },
                      icon: Icon(
                        Icons.add,
                        color: AppColors.buttonText,
                        size: 18,
                      ),
                      label: Text(
                        'เพิ่มกำหนดการ',
                        style: TextStyles.button.copyWith(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildScheduleList(),
                const SizedBox(height: 40),

                _buildReviewSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String? value, {int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.label.copyWith(color: AppColors.mutedBrown),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.lightAccent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Text(
              value ?? 'N/A',
              style: TextStyles.body.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w500,
              ),
              maxLines: maxLines,
              overflow:
                  maxLines == null
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_courseDetails.isEmpty) {
      return Center(
        child: Text(
          'ไม่มีกำหนดการสำหรับหลักสูตรนี้',
          style: TextStyles.body.copyWith(color: AppColors.secondaryText),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _courseDetails.length,
      itemBuilder: (context, index) {
        final schedule = _courseDetails[index];
        final instructorName =
            _instructorNames[schedule.instructorId] ?? 'ไม่พบผู้สอน';

        String formattedRegistOpen = '';
        String formattedRegistClose = '';
        String formattedStartDate = '';
        String formattedEndDate = '';

        try {
          formattedRegistOpen = DateFormat(
            'd MMMM y',
            'th',
          ).format(DateTime.parse(schedule.registOpen).toLocal());
        } catch (e) {
          formattedRegistOpen = schedule.registOpen;
        }
        try {
          formattedRegistClose = DateFormat(
            'd MMMM y',
            'th',
          ).format(DateTime.parse(schedule.registClose).toLocal());
        } catch (e) {
          formattedRegistClose = schedule.registClose;
        }
        try {
          formattedStartDate = DateFormat(
            'd MMMM y',
            'th',
          ).format(DateTime.parse(schedule.startDate).toLocal());
        } catch (e) {
          formattedStartDate = schedule.startDate;
        }
        try {
          formattedEndDate = DateFormat(
            'd MMMM y',
            'th',
          ).format(DateTime.parse(schedule.endDate).toLocal());
        } catch (e) {
          formattedEndDate = schedule.endDate;
        }

        return FutureBuilder<int>(
          future: CourseController.fetchRegistrationCount(schedule.id),
          builder: (context, snapshot) {
            int registrationCount = snapshot.data ?? 0;

            bool currentScheduleStatus = schedule.scheduleStatus == 'open';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.formBackground,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ผู้สอน: ${instructorName}',
                          style: TextStyles.label.copyWith(
                            color: AppColors.primaryBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              currentScheduleStatus
                                  ? 'เปิดลงทะเบียน'
                                  : 'ปิดลงทะเบียน',
                              style: TextStyles.body.copyWith(
                                color:
                                    currentScheduleStatus
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Switch(
                              value: currentScheduleStatus,
                              onChanged: (bool value) {
                                _openAndCloseSchedule(schedule, value);
                              },
                              activeColor: Colors.green.shade600,
                              inactiveTrackColor: Colors.red.shade200,
                              inactiveThumbColor: Colors.red.shade600,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.subtleGray),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildScheduleDetailItem(
                          Icons.schedule,
                          'เวลาเรียน',
                          '${schedule.time} ชั่วโมง',
                        ),
                        _buildScheduleDetailItem(
                          Icons.group,
                          'จำนวนที่นั่ง',
                          '$registrationCount / ${schedule.capacity}',
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ListRegistrationPage(
                                      scheduleId: schedule.id,
                                    ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.people_outline,
                            size: 18,
                            color: AppColors.buttonText,
                          ),
                          label: Text(
                            'รายชื่อผู้ลงทะเบียน',
                            style: TextStyles.button.copyWith(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildScheduleTimeItem(
                      Icons.date_range,
                      'เปิดลงทะเบียน',
                      '$formattedRegistOpen - $formattedRegistClose',
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildScheduleTimeItem(
                          Icons.school,
                          'วันที่เรียน',
                          '$formattedStartDate - $formattedEndDate',
                          isExpanded: true,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: AppColors.mutedBrown,
                              ),
                              tooltip: 'แก้ไขกำหนดการ',
                              onPressed: () async {
                                final result = await _addOrEditSchedule(
                                  scheduleToEdit: schedule,
                                );
                                if (result == true) {
                                  _fetchData();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade700,
                              ),
                              tooltip: 'ลบกำหนดการ',
                              onPressed: () => _confirmDeleteSchedule(schedule),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondaryText),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyles.body.copyWith(color: AppColors.secondaryText),
        ),
        Text(
          value,
          style: TextStyles.body.copyWith(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTimeItem(
    IconData icon,
    String label,
    String value, {
    bool isExpanded = false,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.mutedBrown),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyles.body.copyWith(
            color: AppColors.mutedBrown,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyles.body.copyWith(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    return isExpanded ? Expanded(child: content) : content;
  }

  Widget _buildReviewSection() {
    if (_isReviewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความคิดเห็นจากผู้เรียน',
          style: TextStyles.title.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 20),
        if (_reviews.isEmpty)
          Center(
            child: Text(
              'ยังไม่มีความคิดเห็นสำหรับหลักสูตรนี้',
              style: TextStyles.body.copyWith(color: AppColors.secondaryText),
            ),
          )
        else
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final reviewMap = _reviews[index] as Map<String, dynamic>;
                final reviewPoint =
                    (reviewMap['reviewPoint'] as num).toDouble();

                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: AppColors.formBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryButton,
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.buttonText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${reviewMap['stuName']} ${reviewMap['stuLname']}',
                                style: TextStyles.label.copyWith(
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < reviewPoint
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber.shade600,
                                size: 22,
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              reviewMap['reviews'] as String,
                              style: TextStyles.body.copyWith(
                                color: AppColors.primaryBlack,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

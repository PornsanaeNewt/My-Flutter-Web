import 'package:flutter/material.dart';
import 'package:project_web/controllers/courseController.dart';
import 'package:project_web/controllers/reviewController.dart';
import 'package:project_web/model/Course.dart';
import 'package:project_web/model/CourseDetail.dart';
import 'package:project_web/model/Instructor.dart';
import 'package:project_web/screens/list_course_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'package:project_web/widgets/course_detail_widget.dart';
import 'package:project_web/widgets/instructorSchedule_widget.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  bool _showRightButton = false;

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

  String? _selectedInstructorId;

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
        if (_instructors.isNotEmpty && _selectedInstructorId == null) {
          _selectedInstructorId = _instructors.first.instructorId;
        }
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
      final reviewsJson = await ReviewController().fetchReviewsByCourse(
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

  Future<DateTime?> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? firstSelectableDate,
    DateTime? lastSelectableDate,
  }) async {
    DateTime effectiveFirstDate = firstSelectableDate ?? DateTime(2000);
    DateTime effectiveLastDate = lastSelectableDate ?? DateTime(2101);

    DateTime initialDate;
    try {
      initialDate = DateTime.parse(controller.text).toLocal();
    } catch (_) {
      initialDate = DateTime.now();
    }

    if (initialDate.isBefore(effectiveFirstDate)) {
      initialDate = effectiveFirstDate;
    } else if (initialDate.isAfter(effectiveLastDate)) {
      initialDate = effectiveLastDate;
    }

    initialDate = DateUtils.dateOnly(initialDate);
    effectiveFirstDate = DateUtils.dateOnly(effectiveFirstDate);
    effectiveLastDate = DateUtils.dateOnly(effectiveLastDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      locale: const Locale('th', 'TH'),
    );
    return picked;
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

    final dateFormat = DateFormat('yyyy-MM-dd');

    if (scheduleToEdit != null) {
      try {
        _regisOpenController.text = dateFormat.format(
          DateTime.parse(scheduleToEdit.registOpen).toLocal(),
        );
      } catch (e) {
        print(
          'Error parsing registOpen date: ${scheduleToEdit.registOpen}, Error: $e',
        );
      }
      try {
        _regisCloseController.text = dateFormat.format(
          DateTime.parse(scheduleToEdit.registClose).toLocal(),
        );
      } catch (e) {
        print(
          'Error parsing registClose date: ${scheduleToEdit.registClose}, Error: $e',
        );
      }
      try {
        _startDateController.text = dateFormat.format(
          DateTime.parse(scheduleToEdit.startDate).toLocal(),
        );
      } catch (e) {
        print(
          'Error parsing startDate date: ${scheduleToEdit.startDate}, Error: $e',
        );
      }
      try {
        _endDateController.text = dateFormat.format(
          DateTime.parse(scheduleToEdit.endDate).toLocal(),
        );
      } catch (e) {
        print(
          'Error parsing endDate date: ${scheduleToEdit.endDate}, Error: $e',
        );
      }
    }

    String? _dialogSelectedInstructorId =
        scheduleToEdit?.instructorId ??
        (_instructors.isNotEmpty ? _instructors.first.instructorId : null);

    List<CourseDetail> _dialogSelectedInstructorSchedules = [];
    bool _isDialogScheduleLoading = false;

    Future<void> _fetchDialogInstructorSchedule(String instructorId) async {
      try {
        _isDialogScheduleLoading = true;
        _dialogSelectedInstructorSchedules =
            await CourseController.fetchCourseDetailsByInstructorId(
              instructorId,
            );
      } catch (e) {
        print('Error fetching dialog instructor schedule: $e');
        _dialogSelectedInstructorSchedules = [];
      } finally {
        _isDialogScheduleLoading = false;
      }
    }

    if (_dialogSelectedInstructorId != null) {
      await _fetchDialogInstructorSchedule(_dialogSelectedInstructorId);
    }

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000.0),
              child: AlertDialog(
                title: Text(
                  scheduleToEdit == null
                      ? 'สร้างกำหนดการลงทะเบียนใหม'
                      : 'แก้ไขกำหนดการ',
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
                                  onChanged: (String? value) async {
                                    if (value != null) {
                                      setDialogState(() {
                                        _dialogSelectedInstructorId = value;
                                        _isDialogScheduleLoading = true;
                                      });
                                      await _fetchDialogInstructorSchedule(
                                        value,
                                      );
                                      setDialogState(() {
                                        _isDialogScheduleLoading = false;
                                      });
                                    }
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
                        if (_dialogSelectedInstructorId != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ตารางสอนผู้สอน',
                                style: TextStyles.label,
                              ),
                              const SizedBox(height: 8),
                              InstructorScheduleCalendar(
                                instructorId: _dialogSelectedInstructorId,
                                schedules: _dialogSelectedInstructorSchedules,
                                isLoading: _isDialogScheduleLoading,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
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
                                      _regisCloseController.text.isNotEmpty
                                          ? dateFormat.tryParse(
                                            _regisCloseController.text,
                                          )
                                          : null;

                                  final picked = await _selectDate(
                                    context,
                                    _regisOpenController,
                                    lastSelectableDate: regisCloseDate
                                        ?.subtract(const Duration(days: 1)),
                                  );
                                  if (picked != null) {
                                    _regisOpenController.text = dateFormat
                                        .format(picked);
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
                                  final regisOpenDate = dateFormat.tryParse(
                                    value,
                                  );
                                  final regisCloseDate = dateFormat.tryParse(
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
                                      _regisOpenController.text.isNotEmpty
                                          ? dateFormat.tryParse(
                                            _regisOpenController.text,
                                          )
                                          : null;
                                  final DateTime? startDate =
                                      _startDateController.text.isNotEmpty
                                          ? dateFormat.tryParse(
                                            _startDateController.text,
                                          )
                                          : null;
                                  final picked = await _selectDate(
                                    context,
                                    _regisCloseController,
                                    firstSelectableDate: regisOpenDate?.add(
                                      const Duration(days: 1),
                                    ),
                                    lastSelectableDate: startDate?.subtract(
                                      const Duration(days: 1),
                                    ),
                                  );
                                  if (picked != null) {
                                    _regisCloseController.text = dateFormat
                                        .format(picked);
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
                                  final regisOpenDate = dateFormat.tryParse(
                                    _regisOpenController.text,
                                  );
                                  final regisCloseDate = dateFormat.tryParse(
                                    value,
                                  );

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
                                      _regisCloseController.text.isNotEmpty
                                          ? dateFormat.tryParse(
                                            _regisCloseController.text,
                                          )
                                          : null;
                                  final DateTime? endDate =
                                      _endDateController.text.isNotEmpty
                                          ? dateFormat.tryParse(
                                            _endDateController.text,
                                          )
                                          : null;

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
                                    _startDateController.text = dateFormat
                                        .format(picked);
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
                                  final regisCloseDate = dateFormat.tryParse(
                                    _regisCloseController.text,
                                  );
                                  final startDate = dateFormat.tryParse(value);

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
                                  final DateTime? startDate =
                                      _startDateController.text.isNotEmpty
                                          ? dateFormat.tryParse(
                                            _startDateController.text,
                                          )
                                          : null;
                                  final picked = await _selectDate(
                                    context,
                                    _endDateController,
                                    firstSelectableDate: startDate?.add(
                                      const Duration(days: 1),
                                    ),
                                  );
                                  if (picked != null) {
                                    _endDateController.text = dateFormat.format(
                                      picked,
                                    );
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
                                  final startDate = dateFormat.tryParse(
                                    _startDateController.text,
                                  );
                                  final endDate = dateFormat.tryParse(value);

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
              ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original calendar section removed
            CourseDetailBody(
              course: _course!,
              courseType: _courseType!,
              imageUrls: _imageUrls,
              courseDetails: _courseDetails,
              instructorNames: _instructorNames,
              reviews: _reviews,
              isReviewsLoading: _isReviewsLoading,
              scrollController: _scrollController,
              showLeftButton: _showLeftButton,
              showRightButton: _showRightButton,
              onScrollLeft: () => _scroll(false),
              onScrollRight: () => _scroll(true),
              onEditCourse: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCoursePage(course: _course!),
                  ),
                );
                if (result == true) {
                  _fetchData();
                }
              },
              onAddSchedule: () async {
                final result = await _addOrEditSchedule();
                if (result == true) {
                  _fetchData();
                }
              },
              onEditSchedule: (schedule) async {
                final result = await _addOrEditSchedule(
                  scheduleToEdit: schedule,
                );
                if (result == true) {
                  _fetchData();
                }
              },
              onDeleteSchedule: _confirmDeleteSchedule,
              onOpenCloseSchedule: _openAndCloseSchedule,
            ),
          ],
        ),
      ),
    );
  }
}

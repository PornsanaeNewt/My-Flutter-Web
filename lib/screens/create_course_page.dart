import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:project_web/controllers/courseController.dart';
import 'package:project_web/model/CourseDetail.dart';
import 'package:project_web/model/Instructor.dart';
import 'package:project_web/screens/list_course_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/widgets/create_course_widget.dart';
import 'package:project_web/widgets/instructorSchedule_widget.dart';

class CreateCoursePage extends StatefulWidget {
  final String schoolID;
  const CreateCoursePage({super.key, required this.schoolID});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedType;
  int? _selectedTypeId;
  List<XFile> _pickedImageFiles = [];
  List<Uint8List> _imageBytesList = [];
  final ImagePicker _picker = ImagePicker();

  String? _schoolID;
  List<Map<String, dynamic>> _courseTypes = [];
  bool _isLoadingTypes = true;

  List<CourseDetail> _courseSchedules = [];
  List<Instructor> _instructors = [];
  bool _isLoadingInstructors = true;

  @override
  void initState() {
    super.initState();
    _schoolID = widget.schoolID;
    _idController.text = CourseController.generateNewCourseId();
    _loadCourseTypes();
    _loadInstructors();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _detailController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseTypes() async {
    try {
      final types = await CourseController.loadCourseTypes();
      setState(() {
        _courseTypes = types;
        _isLoadingTypes = false;
        if (_courseTypes.isNotEmpty) {
          _selectedType = _courseTypes.first['courseType'];
          _selectedTypeId = _courseTypes.first['courseTypeId'];
        }
      });
    } catch (e) {
      _showSnackBar('Failed to load course types: $e', Colors.red);
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }

  Future<void> _loadInstructors() async {
    if (_schoolID == null) {
      _showSnackBar(
        'School ID not found. Cannot load instructors.',
        Colors.red,
      );
      setState(() {
        _isLoadingInstructors = false;
      });
      return;
    }
    try {
      final instructors = await CourseController.loadInstructors(_schoolID!);
      setState(() {
        _instructors = instructors;
        _isLoadingInstructors = false;
      });
    } catch (e) {
      _showSnackBar('Failed to load instructors: $e', Colors.red);
      setState(() {
        _isLoadingInstructors = false;
      });
    }
  }

  Future<void> _pickImages() async {
    if (_pickedImageFiles.length >= 5) {
      _showSnackBar('ไม่สามารถเพิ่มรูปภาพได้เกิน 5 รูป', Colors.red);
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _pickedImageFiles.add(pickedFile);
        _imageBytesList.add(bytes);
      });
      _showSnackBar(
        'เพิ่มรูปภาพสำเร็จ (${_imageBytesList.length}/5)',
        Colors.green,
      );
    }
  }

  void _removePickedImage(int index) {
    setState(() {
      _imageBytesList.removeAt(index);
      _pickedImageFiles.removeAt(index);
    });
    _showSnackBar('ลบรูปภาพสำเร็จ', AppColors.secondaryText);
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? firstSelectableDate,
    DateTime? lastSelectableDate,
  }) async {
    DateTime initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    DateTime effectiveFirstDate = firstSelectableDate ?? DateTime(2000);
    DateTime effectiveLastDate = lastSelectableDate ?? DateTime(2101);

    if (initialDate.isBefore(effectiveFirstDate)) {
      initialDate = effectiveFirstDate;
    }
    if (initialDate.isAfter(effectiveLastDate)) {
      initialDate = effectiveLastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _onTypeChanged(String? val) {
    setState(() {
      _selectedType = val!;
      final selectedCourseType = _courseTypes.firstWhere(
        (type) => type['courseType'] == val,
      );
      _selectedTypeId = selectedCourseType['courseTypeId'];
    });
  }

  Future<void> _onAddSchedule() async {
    final _scheduleFormKey = GlobalKey<FormState>();
    final _capacityController = TextEditingController();
    final _studyTimeController = TextEditingController();
    final _regisOpenController = TextEditingController();
    final _regisCloseController = TextEditingController();
    final _startDateController = TextEditingController();
    final _endDateController = TextEditingController();

    String? _dialogSelectedInstructorId =
        _instructors.isNotEmpty ? _instructors.first.instructorId : null;
    List<CourseDetail> _dialogSelectedInstructorSchedules = [];
    bool _isDialogScheduleLoading = false;

    Future<void> _fetchDialogInstructorSchedule(
      String instructorId,
      Function setDialogState,
    ) async {
      try {
        setDialogState(() {
          _isDialogScheduleLoading = true;
          _dialogSelectedInstructorSchedules = [];
        });
        _dialogSelectedInstructorSchedules =
            await CourseController.fetchCourseDetailsByInstructorId(
              instructorId,
            );
      } catch (e) {
        print('Error fetching dialog instructor schedule: $e');
        _dialogSelectedInstructorSchedules = [];
      } finally {
        setDialogState(() {
          _isDialogScheduleLoading = false;
        });
      }
    }

    if (_dialogSelectedInstructorId != null) {
      await _fetchDialogInstructorSchedule(
        _dialogSelectedInstructorId,
        (fn) => setState(fn),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600.0),
              child: AlertDialog(
                title: const Text('สร้างกำหนดการลงทะเบียนใหม'),
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
                            _isLoadingInstructors
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _instructors.isEmpty
                                ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'ไม่พบข้อมูลผู้สอนสำหรับโรงเรียนนี้',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : DropdownButtonFormField<String>(
                                  value: _dialogSelectedInstructorId,
                                  style: TextStyles.input,
                                  decoration: InputDecoration(
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
                                      _dialogSelectedInstructorId = value;
                                      await _fetchDialogInstructorSchedule(
                                        value,
                                        setDialogState,
                                      );
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
                              Text('ตารางสอนผู้สอน', style: TextStyles.label),
                              const SizedBox(height: 8),
                              InstructorScheduleCalendar(
                                instructorId: _dialogSelectedInstructorId,
                                schedules: _dialogSelectedInstructorSchedules,
                                isLoading: _isDialogScheduleLoading,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        _buildDialogTextField(
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
                              child: _buildDialogTextField(
                                controller: _regisOpenController,
                                label: 'วันที่เปิดลงทะเบียน',
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? regisCloseDate =
                                      DateTime.tryParse(
                                        _regisCloseController.text,
                                      );
                                  await _selectDate(
                                    context,
                                    _regisOpenController,
                                    lastSelectableDate:
                                        regisCloseDate != null
                                            ? regisCloseDate.subtract(
                                              const Duration(days: 1),
                                            )
                                            : null,
                                  );
                                  setDialogState(() {});
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
                                    value,
                                  );
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
                              child: _buildDialogTextField(
                                controller: _regisCloseController,
                                label: 'วันที่ปิดลงทะเบียน',
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? regisOpenDate =
                                      DateTime.tryParse(
                                        _regisOpenController.text,
                                      );
                                  await _selectDate(
                                    context,
                                    _regisCloseController,
                                    firstSelectableDate:
                                        regisOpenDate != null
                                            ? regisOpenDate.add(
                                              const Duration(days: 1),
                                            )
                                            : null,
                                  );
                                  setDialogState(() {});
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
                                  final regisCloseDate = DateTime.tryParse(
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
                              child: _buildDialogTextField(
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
                                  await _selectDate(
                                    context,
                                    _startDateController,
                                    firstSelectableDate:
                                        regisCloseDate != null
                                            ? regisCloseDate.add(
                                              const Duration(days: 1),
                                            )
                                            : null,
                                    lastSelectableDate:
                                        endDate != null
                                            ? endDate.subtract(
                                              const Duration(days: 1),
                                            )
                                            : null,
                                  );
                                  setDialogState(() {});
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
                              child: _buildDialogTextField(
                                controller: _endDateController,
                                label: 'วันที่สิ้นสุดการเรียน',
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? startDate = DateTime.tryParse(
                                    _startDateController.text,
                                  );
                                  await _selectDate(
                                    context,
                                    _endDateController,
                                    firstSelectableDate:
                                        startDate != null
                                            ? startDate.add(
                                              const Duration(days: 1),
                                            )
                                            : null,
                                  );
                                  setDialogState(() {});
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
                              child: _buildDialogTextField(
                                controller: _studyTimeController,
                                label: 'เวลาเรียน (ชม.)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกเวลาเรียน';
                                  }
                                  final number = double.tryParse(value);
                                  if (number == null) {
                                    return 'กรุณากรอกตัวเลขเท่านั้น';
                                  }
                                  if (number <= 0) {
                                    return 'เวลาเรียนต้องมากกว่า 0';
                                  }
                                  return null;
                                },
                                suffixIcon: const Icon(
                                  Icons.access_time,
                                  color: AppColors.secondaryText,
                                ),
                                readOnly: false,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('ยกเลิก'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_scheduleFormKey.currentState!.validate() &&
                          _dialogSelectedInstructorId != null) {
                        final newScheduleStartDate = DateTime.parse(
                          _startDateController.text,
                        );
                        final newScheduleEndDate = DateTime.parse(
                          _endDateController.text,
                        );

                        bool internalOverlap = _courseSchedules.any((
                          existingSchedule,
                        ) {
                          final existingStartDate = DateTime.parse(
                            existingSchedule.startDate,
                          );
                          final existingEndDate = DateTime.parse(
                            existingSchedule.endDate,
                          );
                          final existingInstructorId =
                              existingSchedule.instructorId;
                          if (existingInstructorId ==
                                  _dialogSelectedInstructorId &&
                              (newScheduleStartDate.isBefore(existingEndDate) ||
                                  newScheduleStartDate.isAtSameMomentAs(
                                    existingEndDate,
                                  )) &&
                              (newScheduleEndDate.isAfter(existingStartDate) ||
                                  newScheduleEndDate.isAtSameMomentAs(
                                    existingStartDate,
                                  ))) {
                            return true;
                          }
                          return false;
                        });

                        if (internalOverlap) {
                          _showSnackBar(
                            'ผู้สอนมีกำหนดการทับซ้อนในรายการนี้แล้ว',
                            Colors.red,
                          );
                          return;
                        }
                        if (await CourseController.checkInstructorScheduleOverlap(
                          _dialogSelectedInstructorId!,
                          _startDateController.text,
                          _endDateController.text,
                          null,
                        )) {
                          _showSnackBar(
                            'ผู้สอนมีกำหนดการทับซ้อนในช่วงเวลานี้',
                            Colors.red,
                          );
                          return;
                        }
                        final newSchedule = CourseDetail(
                          id: 0,
                          capacity: int.parse(_capacityController.text),
                          endDate: _endDateController.text,
                          registClose: _regisCloseController.text,
                          registOpen: _regisOpenController.text,
                          scheduleStatus: 'open',
                          startDate: _startDateController.text,
                          time: double.parse(_studyTimeController.text),
                          courseId: widget.schoolID,
                          instructorId: _dialogSelectedInstructorId!,
                        );
                        setState(() {
                          _courseSchedules.add(newSchedule);
                        });
                        Navigator.of(context).pop();
                      } else if (_dialogSelectedInstructorId == null &&
                          _instructors.isNotEmpty) {
                        setDialogState(() {});
                      }
                    },
                    child: const Text('เพิ่ม'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _removeSchedule(int index) {
    setState(() {
      _courseSchedules.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedTypeId == null) {
      _showSnackBar('กรุณาเลือกประเภทหลักสูตร', Colors.red);
      return;
    }
    if (_schoolID == null) {
      _showSnackBar('ไม่พบ School ID. กรุณาเข้าสู่ระบบอีกครั้ง.', Colors.red);
      return;
    }
    if (_pickedImageFiles.isEmpty) {
      _showSnackBar('กรุณาเลือกรูปภาพหลักสูตรอย่างน้อย 1 รูป', Colors.red);
      return;
    }
    _showSnackBar('กำลังเพิ่มหลักสูตร...', AppColors.primaryBackground);
    try {
      await CourseController.createCourse(
        courseId: _idController.text,
        courseName: _nameController.text,
        courseDescription: _detailController.text,
        coursePrice: _priceController.text,
        courseRating: '0.0',
        courseTypeId: _selectedTypeId.toString(),
        schoolId: _schoolID!,
        pickedImageFiles: _pickedImageFiles,
        imageBytesList: _imageBytesList,
        courseSchedules: _courseSchedules,
      );

      _showSnackBar('สร้างหลักสูตรเสร็จสมบูรณ์', AppColors.primaryButton);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ListCoursePage()),
        );
      }
    } catch (e) {
      print('Error submitting form: $e');
      _showSnackBar(
        'เกิดข้อผิดพลาดในการเชื่อมต่อ. โปรดลองอีกครั้ง. Error: $e',
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          'เพิ่มข้อมูลหลักสูตร',
          style: TextStyles.title.copyWith(color: AppColors.primaryText),
        ),
        backgroundColor: AppColors.formBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ListCoursePage()),
              ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CreateCourseWidget(
            formKey: _formKey,
            idController: _idController,
            nameController: _nameController,
            detailController: _detailController,
            priceController: _priceController,
            selectedType: _selectedType,
            courseTypes: _courseTypes,
            isLoadingTypes: _isLoadingTypes,
            courseSchedules: _courseSchedules,
            instructors: _instructors,
            imageBytesList: _imageBytesList,
            onPickImages: _pickImages,
            onRemoveImage: _removePickedImage,
            onTypeChanged: (val) => _onTypeChanged(val),
            onAddSchedule: _onAddSchedule,
            onRemoveSchedule: _removeSchedule,
            onSubmitForm: _submitForm,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyles.input,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputFocusedBorder),
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
}

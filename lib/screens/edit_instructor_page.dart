import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/model/Instructor.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/controllers/instructorController.dart';
import 'package:project_web/widgets/edit__instructor_widget.dart';

class EditInstructorPage extends StatefulWidget {
  final String instructorId;

  const EditInstructorPage({super.key, required this.instructorId});

  @override
  State<EditInstructorPage> createState() => _EditInstructorPageState();
}

class _EditInstructorPageState extends State<EditInstructorPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  
  String _selectedGender = 'ชาย';
  final List<String> _genderOptions = ['ชาย', 'หญิง'];
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes; 
  String? _currentPictureFilename;
  String? _schoolId;

  bool _isLoading = true;
  Instructor? _instructor;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInstructorDetails();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _fetchInstructorDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _instructor = await InstructorController.fetchInstructorDetails(widget.instructorId);
      _initializeFormFields(_instructor!);
    } catch (e) {
      _error = e.toString();
      print('Error fetching instructor details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeFormFields(Instructor instructor) {
    _firstNameController.text = instructor.instructorName ?? '';
    _lastNameController.text = instructor.instructorLname ?? '';
    _emailController.text = instructor.instructorEmail ?? '';
    _phoneController.text = instructor.instructorTel ?? '';
    if (instructor.instructorBirthday != null) {
      _birthdayController.text = DateFormat('yyyy-MM-dd').format(instructor.instructorBirthday!);
    }
    _selectedGender = (instructor.instructorGender) ? 'หญิง' : 'ชาย';
    _currentPictureFilename = instructor.instructorPicture;
    _schoolId = instructor.schoolId;
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _birthdayController.text = formatted;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        if (kIsWeb) {
          image.readAsBytes().then((bytes) {
            if (mounted) {
              setState(() {
                _pickedImageBytes = bytes;
              });
            }
          });
        }
      });
      _showSnackBar('เลือกรูปภาพเรียบร้อย', Colors.black);
    }
  }

  void _showSnackBar(String message, [Color backgroundColor = Colors.black]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyles.body),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _updateForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await InstructorController.updateInstructor(
        instructorId: widget.instructorId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        birthday: _birthdayController.text,
        gender: _selectedGender,
        schoolId: _schoolId!,
        pickedImage: _pickedImage,
        pickedImageBytes: _pickedImageBytes,
      );

      if (success && mounted) {
        _showSnackBar('แก้ไขข้อมูลผู้สอนสำเร็จ', Colors.green);
        Navigator.pop(context, true); 
      }
    } catch (e) {
      print('Error updating form: $e');
      _showSnackBar('เกิดข้อผิดพลาด: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _onGenderChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedGender = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลผู้สอน', style: TextStyles.title.copyWith(color: AppColors.primaryText)),
        backgroundColor: AppColors.formBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); 
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: TextStyles.body.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _instructor != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: EditInstructorWidget(
                            formKey: _formKey,
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            birthdayController: _birthdayController,
                            selectedGender: _selectedGender,
                            genderOptions: _genderOptions,
                            pickedImage: _pickedImage,
                            pickedImageBytes: _pickedImageBytes,
                            currentPictureFilename: _currentPictureFilename,
                            isLoading: _isLoading,
                            onPickImage: _pickImage,
                            onSelectDate: _selectDate,
                            onGenderChanged: _onGenderChanged,
                            onUpdateForm: _updateForm,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('ไม่พบข้อมูลผู้สอน', style: TextStyle()),
      ),
    );
  }
}
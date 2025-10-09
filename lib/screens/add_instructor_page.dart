import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/screens/list_instructor_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/styles/font-style.dart';
import 'package:intl/intl.dart';
import 'package:project_web/controllers/instructorController.dart';
import 'package:project_web/widgets/add_instructor_widget.dart'; 

class AddInstructorPage extends StatefulWidget {
  final String? schoolID;
  const AddInstructorPage({super.key, required this.schoolID});

  @override
  State<AddInstructorPage> createState() => _AddInstructorPageState();
}

class _AddInstructorPageState extends State<AddInstructorPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  String? schoolID;
  
  String _selectedGender = 'ชาย';
  final List<String> _genderOptions = ['ชาย', 'หญิง'];
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose(); 
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    schoolID = widget.schoolID;
    
    final initialDate = DateTime(2000, 1, 1);
    final formattedDate = DateFormat('yyyy-MM-dd').format(initialDate);
    _birthdayController.text = formattedDate;
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || schoolID == null) {
      _showSnackBar('กรุณากรอกข้อมูลให้ครบถ้วนและเลือกโรงเรียน', Colors.black);
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      final success = await InstructorController.addInstructor(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        birthday: _birthdayController.text,
        gender: _selectedGender,
        schoolId: schoolID!,
        pickedImage: _pickedImage,
        pickedImageBytes: _pickedImageBytes,
      );

      if (success && mounted) {
        _showSnackBar('เพิ่มผู้สอนสำเร็จ', Colors.black);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ListInstructorPage()),
        );
      }
    } catch (e) {
      print('Error submitting form: $e');
      _showSnackBar('เกิดข้อผิดพลาด: $e', Colors.black);
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
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
  
  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.formBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ListInstructorPage()),
          ),
        ),
        title: Text(
          'เพิ่มผู้สอนใหม่',
          style: TextStyles.title.copyWith(
            fontSize: FontStyles.large,
            color: AppColors.primaryBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AddInstructorWidget(
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
              isLoading: _isLoading,
              onSelectDate: _selectDate,
              onPickImage: _pickImage,
              onGenderChanged: _onGenderChanged,
              onSubmitForm: _submitForm,
              onCancel: _onCancel,
            ),
          ),
        ),
      ),
    );
  }
}
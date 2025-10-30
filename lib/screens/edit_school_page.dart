import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/controllers/schoolController.dart'; 
import 'package:project_web/model/School.dart';
import 'package:project_web/services/map_api.dart'; 
import 'package:project_web/styles/text-style.dart'; 
import 'package:project_web/widgets/edit_school_widget.dart';

class EditSchoolPage extends StatefulWidget {
  final School school;

  const EditSchoolPage({super.key, required this.school});

  @override
  State<EditSchoolPage> createState() => _EditSchoolPageState();
}

class _EditSchoolPageState extends State<EditSchoolPage> {
  final _formKey = GlobalKey<FormState>();

  final schoolNameController = TextEditingController();
  final schoolTelController = TextEditingController();
  final schoolAddressController = TextEditingController();
  final schoolDetailController = TextEditingController();
  final schoolEmailController = TextEditingController();
  final schoolLatitudeController = TextEditingController();
  final schoolLongitudeController = TextEditingController();

  bool _isLoading = false;
  String? _currentSchoolPictureFileName;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _clearPictureFlag = false; 

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  @override
  void dispose() {
    schoolNameController.dispose();
    schoolTelController.dispose();
    schoolAddressController.dispose();
    schoolDetailController.dispose();
    schoolEmailController.dispose();
    schoolLatitudeController.dispose();
    schoolLongitudeController.dispose();
    super.dispose();
  }

  void _initializeFormFields() {
    schoolNameController.text = widget.school.schoolName ?? '';
    schoolTelController.text = widget.school.schoolTel ?? '';
    schoolAddressController.text = widget.school.schoolAddress ?? '';
    schoolDetailController.text = widget.school.schoolDetail ?? '';
    schoolEmailController.text = widget.school.schoolEmail ?? '';
    schoolLatitudeController.text = widget.school.schoolLatitude?.toString() ?? ''; 
    schoolLongitudeController.text = widget.school.schoolLongitude?.toString() ?? '';
    _currentSchoolPictureFileName = widget.school.schoolPicture; 
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (!mounted) return; 
      
      setState(() {
        _pickedImage = picked;
        _clearPictureFlag = false; 
        if (kIsWeb) {
          picked.readAsBytes().then((bytes) {
            if (mounted) {
              setState(() {
                _pickedImageBytes = bytes;
              });
            }
          });
        }
      });
      _showSnackBar('เลือกรูปภาพเรียบร้อย', Colors.green);
    }
  }

  void _clearPicture() {
    if (!mounted) return; 
    setState(() {
      _pickedImage = null;
      _pickedImageBytes = null;
      _currentSchoolPictureFileName = null; 
      _clearPictureFlag = true; 
    });
    _showSnackBar('รูปภาพถูกล้างแล้ว', Colors.orange);
  }

  Future<void> _openMapAndSelectLocation() async {
    final double? initialLat = double.tryParse(schoolLatitudeController.text);
    final double? initialLng = double.tryParse(schoolLongitudeController.text);

    if (!mounted) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapAPI(
          initialLat: initialLat,
          initialLng: initialLng,
          onLocationSelected: (point) {
            if (!mounted) return;
            setState(() {
              schoolLatitudeController.text = point.latitude.toString();
              schoolLongitudeController.text = point.longitude.toString();
            });
            _showSnackBar('อัปเดตพิกัดเรียบร้อย', Colors.black);
          },
        ),
      ),
    );
  }

  Future<void> _updateSchool() async {
    if (!_formKey.currentState!.validate()) { 
      _showSnackBar('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง', Colors.red);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await SchoolController.updateSchool( 
        schoolId: widget.school.schoolId!,
        schoolName: schoolNameController.text,
        schoolEmail: schoolEmailController.text,
        schoolPassword: widget.school.schoolPassword!,
        schoolDetail: schoolDetailController.text,
        schoolAddress: schoolAddressController.text,
        schoolTel: schoolTelController.text,
        schoolStatus: widget.school.schoolStatus ?? 'active',
        schoolLatitude: schoolLatitudeController.text,
        schoolLongitude: schoolLongitudeController.text,
        pickedImage: _pickedImage,
        pickedImageBytes: _pickedImageBytes,
        clearPictureFlag: _clearPictureFlag,
      );

      _showSnackBar('อัปเดตข้อมูลสำเร็จ', Colors.black);
      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: ${e.toString()}', Colors.red);
      print('Update Exception: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลโรงเรียน'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: EditSchoolWidget(
              formKey: _formKey,
              schoolNameController: schoolNameController,
              schoolTelController: schoolTelController,
              schoolAddressController: schoolAddressController,
              schoolDetailController: schoolDetailController,
              schoolEmailController: schoolEmailController,
              schoolLatitudeController: schoolLatitudeController,
              schoolLongitudeController: schoolLongitudeController,
              isLoading: _isLoading,
              currentSchoolPictureFileName: _currentSchoolPictureFileName,
              pickedImage: _pickedImage,
              pickedImageBytes: _pickedImageBytes,
              onPickImage: _pickImage,
              onClearPicture: _clearPicture,
              onUpdateSchool: _updateSchool,
              onCancel: () {
                Navigator.pop(context);
              },
              onOpenMap: _openMapAndSelectLocation, 
            ),
          ),
        ),
      ),
    );
  }
}
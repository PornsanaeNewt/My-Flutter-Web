import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_web/controllers/courseController.dart';
import 'package:project_web/model/Course.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/widgets/edit_course_widget.dart';

class EditCoursePage extends StatefulWidget {
  final Course course;

  const EditCoursePage({
    super.key,
    required this.course,
  });

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();


  String? _selectedCourseType;
  List<Map<String, dynamic>> _courseTypes = [];
  bool _isLoading = false;
  
  List<String> _currentImageUrls = []; 
  List<XFile> _pickedImageFiles = []; 
  List<Uint8List> _pickedImageBytesList = []; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _fetchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    _nameController.text = widget.course.name.toString();
    _descriptionController.text = widget.course.description.toString();
    _priceController.text = widget.course.price.toString();
    _selectedCourseType = widget.course.courseTypeId.toString();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final courseTypes = await CourseController.fetchCourseTypes();
      final imageUrls = await CourseController.fetchCourseImages(widget.course.id!);
      
      setState(() {
        _courseTypes = courseTypes;
        _currentImageUrls = imageUrls;
        final exists = _courseTypes.any(
          (e) => e['courseTypeId'].toString() == _selectedCourseType,
        );
        if (!exists) {
          _selectedCourseType = _courseTypes.isNotEmpty
              ? _courseTypes.first['courseTypeId'].toString()
              : null;
        }
      });
    } catch (e) {
      _showSnackBar('Error loading data: $e', Colors.black);
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      if (_currentImageUrls.length + _pickedImageFiles.length + images.length > 5) {
        _showSnackBar('ไม่สามารถเพิ่มรูปภาพได้เกิน 5 รูป', Colors.black);
        return;
      }
      
      setState(() {
        _pickedImageFiles.addAll(images);
        if (kIsWeb) {
          for (var img in images) { 
            img.readAsBytes().then((bytes) {
              setState(() {
                _pickedImageBytesList.add(bytes);
              });
            });
          }
        }
      });
      _showSnackBar('เลือกรูปภาพเพิ่ม ${images.length} รูป', Colors.black);
    }
  }

  void _removePickedImage(int index) {
    setState(() {
      _pickedImageFiles.removeAt(index);
      if (kIsWeb) {
        _pickedImageBytesList.removeAt(index);
      }
    });
    _showSnackBar('ลบรูปภาพที่เลือกแล้ว', Colors.black);
  }

  Future<void> _deleteExistingImage(String imageUrl) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณแน่ใจหรือไม่ที่ต้องการลบรูปภาพนี้? การกระทำนี้ไม่สามารถยกเลิกได้'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('ลบ', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete != null && shouldDelete) {
      try {
        await CourseController.deleteCourseImage(imageUrl);
        _showSnackBar('ลบรูปภาพสำเร็จ', Colors.black);
        _fetchData(); 
      } catch (e) {
        _showSnackBar('เกิดข้อผิดพลาดในการลบรูปภาพ: $e', Colors.black);
      }
    }
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CourseController.updateCourseDetails(
        courseId: widget.course.id!,
        courseName: _nameController.text,
        courseDescription: _descriptionController.text,
        coursePrice: double.tryParse(_priceController.text) ?? 0,
        courseTypeId: int.tryParse(_selectedCourseType ?? '') ?? 0,
        pickedImageFiles: _pickedImageFiles,
        pickedImageBytesList: _pickedImageBytesList,
      );

      _showSnackBar('บันทึกการแก้ไขหลักสูตรสำเร็จ', Colors.black);
      Navigator.pop(context, true); 
    } catch (e) {
      _showSnackBar('Error: $e', Colors.black);
    } finally {
      setState(() => _isLoading = false);
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
  
  void _onCourseTypeChanged(String? value) {
    setState(() {
      _selectedCourseType = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขหลักสูตร'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: EditCourseWidget(
                    formKey: _formKey,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    priceController: _priceController,
                    selectedCourseType: _selectedCourseType,
                    courseTypes: _courseTypes,
                    isLoading: _isLoading,
                    currentImageUrls: _currentImageUrls,
                    pickedImageFiles: _pickedImageFiles,
                    pickedImageBytesList: _pickedImageBytesList,
                    onPickImages: _pickImages,
                    onRemovePickedImage: _removePickedImage,
                    onDeleteExistingImage: _deleteExistingImage,
                    onUpdateCourse: _updateCourse,
                    onCourseTypeChanged: _onCourseTypeChanged,
                  ),
                ),
              ),
            ),
    );
  }
}
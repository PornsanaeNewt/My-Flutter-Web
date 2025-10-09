import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../screens/login_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:flutter/services.dart'; 

class AddSchoolForm extends StatefulWidget {
  const AddSchoolForm({super.key});

  @override
  State<AddSchoolForm> createState() => _AddSchoolFormState();
}

class _AddSchoolFormState extends State<AddSchoolForm> {
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes; 

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final detailController = TextEditingController();
  bool agree = false;
  bool _isLoading = false; 


  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        if (kIsWeb) {
          image.readAsBytes().then((bytes) {
            setState(() {
              _pickedImageBytes = bytes;
            });
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เลือกรูปภาพเรียบร้อย')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && agree) {
      setState(() {
        _isLoading = true; 
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/school/addSchool'),
      );

      request.fields['schoolID'] = "${DateTime.now().millisecondsSinceEpoch}".substring(3);
      request.fields['schoolName'] = nameController.text;
      request.fields['schoolEmail'] = emailController.text;
      request.fields['schoolPassword'] = passwordController.text;
      request.fields['schoolTel'] = phoneController.text;
      request.fields['schoolAddress'] = addressController.text;
      request.fields['schoolLatitude'] = latitudeController.text;
      request.fields['schoolLongitude'] = longitudeController.text;
      request.fields['schoolDetail'] = detailController.text;
      request.fields['schoolStatus'] = "wait";

      print(nameController);
      print(emailController);
      print(passwordController);
      print(addressController);
      print(latitudeController);
      print(longitudeController);
      print(detailController);

      if (_pickedImage != null) {
        if (kIsWeb && _pickedImageBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'schoolPicture',
              _pickedImageBytes!,
              filename: _pickedImage!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'schoolPicture',
              _pickedImage!.path,
              filename: _pickedImage!.name,
            ),
          );
        }
      } else {
        request.fields['schoolPicture'] = '';
      }

      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลงทะเบียนสำเร็จ')),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถลงทะเบียนได้: ${response.statusCode} - ${response.body}')),
          );
          print('Server Error: ${response.statusCode} - ${response.body}'); // เพิ่มการ log ข้อผิดพลาดจากเซิร์ฟเวอร์
        }
      } catch (e) {
        print('Error sending request: $e'); // Log ข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์: $e')), // แสดงข้อผิดพลาดให้ผู้ใช้
        );
      } finally {
        setState(() {
          _isLoading = false; // หยุดโหลดไม่ว่าจะสำเร็จหรือล้มเหลว
        });
      }
    } else if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณายอมรับข้อตกลงและเงื่อนไข')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyles.input,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? 'กรอก$label',
            hintStyle: TextStyles.input.copyWith(
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputFocusedBorder, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFileUploadArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('รูปภาพ', style: TextStyles.label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(
                color: AppColors.inputBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _pickedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to upload or drag and drop',
                        style: TextStyles.body.copyWith(color: Colors.grey.shade600),
                      ),
                      Text(
                        'SVG, PNG, JPG or GIF (max 800x400px)',
                        style: TextStyles.body.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb && _pickedImageBytes != null 
                        ? Image.memory( 
                            _pickedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file( 
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: isLargeScreen
                ? _buildLargeScreenLayout()
                : _buildRegistrationFormCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Image.asset(
            'lib/assets/images/tung.png',
            fit: BoxFit.cover,
            height: 600,
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 1,
          child: _buildRegistrationFormCard(),
        ),
      ],
    );
  }

  Widget _buildRegistrationFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFileUploadArea(),
            _buildTextField(controller: nameController, label: 'ชื่อโรงเรียน', validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อ' : null),
            _buildTextField(controller: emailController, label: 'อีเมล', validator: (v) => v!.isEmpty ? 'กรุณากรอกอีเมล' : null),
            _buildTextField(controller: passwordController, label: 'รหัสผ่าน', obscureText: true, validator: (v) => v!.length < 6 ? 'อย่างน้อย 6 ตัว' : null),
            _buildTextField(controller: confirmPasswordController, label: 'ยืนยันรหัสผ่าน', obscureText: true, validator: (v) => v != passwordController.text ? 'ไม่ตรงกัน' : null),
            _buildTextField(controller: phoneController, label: 'เบอร์โทร', validator: (v) => v!.isEmpty ? 'กรุณากรอกเบอร์โทร' : null),
            _buildTextField(controller: addressController, label: 'ที่อยู่'),
            _buildTextField(controller: latitudeController, label: 'ละติจูด'),
            _buildTextField(controller: longitudeController, label: 'ลองจิจูด'),
            _buildTextField(controller: detailController, label: 'รายละเอียดโรงเรียน', maxLines: 3),
            Row(
              children: [
                Checkbox(
                  value: agree,
                  onChanged: (val) => setState(() => agree = val!),
                  activeColor: AppColors.primaryButton,
                ),
                Expanded(child: Text('ยอมรับข้อตกลงและเงื่อนไข')),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (agree && !_isLoading) ? _submitForm : null, 
                child: _isLoading 
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('ลงทะเบียน'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

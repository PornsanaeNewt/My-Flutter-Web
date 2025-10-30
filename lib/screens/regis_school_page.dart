import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:project_web/controllers/schoolController.dart'; 
import 'package:project_web/screens/login_page.dart'; 
import 'package:project_web/styles/app-color.dart'; 
import 'package:project_web/widgets/regist_school_widget.dart';

class RegisterSchoolPage extends StatefulWidget {
  const RegisterSchoolPage({super.key});

  @override
  State<RegisterSchoolPage> createState() => _RegisterSchoolPageState();
}

class _RegisterSchoolPageState extends State<RegisterSchoolPage> {
  final _formKey = GlobalKey<FormState>();
  final SchoolController _schoolController = SchoolController(); 

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _isLoadingLocation = false;
  bool _isLoading = false;
  bool _agree = false;
  
  bool _obscurePassword = true; 
  bool _obscureConfirmPassword = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final detailController = TextEditingController();
  
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    detailController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }
  
  void _onMapLocationSelected(String lat, String lng, String address) {
    setState(() {
      // For instance, you might want to re-validate the form fields related to location.
      // Or just ensure the state reflects the new values.
    });
    print('Selected Lat: $lat, Lng: $lng, Address: $address');
  }


  Future<void> _determineAndSetPosition() async {
    setState(() {
      _isLoadingLocation = true;
      latitudeController.text = '';
      longitudeController.text = '';
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw Exception('สิทธิ์การเข้าถึงตำแหน่งถูกปฏิเสธ');
        }
      }
      
      Position position = await _schoolController.determinePosition();
      print("My Current Position : $position");
      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงตำแหน่งปัจจุบันได้: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final size = await image.length();
      if (size > 5 * 1024 * 1024) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไฟล์รูปภาพมีขนาดใหญ่เกินไป ')),
        );
        return; 
      }
      
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImage = image;
          _pickedImageBytes = bytes;
        });
      } else {
        setState(() {
          _pickedImage = image;
          _pickedImageBytes = null;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เลือกรูปภาพเรียบร้อย')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _agree) { 
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาอัปโหลดรูปภาพหลักของโรงเรียน')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _schoolController.submitSchoolRegistration(
          schoolName: nameController.text,
          schoolEmail: emailController.text,
          schoolPassword: passwordController.text,
          schoolTel: phoneController.text,
          schoolAddress: addressController.text,
          schoolLatitude: latitudeController.text,
          schoolLongitude: longitudeController.text,
          schoolDetail: detailController.text,
          pickedImage: _pickedImage,
          pickedImageBytes: _pickedImageBytes,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลงทะเบียนสำเร็จ! กำลังนำไปสู่หน้าเข้าสู่ระบบ')),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถลงทะเบียนได้: ${response.statusCode} - ${response.body}')),
          );
          print('Server Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error sending request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณายอมรับข้อตกลงและเงื่อนไข')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 1000; 

    final registrationFormCard = RegisterSchoolWidgets.buildRegistrationFormCard(
      formKey: _formKey,
      nameController: nameController,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      phoneController: phoneController,
      addressController: addressController,
      latitudeController: latitudeController,
      longitudeController: longitudeController,
      detailController: detailController,
      pickedImage: _pickedImage,
      pickedImageBytes: _pickedImageBytes,
      pickImageCallback: _pickImage,
      agree: _agree, 
      onAgreeChanged: (val) => setState(() => _agree = val ?? false), 
      submitFormCallback: _submitForm,
      isLoading: _isLoading,
      isLoadingLocation: _isLoadingLocation,
      determineAndSetPositionCallback: _determineAndSetPosition,
      obscurePassword: _obscurePassword, 
      obscureConfirmPassword: _obscureConfirmPassword,
      togglePasswordVisibility: _togglePasswordVisibility,
      toggleConfirmPasswordVisibility: _toggleConfirmPasswordVisibility,
      context: context, 
      onMapLocationSelected: _onMapLocationSelected,
    );

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea( 
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: isLargeScreen
                  ? RegisterSchoolWidgets.buildLargeScreenLayout(
                      registrationFormCard: registrationFormCard,
                    )
                  : registrationFormCard,
            ),
          ),
        ),
      ),
    );
  }
}
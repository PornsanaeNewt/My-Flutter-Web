import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';

class EditCourseWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String? selectedCourseType;
  final List<Map<String, dynamic>> courseTypes;
  final bool isLoading;
  final List<String> currentImageUrls;
  final List<XFile> pickedImageFiles;
  final List<Uint8List> pickedImageBytesList;
  final VoidCallback onPickImages;
  final Function(int) onRemovePickedImage;
  final Function(String) onDeleteExistingImage;
  final VoidCallback onUpdateCourse;
  final Function(String?) onCourseTypeChanged;

  const EditCourseWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.selectedCourseType,
    required this.courseTypes,
    required this.isLoading,
    required this.currentImageUrls,
    required this.pickedImageFiles,
    required this.pickedImageBytesList,
    required this.onPickImages,
    required this.onRemovePickedImage,
    required this.onDeleteExistingImage,
    required this.onUpdateCourse,
    required this.onCourseTypeChanged,
  });
  
  @override
  State<EditCourseWidget> createState() => _EditCourseWidgetState();
}

class _EditCourseWidgetState extends State<EditCourseWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  bool _showRightButton = false;

  @override
  void initState() {
    super.initState();
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

    // มีเนื้อหาเกินขอบเขตให้เลื่อนหรือไม่
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
    final scrollAmount = context.size!.width * 0.6; 
    
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

  Widget _buildScrollButton({required IconData icon, required VoidCallback onPressed}) {
    return Card(
      elevation: 6,
      shape: const CircleBorder(),
      color: AppColors.cardBackground.withOpacity(0.9),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryAccent, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        splashRadius: 24,
      ),
    );
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
    int? maxLines = 1,
    String? hintText,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyles.input.copyWith(color: AppColors.secondaryText.withOpacity(0.6)),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.errorColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ประเภทหลักสูตร', style: TextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: widget.courseTypes.any(
                        (e) => e['courseTypeId'].toString() == widget.selectedCourseType)
                    ? widget.selectedCourseType
                    : null,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            dropdownColor: AppColors.cardBackground,
            style: TextStyles.input,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryText),
            items: widget.courseTypes.map((type) {
              final id = type['courseTypeId'].toString();
              return DropdownMenuItem<String>(
                value: id,
                child: Text(type['courseType'], style: TextStyles.input),
              );
            }).toList(),
            onChanged: widget.onCourseTypeChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer({
    required Widget child,
    required VoidCallback onDelete,
    required bool isPicked,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 250,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isPicked ? AppColors.primaryAccent : AppColors.inputBorder,
                width: isPicked ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        Positioned(
          top: 8,
          right: 16,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> allImages = [
      ...widget.currentImageUrls.map((imageUrl) {
        return _buildImageContainer(
          isPicked: false,
          onDelete: () => widget.onDeleteExistingImage(imageUrl),
          child: Image.network(
            'http://localhost:3000/assets/course/$imageUrl',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image_outlined, size: 60, color: AppColors.secondaryText.withOpacity(0.6)),
          ),
        );
      }).toList(),
      ...List.generate(widget.pickedImageFiles.length, (index) {
        final file = widget.pickedImageFiles[index];
        return _buildImageContainer(
          isPicked: true,
          onDelete: () => widget.onRemovePickedImage(index),
          child: kIsWeb && widget.pickedImageBytesList.isNotEmpty && index < widget.pickedImageBytesList.length
              ? Image.memory(widget.pickedImageBytesList[index], fit: BoxFit.cover)
              : Image.file(File(file.path), fit: BoxFit.cover),
        );
      }),
      if (widget.currentImageUrls.length + widget.pickedImageFiles.length < 5)
        InkWell(
          onTap: widget.onPickImages,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.lightAccent.withOpacity(0.2),
          child: Container(
            width: 250,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primaryAccent),
                SizedBox(height: 12),
                Text('เพิ่มรูปภาพ', style: TextStyles.label.copyWith(color: AppColors.primaryAccent)),
              ],
            ),
          ),
        ),
    ]; 

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text('รูปภาพหลักสูตร', style: TextStyles.title.copyWith(fontSize: 28)),
                const SizedBox(height: 20),
                
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Row(
                          children: allImages,
                        ),
                      ),
                      
                      if (_showLeftButton)
                        Positioned(
                          left: 0,
                          child: _buildScrollButton(
                            icon: Icons.arrow_back_ios_new,
                            onPressed: () => _scroll(false),
                          ),
                        ),
                      
                      if (_showRightButton)
                        Positioned(
                          right: 0,
                          child: _buildScrollButton(
                            icon: Icons.arrow_forward_ios,
                            onPressed: () => _scroll(true),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor.withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: widget.nameController,
                              label: 'ชื่อหลักสูตร',
                              hintText: 'กรอกชื่อหลักสูตรที่นี่',
                              validator: (value) => (value == null || value.isEmpty)
                                  ? 'กรุณากรอกชื่อ'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              controller: widget.priceController,
                              label: 'ราคา (บาท)',
                              hintText: 'ตัวอย่าง: 1999.00',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              validator: (value) =>
                                  (value == null || double.tryParse(value) == null)
                                      ? 'กรุณากรอกราคาที่ถูกต้อง'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: widget.descriptionController,
                        label: 'รายละเอียดหลักสูตร',
                        hintText: 'อธิบายรายละเอียดของหลักสูตรอย่างละเอียด...',
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildDropdownField(),

                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: widget.isLoading ? null : widget.onUpdateCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      foregroundColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 8,
                      shadowColor: AppColors.primaryButton.withOpacity(0.3),
                    ),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('บันทึกการแก้ไขหลักสูตร', style: TextStyles.button.copyWith(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
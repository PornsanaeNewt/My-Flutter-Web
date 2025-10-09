import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_web/model/CourseDetail.dart';
import 'package:project_web/model/Instructor.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/font-style.dart';
import 'package:project_web/styles/text-style.dart';

class CreateCourseWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController detailController;
  final TextEditingController priceController;
  final String? selectedType;
  final List<Map<String, dynamic>> courseTypes;
  final bool isLoadingTypes;
  final List<CourseDetail> courseSchedules;
  final List<Instructor> instructors;
  final List<Uint8List> imageBytesList;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final Function(String?) onTypeChanged;
  final VoidCallback onAddSchedule;
  final Function(int) onRemoveSchedule;
  final VoidCallback onSubmitForm;
  final VoidCallback onCancel;

  const CreateCourseWidget({
    super.key,
    required this.formKey,
    required this.idController,
    required this.nameController,
    required this.detailController,
    required this.priceController,
    required this.selectedType,
    required this.courseTypes,
    required this.isLoadingTypes,
    required this.courseSchedules,
    required this.instructors,
    required this.imageBytesList,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onTypeChanged,
    required this.onAddSchedule,
    required this.onRemoveSchedule,
    required this.onSubmitForm,
    required this.onCancel,
  });

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
        Text(label, style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
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
            fillColor: AppColors.lightAccent, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDropdown() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.lightAccent,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkAccent),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.formBackground,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyles.title.copyWith(fontSize: 22, color: AppColors.primaryBlack)),
            const Divider(height: 30, color: AppColors.inputBorder),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildScrollButton({required IconData icon, required VoidCallback onPressed}) {
    return Card(
      elevation: 6,
      shape: const CircleBorder(),
      color: AppColors.formBackground.withOpacity(0.9),
      child: IconButton(
        icon: Icon(icon, color: AppColors.mutedBrown, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        splashRadius: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200), 
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Courses / Create Course',
                    style: TextStyles.body.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: FontStyles.small,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionCard(
                    title: 'รูปหลักสูตร',
                    content: _buildImagePickerContent(), 
                  ),

                  _buildSectionCard(
                    title: 'ข้อมูลพื้นฐาน',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: idController,
                          label: 'รหัสหลักสูตร',
                          validator: (value) => value!.isEmpty ? 'กรุณากรอกรหัสหลักสูตร' : null,
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: nameController,
                          label: 'ชื่อหลักสูตร',
                          validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อหลักสูตร' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTypeDropdown(),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: detailController,
                          label: 'รายละเอียดหลักสูตร',
                          keyboardType: TextInputType.multiline, 
                          maxLines: 10,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: priceController,
                          label: 'ราคา (บาท)',
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'กรุณากรอกราคาหลักสูตร';
                            }
                            if (double.tryParse(value) == null) {
                              return 'กรุณากรอกราคาให้ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  _buildSectionCard(
                    title: 'กำหนดการหลักสูตร',
                    content: _buildScheduleListContent(),
                  ),
                  
                  _buildFooterButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePickerContent() {
    return _BuildImagePickerInner(
      imageBytesList: imageBytesList,
      onPickImages: onPickImages,
      onRemoveImage: onRemoveImage,
      buildImageThumbnail: _buildImageThumbnail, 
      buildAddImageButton: _buildAddImageButton,
      buildScrollButton: _buildScrollButton,
    );
  }

  Widget _buildAddImageButton() {
    const double imageSize = 210.0;
    return InkWell(
      onTap: onPickImages,
      borderRadius: BorderRadius.circular(10),
      hoverColor: AppColors.subtleGray,
      child: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: AppColors.subtleGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: AppColors.mutedBrown,
            ),
            const SizedBox(height: 8),
            Text(
              'เพิ่มรูปภาพ',
              style: TextStyles.label.copyWith(
                color: AppColors.mutedBrown,
                fontWeight: FontStyles.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index, double size) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            imageBytesList[index],
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.formBackground, width: 2),
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ประเภทหลักสูตร', style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
        const SizedBox(height: 8),
        isLoadingTypes
            ? _buildLoadingDropdown()
            : DropdownButtonFormField<String>(
                value: selectedType,
                style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightAccent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.inputFocusedBorder, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: courseTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['courseType'],
                    child: Text(
                      type['courseType'],
                      style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
                    ),
                  );
                }).toList(),
                onChanged: onTypeChanged,
                validator: (value) => value == null ? 'กรุณาเลือกประเภทหลักสูตร' : null,
              ),
      ],
    );
  }

  Widget _buildScheduleListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: onAddSchedule,
          icon: const Icon(Icons.add_box, color: AppColors.buttonText),
          label: const Text('เพิ่มกำหนดการใหม่'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryButton,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
          ),
        ),
        const SizedBox(height: 20),
        
        courseSchedules.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'ยังไม่มีกำหนดการเพิ่มเข้ามา',
                  style: TextStyles.body.copyWith(color: AppColors.secondaryText),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courseSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = courseSchedules[index];
                  final instructor = instructors.firstWhere(
                    (inst) => inst.instructorId == schedule.instructorId.toString(),
                    orElse: () => Instructor(instructorId: '', instructorName: 'Unknown', instructorLname: '', instructorEmail: '', instructorBirthday: null, instructorGender: false, instructorPicture: '', instructorTel: '', schoolId: ''),
                  );
                  return _buildScheduleCard(schedule, instructor, index);
                },
              ),
      ],
    );
  }

  Widget _buildScheduleCard(CourseDetail schedule, Instructor instructor, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.subtleGray,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('กำหนดการที่ ${index + 1}', style: TextStyles.label.copyWith(color: AppColors.primaryBlack, fontWeight: FontStyles.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onRemoveSchedule(index),
                  tooltip: 'ลบกำหนดการ',
                ),
              ],
            ),
            const Divider(height: 10, color: AppColors.inputBorder),
            _buildScheduleInfoRow('ผู้สอน', '${instructor.instructorName} ${instructor.instructorLname}', Icons.person),
            _buildScheduleInfoRow('จำนวนที่นั่ง', schedule.capacity.toString(), Icons.group),
            _buildScheduleInfoRow('เวลาเรียน', '${schedule.time} ชั่วโมง', Icons.schedule),
            _buildScheduleInfoRow('เปิดลงทะเบียน', '${schedule.registOpen} ถึง ${schedule.registClose}', Icons.date_range),
            _buildScheduleInfoRow('วันที่เรียน', '${schedule.startDate} ถึง ${schedule.endDate}', Icons.school),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mutedBrown),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyles.body.copyWith(color: AppColors.secondaryText)),
          Expanded(child: Text(value, style: TextStyles.body.copyWith(color: AppColors.primaryBlack, fontWeight: FontStyles.mediums))),
        ],
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 150,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.mutedBrown),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'ยกเลิก',
                style: TextStyles.button.copyWith(
                  color: AppColors.mutedBrown,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: onSubmitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAccent,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: Text(
                'ยืนยันการสร้าง',
                style: TextStyles.button.copyWith(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildImagePickerInner extends StatefulWidget {
  final List<Uint8List> imageBytesList;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final Widget Function(int index, double size) buildImageThumbnail;
  final Widget Function() buildAddImageButton;
  final Widget Function({required IconData icon, required VoidCallback onPressed}) buildScrollButton;

  const _BuildImagePickerInner({
    required this.imageBytesList,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.buildImageThumbnail,
    required this.buildAddImageButton,
    required this.buildScrollButton,
  });

  @override
  State<_BuildImagePickerInner> createState() => _BuildImagePickerInnerState();
}

class _BuildImagePickerInnerState extends State<_BuildImagePickerInner> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  bool _showRightButton = false;
  static const double _imageSize = 210.0;
  static const double _itemSpacing = 12.0;
  final double _itemWidth = _imageSize + _itemSpacing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.addListener(_checkScrollPosition);
        _checkScrollPosition();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _BuildImagePickerInner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageBytesList.length != oldWidget.imageBytesList.length) {
      Future.delayed(const Duration(milliseconds: 50), () {
          _checkScrollPosition();
      });
    }
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      _scrollController.removeListener(_checkScrollPosition);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (!mounted || !_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    const double tolerance = 5; 

    setState(() {
      final isScrollable = maxScroll > tolerance;
      print('Is Scrollable: $isScrollable');
      print('Max Scroll: $maxScroll, Current Scroll: $currentScroll');
      
      if (isScrollable) {
        _showLeftButton = currentScroll > tolerance; 
        _showRightButton = currentScroll < maxScroll - tolerance;
      } else {
        _showLeftButton = false;
        _showRightButton = false;
      }
    });
  }
  
  void _scroll(bool isRight) {
    if (!_scrollController.hasClients) return;
    final newOffset = isRight
        ? _scrollController.offset + _itemWidth * 2
        : _scrollController.offset - _itemWidth * 2;
    
    _scrollController.animateTo(
      newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: widget.imageBytesList.isEmpty ? 150 : _imageSize + _itemSpacing * 2,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(widget.imageBytesList.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: _itemSpacing),
                        child: widget.buildImageThumbnail(index, _imageSize),
                      );
                    }),
        
                    if (widget.imageBytesList.length < 5)
                      widget.buildAddImageButton(),
                      
                    if (widget.imageBytesList.isEmpty)
                       Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: _itemSpacing),
                          child: Text(
                            'กรุณาเลือกรูปภาพและกดปุ่มเพื่อเพิ่มทีละรูป',
                            style: TextStyles.body.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: FontStyles.medium,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (_showLeftButton)
              Positioned(
                left: 0, 
                child: widget.buildScrollButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () => _scroll(false),
                ),
              ),
              
            if (_showRightButton)
              Positioned(
                right: 0, 
                child: widget.buildScrollButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: () => _scroll(true),
                ),
              ),
          ],
        );
      },
    );
  }
}
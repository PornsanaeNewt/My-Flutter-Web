import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/model/Course.dart';
import 'package:project_web/controllers/courseController.dart';
import 'package:project_web/screens/course_detail_page.dart';

class ListCourseWidget extends StatelessWidget {
  final TextEditingController searchController;
  final List<Map<String, dynamic>> courseTypes;
  final Set<int> selectedTypeIds;
  final Function(bool?, int) onTypeChanged;
  final List<Course> filteredCourses;
  final bool isLoading;
  final bool isLoadingTypes;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final Function(Course) onConfirmDelete;
  
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final VoidCallback onFilterChanged;


  const ListCourseWidget({
    super.key,
    required this.searchController,
    required this.courseTypes,
    required this.selectedTypeIds,
    required this.onTypeChanged,
    required this.filteredCourses,
    required this.isLoading,
    required this.isLoadingTypes,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onConfirmDelete,
    required this.minPriceController,
    required this.maxPriceController,
    required this.onFilterChanged,
  });


  @override
  Widget build(BuildContext context) {
    // ห่อด้วย Container เพื่อกำหนดพื้นหลังหลักให้ดูสบายตา
    return Container(
      color: AppColors.primaryBackground, 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(context),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildCourseGrid(context),
                  ),
                  _buildPagination(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ปรับปรุงส่วน Filter
  Widget _buildFilterSection(BuildContext context) {
    return Container(
      width: 320, // ขยายความกว้างของ Filter เล็กน้อย
      padding: const EdgeInsets.all(24), // เพิ่ม Padding
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // ปรับ Margin
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        borderRadius: BorderRadius.circular(16), // เพิ่ม BorderRadius
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ตัวกรองหลักสูตร', style: TextStyles.title.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          const Divider(height: 30, color: AppColors.subtleGray),
          
          // ค้นหา
          Text('ค้นหาหลักสูตร', style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
          const SizedBox(height: 8),
          _buildFilterTextField(
            controller: searchController,
            hintText: 'ค้นหาชื่อหรือรายละเอียด...',
            prefixIcon: const Icon(Icons.search),
            onChanged: (_) => onFilterChanged(),
          ),
          
          const SizedBox(height: 30),
          
          // ประเภทหลักสูตร
          Text('ประเภทหลักสูตร', style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
          const SizedBox(height: 8),
          isLoadingTypes
              ? const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(),
                ))
              : Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightAccent.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: courseTypes.length,
                      itemBuilder: (context, index) {
                        final type = courseTypes[index];
                        final typeId = type['courseTypeId'];
                        return Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: AppColors.secondaryText,
                          ),
                          child: CheckboxListTile(
                            title: Text(type['courseType'], style: TextStyles.body.copyWith(color: AppColors.primaryBlack)),
                            value: selectedTypeIds.contains(typeId),
                            activeColor: AppColors.darkAccent,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            onChanged: (bool? newValue) {
                              onTypeChanged(newValue, typeId);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
          
          const SizedBox(height: 24),
          
          // ช่วงราคา
          Text('ช่วงราคา (บาท)', style: TextStyles.label.copyWith(color: AppColors.primaryBlack)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterTextField(
                  controller: minPriceController,
                  hintText: 'ราคาต่ำสุด',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  onChanged: (_) => onFilterChanged(),
                ),
              ),
              const SizedBox(width: 10),
              Text('-', style: TextStyles.label.copyWith(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFilterTextField(
                  controller: maxPriceController,
                  hintText: 'ราคาสูงสุด',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  onChanged: (_) => onFilterChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Widget ช่วยสร้าง TextField ที่มีสไตล์เฉพาะสำหรับ Filter
  Widget _buildFilterTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText.withOpacity(0.6)),
        filled: true,
        fillColor: AppColors.lightAccent.withOpacity(0.5),
        prefixIcon: prefixIcon,
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
          borderSide: BorderSide(color: AppColors.darkAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildCourseGrid(BuildContext context) {
    if (filteredCourses.isEmpty && !isLoading) {
      return Center(
        child: Text(
          'ไม่พบหลักสูตรที่ตรงกับเงื่อนไข',
          style: TextStyles.title.copyWith(color: AppColors.secondaryText),
        ),
      );
    }
    
    // คำนวณจำนวนหลักสูตรสำหรับหน้าปัจจุบัน
    final coursesForCurrentPage = _getCoursesForCurrentPage();

    return Container(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        itemCount: coursesForCurrentPage.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 450,
          mainAxisSpacing: 25, // เพิ่มระยะห่างแนวตั้ง
          crossAxisSpacing: 25, // เพิ่มระยะห่างแนวนอน
          childAspectRatio: 0.9, // ปรับอัตราส่วนให้สูงขึ้นเพื่อแสดงรายละเอียดมากขึ้น
        ),
        itemBuilder: (context, index) {
          return _buildCourseCard(context, coursesForCurrentPage[index]);
        },
      ),
    );
  }

  List<Course> _getCoursesForCurrentPage() {
    final int itemsPerPage = 8;
    final startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredCourses.length) {
      endIndex = filteredCourses.length;
    }
    return filteredCourses.sublist(startIndex, endIndex);
  }

   Widget _buildCourseCard(BuildContext context, Course course) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        CourseController.fetchCourseTypeName(course.courseTypeId),
        CourseController.fetchCourseRandomImage(course.id!),
      ]).then((results) {
        return {
          'courseTypeName': results[0],
          'randomImageUrl': results[1],
        };
      }),
      builder: (context, snapshot) {
        String courseTypeName = snapshot.data?['courseTypeName'] ?? 'ไม่ระบุ';
        String displayImageUrl = snapshot.data?['randomImageUrl'] != null
            ? 'http://localhost:3000/assets/course/${snapshot.data!['randomImageUrl']}'
            : 'https://placehold.co/400x200/E8DDD2/8F7D68?text=Course+Image'; 

        // Card Style ที่ทันสมัย
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          color: AppColors.formBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปภาพ
              Container(
                height: 170,
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.inputBorder, width: 1)),
                ),
                child: Image.network(
                  displayImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'ไม่สามารถโหลดรูปภาพได้',
                        style: TextStyles.body.copyWith(color: AppColors.secondaryText),
                      ),
                    );
                  },
                ),
              ),
              
              // เนื้อหาหลัก
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌟 ส่วนที่ถูกแก้ไข: ชื่อหลักสูตร (ซ้าย) และ คะแนน (ขวาบน)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start, // จัดให้ข้อความและคะแนนชิดบน
                        children: [
                          Expanded(
                            child: Text(
                              course.name ?? 'ไม่มีชื่อหลักสูตร',
                              style: TextStyles.title.copyWith(fontSize: 18, color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8), 
                          _buildRatingChip(course.rating),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        course.description ?? 'ไม่มีรายละเอียด',
                        style: TextStyles.body.copyWith(color: AppColors.secondaryText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // ราคา และ ประเภท
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailChip(Icons.price_change, '${course.price?.toStringAsFixed(0) ?? 'N/A'} บาท', AppColors.darkAccent),
                          _buildDetailChip(Icons.category, courseTypeName, AppColors.mutedBrown),
                          // ลบ Chip คะแนนออกจากตรงนี้แล้ว
                          const SizedBox(width: 8), // เพื่อให้จัดวางสวยงาม
                        ],
                      ),
                      const Spacer(),

                      // ปุ่ม
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailPage(courseId: course.id!),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline, size: 18, color: AppColors.buttonText),
                            label: Text(
                              'รายละเอียด',
                              style: TextStyles.button.copyWith(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                          
                          // ปุ่มลบ (เน้นสีแดง)
                          IconButton(
                            onPressed: () => onConfirmDelete(course),
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                            tooltip: 'ลบหลักสูตร',
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget ใหม่สำหรับแสดงคะแนน (Rating Chip)
  Widget _buildRatingChip(double? rating) {
    final displayRating = rating?.toStringAsFixed(1) ?? 'N/A';
    final color = Colors.amber.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            displayRating,
            style: TextStyles.body.copyWith(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Widget ช่วยสร้าง Detail Chip
  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyles.body.copyWith(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ปรับปรุง Pagination
  Widget _buildPagination() {
    if (filteredCourses.length <= 8) {
      return const SizedBox.shrink();
    }

    List<Widget> pages = [];

    // Previous button
    pages.add(
      IconButton(
        onPressed: currentPage > 1 ? onPreviousPage : null,
        icon: Icon(Icons.arrow_back_ios, size: 16, color: currentPage > 1 ? AppColors.primaryBlack : AppColors.secondaryText.withOpacity(0.5)),
      ),
    );

    // Page numbers logic (เหมือนเดิม)
    if (totalPages <= 5) {
      for (int i = 1; i <= totalPages; i++) {
        pages.add(_buildPageNumber(i));
      }
    } else {
      if (currentPage <= 3) {
        for (int i = 1; i <= 3; i++) {
          pages.add(_buildPageNumber(i));
        }
        pages.add(Text('...', style: TextStyles.body.copyWith(color: AppColors.primaryBlack)));
        pages.add(_buildPageNumber(totalPages));
      } else if (currentPage >= totalPages - 2) {
        pages.add(_buildPageNumber(1));
        pages.add(Text('...', style: TextStyles.body.copyWith(color: AppColors.primaryBlack)));
        for (int i = totalPages - 2; i <= totalPages; i++) {
          pages.add(_buildPageNumber(i));
        }
      } else {
        pages.add(_buildPageNumber(1));
        pages.add(Text('...', style: TextStyles.body.copyWith(color: AppColors.primaryBlack)));
        pages.add(_buildPageNumber(currentPage));
        pages.add(Text('...', style: TextStyles.body.copyWith(color: AppColors.primaryBlack)));
        pages.add(_buildPageNumber(totalPages));
      }
    }
    
    // Next button
    pages.add(
      IconButton(
        onPressed: currentPage < totalPages ? onNextPage : null,
        icon: Icon(Icons.arrow_forward_ios, size: 16, color: currentPage < totalPages ? AppColors.primaryBlack : AppColors.secondaryText.withOpacity(0.5)),
      ),
    );
    

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pages,
      ),
    );
  }
  
  // ปรับปรุง Page Number ให้ดูเป็นโทนสีมากขึ้น
  Widget _buildPageNumber(int page) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => onPageChanged(page),
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppColors.darkAccent : AppColors.subtleGray,
          foregroundColor: isActive ? AppColors.buttonText : AppColors.primaryBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(40, 40),
        ),
        child: Text('$page', style: TextStyles.body.copyWith(fontWeight: FontWeight.w600, color: isActive ? AppColors.buttonText : AppColors.primaryBlack)),
      ),
    );
  }
}
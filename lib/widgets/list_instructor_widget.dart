import 'package:flutter/material.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:project_web/styles/font-style.dart';

class ListInstructorWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool isLoading;
  final List<dynamic> filteredInstructors;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final Function(String) onSearch;
  final VoidCallback onAddInstructor;
  final Function(Map<String, dynamic>) onDeleteInstructor;
  final Function(String) onEditInstructor;

  const ListInstructorWidget({
    super.key,
    required this.searchController,
    required this.isLoading,
    required this.filteredInstructors,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onSearch,
    required this.onAddInstructor,
    required this.onDeleteInstructor,
    required this.onEditInstructor,
  });

  List<dynamic> _getCurrentPageItems() {
    final int itemsPerPage = 7;
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredInstructors.sublist(
      startIndex,
      endIndex > filteredInstructors.length ? filteredInstructors.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground, 
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildInstructorTable(context),
          ),
          if (totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24), 
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildSearchBar(),
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            onPressed: onAddInstructor,
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.buttonText),
            label: Text('เพิ่มผู้สอนใหม่', style: TextStyles.button.copyWith(fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAccent, 
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              shadowColor: AppColors.darkAccent.withOpacity(0.4),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: onSearch,
      style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
      decoration: InputDecoration(
        hintText: 'ค้นหาชื่อ, อีเมล, หรือเบอร์โทร...',
        hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText.withOpacity(0.6)),
        prefixIcon: const Icon(Icons.search, color: AppColors.mutedBrown),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.inputFocusedBorder, width: 2)),
        filled: true,
        fillColor: AppColors.formBackground, // ใช้สีพื้นหลังฟอร์มที่สะอาดตา
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildInstructorTable(BuildContext context) {
    if (filteredInstructors.isEmpty) {
      return Center(
        child: Text('ไม่พบข้อมูลผู้สอน', style: TextStyles.title.copyWith(color: AppColors.secondaryText)),
      );
    }
    
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table Header (ส่วนหัวตาราง)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.warmGray, // ใช้สี Warm Gray ให้เด่นขึ้น
              border: Border(bottom: BorderSide(color: AppColors.inputBorder, width: 2)),
            ),
            child: Row(
              children: [
                _buildHeaderCell('รูป', width: 80, alignment: Alignment.center),
                _buildHeaderCell('ชื่อ - นามสกุล', flex: 2),
                _buildHeaderCell('อีเมล', flex: 3),
                _buildHeaderCell('เบอร์โทรศัพท์', flex: 2),
                _buildHeaderCell('จัดการ', flex: 1, alignment: Alignment.center),
              ],
            ),
          ),
          
          // Table Body
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _getCurrentPageItems().length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.inputBorder,
              ),
              itemBuilder: (context, index) {
                final instructor = _getCurrentPageItems()[index];
                return _buildInstructorRow(context, instructor);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget ช่วยสร้าง Header Cell
  Widget _buildHeaderCell(String text, {int? flex, double? width, Alignment alignment = Alignment.centerLeft}) {
    final content = Align(
      alignment: alignment,
      child: Text(
        text,
        style: TextStyles.label.copyWith(
          fontWeight: FontStyles.bold,
          color: AppColors.primaryBlack, // ใช้สีดำที่เข้มขึ้น
          fontSize: 15,
        ),
      ),
    );
    
    if (flex != null) {
      return Expanded(flex: flex, child: content);
    } else if (width != null) {
      return SizedBox(width: width, child: content);
    }
    return content;
  }
  
  // Widget สร้าง Row ข้อมูลผู้สอน
  Widget _buildInstructorRow(BuildContext context, Map<String, dynamic> instructor) {
    final instructorPicture = instructor['instructorPicture'];
    final imageUrl = instructorPicture != null && instructorPicture.isNotEmpty
        ? 'http://localhost:3000/assets/instructor/$instructorPicture'
        : 'https://placehold.co/60x60/cccccc/000000?text=No+Img';
    
    return Material(
      color: AppColors.formBackground,
      child: InkWell(
        onTap: () => onEditInstructor(instructor['instructorId']), // สามารถแตะที่แถวเพื่อแก้ไข
        hoverColor: AppColors.lightAccent.withOpacity(0.5), // เพิ่มลูกเล่น hover
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Row(
            children: [
              // รูปภาพ (Circle Avatar)
              SizedBox(
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.inputBorder, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 30, color: AppColors.secondaryText);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // ชื่อ
              Expanded(
                flex: 2,
                child: Text(
                  '${instructor['instructorName']} ${instructor['instructorLname']}',
                  style: TextStyles.body.copyWith(
                    color: AppColors.primaryBlack,
                    fontWeight: FontStyles.semiBold,
                  ),
                ),
              ),
              // อีเมล
              Expanded(
                flex: 3,
                child: Text(
                  instructor['instructorEmail'] ?? '-',
                  style: TextStyles.body.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              // เบอร์โทร
              Expanded(
                flex: 2,
                child: Text(
                  instructor['instructorTel'] ?? '-',
                  style: TextStyles.body.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              // จัดการ (Actions)
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ปุ่ม Edit
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      color: AppColors.darkAccent,
                      onTap: () => onEditInstructor(instructor['instructorId']),
                      tooltip: 'แก้ไข',
                    ),
                    const SizedBox(width: 8),
                    // ปุ่ม Delete
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: Colors.red.shade700,
                      onTap: () => onDeleteInstructor(instructor),
                      tooltip: 'ลบ',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget ช่วยสร้างปุ่มจัดการ
  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap, required String tooltip}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Tooltip(
          message: tooltip,
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  // ปรับปรุง Pagination ให้สอดคล้องกับสไตล์
  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final page = index + 1;
          final isActive = page == currentPage;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => onPageChanged(page),
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? AppColors.darkAccent : AppColors.subtleGray,
                foregroundColor: isActive ? AppColors.buttonText : AppColors.primaryBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: isActive ? 4 : 0,
                minimumSize: const Size(40, 40),
              ),
              child: Text(
                '$page', 
                style: TextStyles.body.copyWith(fontWeight: isActive ? FontStyles.semiBold : FontStyles.regular),
              ),
            ),
          );
        }),
      ),
    );
  }
}
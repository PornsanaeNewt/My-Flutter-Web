import 'package:flutter/material.dart';
import 'package:project_web/model/School.dart';
import 'package:project_web/screens/edit_school_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/font-style.dart';
import 'package:project_web/styles/text-style.dart';

class SchoolDetailWidget extends StatelessWidget {
  final School schoolData;
  final Function(bool) onEditComplete;

  const SchoolDetailWidget({
    super.key,
    required this.schoolData,
    required this.onEditComplete,
  });


  Widget _buildPictureDisplay(String? filename) {
    final imageUrl = filename != null && filename.isNotEmpty
        ? 'http://localhost:3000/assets/school/$filename'
        : 'https://placehold.co/400x320/EFE4D6/7A6B4F?text=No+Image';

    return Center(
      child: Container(
        width: 400,
        height: 320,
        margin: const EdgeInsets.only(bottom: 32), 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.lightAccent,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primaryButton,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image, size: 60, color: AppColors.secondaryText),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String? value, {int maxLines = 1}) {
    final bool isTextArea = maxLines > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyles.label.copyWith(color: AppColors.primaryBlack, fontWeight: FontStyles.regular)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            constraints: isTextArea ? const BoxConstraints(minHeight: 100) : null,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder, width: 1.0),
            ),
            child: Text(
              value ?? 'N/A',
              style: TextStyles.input.copyWith(color: AppColors.primaryText),
              maxLines: isTextArea ? null : maxLines,
              overflow: isTextArea ? TextOverflow.clip : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionDivider(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(color: AppColors.inputBorder, height: 1),
        const SizedBox(height: 16),
        Text(
            title,
            style: TextStyles.title.copyWith(fontSize: FontStyles.title, fontWeight: FontStyles.semiBold, color: AppColors.primaryBlack),
        ),
        const Divider(color: AppColors.inputBorder, height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center( 
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'รายละเอียดโรงเรียน',
                style: TextStyles.title.copyWith(fontSize: FontStyles.heading, color: AppColors.primaryBlack),
              ),
              const SizedBox(height: 32),
              _buildPictureDisplay(schoolData.schoolPicture),

              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: AppColors.formBackground,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ข้อมูลทั่วไป',
                        style: TextStyles.title.copyWith(fontSize: FontStyles.title, fontWeight: FontStyles.semiBold, color: AppColors.primaryBlack),
                      ),
                      const Divider(color: AppColors.inputBorder, height: 16),
                      
                      _buildInfoField('ชื่อโรงเรียน', schoolData.schoolName),
                      _buildInfoField('รายละเอียด', schoolData.schoolDetail, maxLines: 5), 
                      _buildInfoField('ที่อยู่', schoolData.schoolAddress),
                      
                      _buildSectionDivider('ข้อมูลการติดต่อ'),

                      _buildInfoField('เบอร์โทร', schoolData.schoolTel),
                      _buildInfoField('อีเมล', schoolData.schoolEmail),
                      
                      _buildSectionDivider('พิกัดทางภูมิศาสตร์'),

                      Row(
                        children: [
                          Expanded(child: _buildInfoField('ละติจูด', schoolData.schoolLatitude?.toString())),
                          const SizedBox(width: 20),
                          Expanded(child: _buildInfoField('ลองจิจูด', schoolData.schoolLongitude?.toString())),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32), 
              
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditSchoolPage(school: schoolData),
                      ),
                    );
                    if (result == true) {
                      onEditComplete(true);
                    }
                  },
                  icon: const Icon(Icons.edit, color: AppColors.buttonText),
                  label: Text('แก้ไขข้อมูลโรงเรียน', style: TextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    shadowColor: AppColors.primaryButton.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
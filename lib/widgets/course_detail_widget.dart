import 'package:flutter/material.dart';
import 'package:project_web/controllers/courseController.dart';
import 'package:project_web/model/Course.dart';
import 'package:project_web/model/CourseDetail.dart';
import 'package:project_web/screens/list_registration_page.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'package:intl/intl.dart';

class CourseDetailBody extends StatelessWidget {
  final Course course;
  final String courseType;
  final List<String> imageUrls;
  final List<CourseDetail> courseDetails;
  final Map<String, String> instructorNames;
  final List<dynamic> reviews;
  final bool isReviewsLoading;

  final ScrollController scrollController;
  final bool showLeftButton;
  final bool showRightButton;
  final VoidCallback onScrollLeft;
  final VoidCallback onScrollRight;

  final VoidCallback onEditCourse;
  final VoidCallback onAddSchedule;
  final Future<void> Function(CourseDetail schedule) onEditSchedule;
  final void Function(CourseDetail schedule) onDeleteSchedule;
  final Future<void> Function(CourseDetail schedule, bool isOpen) onOpenCloseSchedule;

  const CourseDetailBody({
    super.key,
    required this.course,
    required this.courseType,
    required this.imageUrls,
    required this.courseDetails,
    required this.instructorNames,
    required this.reviews,
    required this.isReviewsLoading,
    required this.scrollController,
    required this.showLeftButton,
    required this.showRightButton,
    required this.onScrollLeft,
    required this.onScrollRight,
    required this.onEditCourse,
    required this.onAddSchedule,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.onOpenCloseSchedule,
  });
  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLeft,
  }) {
    final double horizontalPadding = isLeft ? 10 : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Card(
        elevation: 6,
        shape: const CircleBorder(),
        color: AppColors.formBackground.withOpacity(0.9),
        child: IconButton(
          icon: Icon(icon, color: AppColors.primaryBlack, size: 20),
          onPressed: onPressed,
          padding: const EdgeInsets.all(8),
          splashRadius: 24,
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String? value, {int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.label.copyWith(color: AppColors.mutedBrown),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.lightAccent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Text(
              value ?? 'N/A',
              style: TextStyles.body.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w500,
              ),
              maxLines: maxLines,
              overflow:
                  maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondaryText),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyles.body.copyWith(color: AppColors.secondaryText),
        ),
        Text(
          value,
          style: TextStyles.body.copyWith(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTimeItem(
    IconData icon,
    String label,
    String value, {
    bool isExpanded = false,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.mutedBrown),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyles.body.copyWith(
            color: AppColors.mutedBrown,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyles.body.copyWith(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    return isExpanded ? Expanded(child: content) : content;
  }
  
  // [END] Helper Widgets

  Widget _buildImageCarousel() {
    if (imageUrls.isEmpty) {
      return Text(
        'ไม่มีรูปภาพสำหรับหลักสูตรนี้',
        style: TextStyles.body.copyWith(
          color: AppColors.secondaryText,
        ),
      );
    }
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            child: Row(
              children: imageUrls.map((url) {
                return Container(
                  width: 300,
                  height: 250,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.inputBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    'http://localhost:3000/assets/course/$url',
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 50,
                          color: AppColors.secondaryText,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (showLeftButton)
            Positioned(
              left: 0,
              child: _buildScrollButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: onScrollLeft,
                isLeft: true,
              ),
            ),
          if (showRightButton)
            Positioned(
              right: 0,
              child: _buildScrollButton(
                icon: Icons.arrow_forward_ios,
                onPressed: onScrollRight,
                isLeft: false,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.formBackground,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ข้อมูลทั่วไปของหลักสูตร',
                  style: TextStyles.title.copyWith(fontSize: 22),
                ),
                ElevatedButton.icon(
                  onPressed: onEditCourse,
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.buttonText,
                    size: 18,
                  ),
                  label: Text(
                    'แก้ไขหลักสูตร',
                    style: TextStyles.button.copyWith(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 30, color: AppColors.inputBorder),
            _buildInfoField('ชื่อหลักสูตร', course.name),
            _buildInfoField(
              'รายละเอียด',
              course.description,
              maxLines: null,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                    'ราคา',
                    '${course.price?.toStringAsFixed(2) ?? 'N/A'} บาท',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildInfoField(
                    'ประเภทหลักสูตร',
                    courseType,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    if (courseDetails.isEmpty) {
      return Center(
        child: Text(
          'ไม่มีกำหนดการสำหรับหลักสูตรนี้',
          style: TextStyles.body.copyWith(color: AppColors.secondaryText),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courseDetails.length,
      itemBuilder: (context, index) {
        final schedule = courseDetails[index];
        final instructorName =
            instructorNames[schedule.instructorId] ?? 'ไม่พบผู้สอน';

        String format(String dateString) {
          try {
            return DateFormat('d MMMM y', 'th').format(
              DateTime.parse(dateString).toLocal(),
            );
          } catch (_) {
            return dateString;
          }
        }

        final formattedRegistOpen = format(schedule.registOpen);
        final formattedRegistClose = format(schedule.registClose);
        final formattedStartDate = format(schedule.startDate);
        final formattedEndDate = format(schedule.endDate);

        return FutureBuilder<int>(
          future: CourseController.fetchRegistrationCount(schedule.id),
          builder: (context, snapshot) {
            int registrationCount = snapshot.data ?? 0;
            bool currentScheduleStatus = schedule.scheduleStatus == 'open';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.formBackground,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ผู้สอน: ${instructorName}',
                          style: TextStyles.label.copyWith(
                            color: AppColors.primaryBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              currentScheduleStatus
                                  ? 'เปิดลงทะเบียน'
                                  : 'ปิดลงทะเบียน',
                              style: TextStyles.body.copyWith(
                                color: currentScheduleStatus
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Switch(
                              value: currentScheduleStatus,
                              onChanged: (bool value) =>
                                  onOpenCloseSchedule(schedule, value),
                              activeColor: Colors.green.shade600,
                              inactiveTrackColor: Colors.red.shade200,
                              inactiveThumbColor: Colors.red.shade600,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.subtleGray),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildScheduleDetailItem(
                          Icons.schedule,
                          'เวลาเรียน',
                          '${schedule.time} ชั่วโมง',
                        ),
                        _buildScheduleDetailItem(
                          Icons.group,
                          'จำนวนที่นั่ง',
                          '$registrationCount / ${schedule.capacity}',
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListRegistrationPage(
                                  scheduleId: schedule.id,
                                  courseId: course.id ?? 'N/A',
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.people_outline,
                            size: 18,
                            color: AppColors.buttonText,
                          ),
                          label: Text(
                            'รายชื่อผู้ลงทะเบียน',
                            style: TextStyles.button.copyWith(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildScheduleTimeItem(
                      Icons.date_range,
                      'เปิดลงทะเบียน',
                      '$formattedRegistOpen - $formattedRegistClose',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildScheduleTimeItem(
                          Icons.school,
                          'วันที่เรียน',
                          '$formattedStartDate - $formattedEndDate',
                          isExpanded: true,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: AppColors.mutedBrown,
                              ),
                              tooltip: 'แก้ไขกำหนดการ',
                              onPressed: () => onEditSchedule(schedule),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade700,
                              ),
                              tooltip: 'ลบกำหนดการ',
                              onPressed: () => onDeleteSchedule(schedule),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewSection() {
    if (isReviewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความคิดเห็นจากผู้เรียน',
          style: TextStyles.title.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 20),
        if (reviews.isEmpty)
          Center(
            child: Text(
              'ยังไม่มีความคิดเห็นสำหรับหลักสูตรนี้',
              style: TextStyles.body.copyWith(color: AppColors.secondaryText),
            ),
          )
        else
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final reviewMap = reviews[index] as Map<String, dynamic>;
                final reviewPoint = (reviewMap['reviewPoint'] as num).toDouble();

                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: AppColors.formBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryButton,
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.buttonText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${reviewMap['stuName']} ${reviewMap['stuLname']}',
                                style: TextStyles.label.copyWith(
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < reviewPoint
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber.shade600,
                                size: 22,
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              reviewMap['reviews'] as String,
                              style: TextStyles.body.copyWith(
                                color: AppColors.primaryBlack,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'รูปภาพหลักสูตร',
                style: TextStyles.title.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 20),
              _buildImageCarousel(),
              const SizedBox(height: 40),
              _buildCourseInfoCard(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รายการกำหนดการ',
                    style: TextStyles.title.copyWith(fontSize: 22),
                  ),
                  ElevatedButton.icon(
                    onPressed: onAddSchedule,
                    icon: Icon(
                      Icons.add,
                      color: AppColors.buttonText,
                      size: 18,
                    ),
                    label: Text(
                      'สร้างกำหนดการลงทะเบียนใหม',
                      style: TextStyles.button.copyWith(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildScheduleList(),
              const SizedBox(height: 40),
              _buildReviewSection(),
            ],
          ),
        ),
      ),
    );
  }
}
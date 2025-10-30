import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_web/model/CourseDetail.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';

class InstructorScheduleCalendar extends StatefulWidget {
  final String? instructorId;
  final List<CourseDetail> schedules;
  final bool isLoading;

  const InstructorScheduleCalendar({
    super.key,
    required this.instructorId,
    required this.schedules,
    required this.isLoading,
  });

  @override
  State<InstructorScheduleCalendar> createState() => _InstructorScheduleCalendarState();
}

class _InstructorScheduleCalendarState extends State<InstructorScheduleCalendar> {
  DateTime _displayDate = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _displayDate = DateUtils.dateOnly(DateTime.now());
  }

  Set<DateTime> _getInstructorTeachingDates(List<CourseDetail> schedules) {
    final Set<DateTime> dates = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var detail in schedules) {
      try {
        final startDate = dateFormat.parse(detail.startDate);
        final endDate = dateFormat.parse(detail.endDate);

        DateTime currentDate = DateUtils.dateOnly(startDate);
        final endDay = DateUtils.dateOnly(endDate);

        while (currentDate.isBefore(endDay) || currentDate.isAtSameMomentAs(endDay)) {
          dates.add(currentDate);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } catch (e) {
        print('Error parsing date for schedule ${detail.id}: $e');
      }
    }
    return dates;
  }

  void _changeMonth(int monthDelta) {
    setState(() {
      _displayDate = DateUtils.addMonthsToMonthDate(_displayDate, monthDelta);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.instructorId == null) {
      return const Center(child: Text('กรุณาเลือกผู้สอนเพื่อดูตารางสอน'));
    }
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final firstDayOfMonth = DateUtils.dateOnly(
      DateTime(_displayDate.year, _displayDate.month, 1),
    );
    final lastDayOfMonth = DateUtils.dateOnly(
      DateTime(_displayDate.year, _displayDate.month + 1, 0),
    );
    final teachingDates = _getInstructorTeachingDates(widget.schedules);
    final today = DateUtils.dateOnly(DateTime.now());

    final int startDayOffset = firstDayOfMonth.weekday % 7; 

    List<Widget> calendarDays = [];
    
    for (int i = 0; i < startDayOffset; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    DateTime currentDay = firstDayOfMonth;
    while (currentDay.isBefore(lastDayOfMonth) || currentDay.isAtSameMomentAs(lastDayOfMonth)) {
      final dayOnly = DateUtils.dateOnly(currentDay);
      final isTeachingDay = teachingDates.contains(dayOnly);
      final isCurrentMonth = currentDay.month == _displayDate.month;
      final isToday = dayOnly.isAtSameMomentAs(today);

      calendarDays.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              constraints: const BoxConstraints(minHeight: 30, minWidth: 50),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTeachingDay 
                    ? Colors.red.withOpacity(0.9) 
                    : (isToday ? AppColors.inputFocusedBorder.withOpacity(0.3) : Colors.transparent), 
                shape: BoxShape.circle,
                border: isToday && !isTeachingDay ? Border.all(color: AppColors.primaryBlack, width: 1) : null,
              ),
              child: Text(
                '${currentDay.day}',
                style: TextStyles.body.copyWith(
                  fontSize: 10,
                  color: isTeachingDay 
                      ? Colors.white 
                      : (isCurrentMonth ? AppColors.primaryBlack : AppColors.secondaryText),
                  fontWeight: isTeachingDay || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
      currentDay = currentDay.add(const Duration(days: 1));
    }
    
    List<Widget> monthRows = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      final rowDays = calendarDays.sublist(
        i,
        i + 7 > calendarDays.length ? calendarDays.length : i + 7,
      );
      
      if (rowDays.length < 7) {
        final padding = List.generate(
          7 - rowDays.length, 
          (_) => const Expanded(child: SizedBox()),
        );
        monthRows.add(Row(children: [...rowDays, ...padding]));
      } else {
        monthRows.add(Row(children: rowDays));
      }
    }


    final thaiYear = _displayDate.year + 543;
    final thaiMonth = DateFormat('MMMM', 'th').format(_displayDate);

    final List<String> weekDays = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

    return Container(
      padding: const EdgeInsets.all(8.0), 
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                onPressed: () => _changeMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '$thaiMonth $thaiYear', 
                style: TextStyles.title.copyWith(fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                onPressed: () => _changeMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: day == 'อา' ? Colors.red : AppColors.primaryBlack, 
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 8, thickness: 0.5),

          Column(
            children: monthRows,
          ),
        ],
      ),
    );
  }
}
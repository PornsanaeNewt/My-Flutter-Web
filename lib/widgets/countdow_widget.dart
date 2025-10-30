import 'package:flutter/material.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';
import 'dart:async';
import 'package:project_web/controllers/registrationController.dart'; 
import 'package:project_web/controllers/courseController.dart';

class ScheduleCountdownWidget extends StatefulWidget {
  final int scheduleId;
  final String startDate;
  final String endDate;  
  final bool isManuallyCompleted; 
  final VoidCallback? onCountdownComplete; 

  const ScheduleCountdownWidget({
    super.key,
    required this.scheduleId,
    required this.startDate,
    required this.endDate,
    required this.isManuallyCompleted, 
    this.onCountdownComplete, 
  });

  @override
  State<ScheduleCountdownWidget> createState() => _ScheduleCountdownWidgetState();
}

class _ScheduleCountdownWidgetState extends State<ScheduleCountdownWidget> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  String _statusMessage = 'กำลังโหลดสถานะ...';
  Color _statusColor = AppColors.secondaryText;
  
  String _currentStatus = 'Loading'; 

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }
  
  @override
  void didUpdateWidget(covariant ScheduleCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.startDate != oldWidget.startDate || 
        widget.endDate != oldWidget.endDate ||
        widget.isManuallyCompleted != oldWidget.isManuallyCompleted) 
    {
        _startCountdownTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime? _safeParseDate(String dateString) {
    if (dateString.isEmpty) {
      return null;
    }
    final String fullDateString = '${dateString.split('T').first}T00:00:00Z';
    return DateTime.tryParse(fullDateString)?.toLocal();
  }

  Future<void> _handleStatusTransition(String oldStatus, String newStatus) async {
    if (oldStatus == newStatus) return;
    if (oldStatus == 'Loading' || oldStatus == 'Error') return;

    if (widget.isManuallyCompleted) return;

    try {
        final List<Map<String, dynamic>> registrations = 
            await RegistrationController.fetchRegistrationData(widget.scheduleId);
        
        final List<String> stuIds = registrations
            .map((reg) => reg['stuId'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        if (newStatus == 'InProgress' && oldStatus == 'NotStarted') {
            for (final stuId in stuIds) {
                RegistrationController.startRegistration(widget.scheduleId, stuId).catchError((e) {
                    print('Error starting registration for $stuId: $e');
                });
            }
            print('Called startRegistration for all students.');
        } else if (newStatus == 'Completed' && oldStatus == 'InProgress') {
            for (final stuId in stuIds) {
                RegistrationController.completeRegistration(widget.scheduleId, stuId).catchError((e) {
                    print('Error completing registration for $stuId: $e');
                });
            }
            print('Called completeRegistration for all students.');
            
            await CourseController.openAndCloseSchedule(widget.scheduleId, 'close');
            print('Schedule status set to close after auto-complete.');
        }
    } catch (e) {
        print('Error handling status transition or fetching data: $e');
        if (mounted) {
            setState(() {
                _statusMessage = 'ข้อผิดพลาดในการอัปเดตสถานะ: ${e.toString().split(':').last}';
                _statusColor = Colors.orange.shade700;
            });
        }
    }
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    
    final DateTime? startDate = _safeParseDate(widget.startDate);
    final DateTime? endDate = _safeParseDate(widget.endDate);
    
    if (startDate == null || endDate == null) {
      setState(() {
        _currentStatus = 'Error';
        _statusMessage = 'ข้อผิดพลาด: รูปแบบวันที่ไม่ถูกต้อง'; 
        _statusColor = Colors.red.shade700;
      });
      return;
    }
    void updateStatus(Timer timer) {
        final DateTime currentTime = DateTime.now();
        final String oldStatus = _currentStatus; 
        String newStatus = oldStatus; 

        if (widget.isManuallyCompleted) {
             newStatus = 'Completed';
            _statusMessage = 'หลักสูตรเสร็จสิ้นสมบูรณ์';
            _statusColor = Colors.green;
            timer.cancel();
            _timeRemaining = Duration.zero;
        } else {
            final DateTime dayAfterEndDate = endDate.add(const Duration(days: 1)); 
            
            if (currentTime.isBefore(startDate)) {
                newStatus = 'NotStarted';
                _statusColor = Colors.red.shade700;
                _timeRemaining = startDate.difference(currentTime);
            } else if (currentTime.isBefore(dayAfterEndDate)) { 
                newStatus = 'InProgress';
                _statusMessage = 'กำลังทำการเรียนการสอน';
                _statusColor = Colors.blue.shade700;
                _timeRemaining = dayAfterEndDate.difference(currentTime);
            } else {
                newStatus = 'Completed';
                _statusMessage = 'หลักสูตรเสร็จสิ้นสมบูรณ์'; 
                _statusColor = Colors.green;
                timer.cancel();
                _timeRemaining = Duration.zero;
                
                if (oldStatus == 'InProgress' && widget.onCountdownComplete != null) {
                    widget.onCountdownComplete!();
                }
            }
        }
        if (newStatus != oldStatus) {
            _handleStatusTransition(oldStatus, newStatus);
        }
        _currentStatus = newStatus;
        if (mounted) {
            setState(() {});
        } else {
            timer.cancel();
        }
    }

    if (widget.isManuallyCompleted && mounted) {
        updateStatus(Timer(Duration.zero, () {}));
    } else if (!widget.isManuallyCompleted) {
        _timer = Timer.periodic(const Duration(seconds: 1), updateStatus);
        updateStatus(_timer!);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 0) return '00:00:00';
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String days = duration.inDays > 0 ? '${duration.inDays} วัน ' : '';
    final String hours = twoDigits(duration.inHours.remainder(24));
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (_currentStatus == 'NotStarted') {
        final remainingDays = duration.inDays + 1;
        return 'อีก $remainingDays วันจะเริ่ม';
    }
    
    return '$days$hours ชม. $minutes น. $seconds ว.';
  }

  @override
  Widget build(BuildContext context) {

    if (_currentStatus == 'Completed') {
        return Text(
            _statusMessage,
            style: TextStyles.body.copyWith(
                color: _statusColor,
                fontWeight: FontWeight.bold,
            ),
        );
    }
    
    if (_currentStatus == 'NotStarted') {
        final String countdownText = _formatDuration(_timeRemaining);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'หลักสูตรนี้ยังไม่เริ่ม',
              style: TextStyles.body.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              countdownText,
              style: TextStyles.body.copyWith(color: AppColors.primaryBlack),
            ),
          ],
        );
    } 
    
    if (_currentStatus == 'InProgress') {
      final String countdownText = _formatDuration(_timeRemaining);
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusMessage, 
            style: TextStyles.body.copyWith(
              color: _statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_timeRemaining.inSeconds > 0)
            Text(
              'เหลือเวลา: $countdownText',
              style: TextStyles.body.copyWith(color: AppColors.primaryBlack),
            ),
        ],
      );
    }

    return Text(
        _statusMessage,
        style: TextStyles.body.copyWith(
            color: _statusColor,
            fontWeight: FontWeight.bold,
        ),
    );
  }
}
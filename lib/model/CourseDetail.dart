class CourseDetail {
  final int id;
  final int capacity;
  final String registOpen;
  final String registClose; 
  final String startDate; 
  final String endDate;
  final double time; 
  final String scheduleStatus;
  final String courseId; 
  final String instructorId; 

  CourseDetail({
    required this.id,
    required this.registOpen,
    required this.registClose,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.capacity,
    this.scheduleStatus = 'free', 
    required this.courseId, 
    required this.instructorId,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: json['scheduleId'] as int,
      capacity: json['capacity'] as int,
      registOpen: json['registOpen'] as String? ?? '', 
      registClose: json['registClose'] as String? ?? '', 
      startDate: json['startDate'] as String? ?? '', 
      endDate: json['endDate'] as String? ?? '', 
      time: json['studyTime'] as double, 
      scheduleStatus: json['scheduleStatus'] as String,
      courseId: json['courseId'].toString(), 
      instructorId: json['instructorId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId, 
      'registOpen': registOpen,
      'registClose': registClose,
      'startDate': startDate,
      'endDate': endDate,
      'studyTime': time,
      'capacity': capacity,
      'scheduleStatus': scheduleStatus,
      'instructorId': instructorId, 
    };
  }
}
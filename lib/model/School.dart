class School {
  final String? schoolId;
  final String? schoolName;
  final String? schoolEmail;
  final String? schoolPassword; 
  final String? schoolDetail;
  final String? schoolAddress;
  final double? schoolLatitude;
  final double? schoolLongitude;
  final String? schoolPicture;
  final String? schoolStatus;
  final String? schoolTel;

  School({
    required this.schoolId,
    required this.schoolName,
    required this.schoolEmail,
    required this.schoolPassword, 
    required this.schoolDetail,
    required this.schoolAddress,
    required this.schoolLatitude,
    required this.schoolLongitude,
    required this.schoolPicture,
    required this.schoolStatus,
    required this.schoolTel,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolId: json['schoolId'] as String?,
      schoolName: json['schoolName'] as String?,
      schoolEmail: json['schoolEmail'] as String?,
      schoolPassword: json['schoolPassword'] as String?, 
      schoolDetail: json['schoolDetail'] as String?,
      schoolAddress: json['schoolAddress'] as String?,
      schoolLatitude: (json['schoolLatitude'] as num?)?.toDouble(), 
      schoolLongitude: (json['schoolLongitude'] as num?)?.toDouble(),
      schoolPicture: json['schoolPicture'] as String?,
      schoolStatus: json['schoolStatus'] as String?,
      schoolTel: json['schoolTel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolID': schoolId,
      'schoolName': schoolName,
      'schoolEmail': schoolEmail,
      'schoolPassword': schoolPassword,
      'schoolDetail': schoolDetail,
      'schoolAddress': schoolAddress,
      'schoolLatitude': schoolLatitude,
      'schoolLongitude': schoolLongitude,
      'schoolPicture': schoolPicture,
      'schoolStatus': schoolStatus,
      'schoolTel': schoolTel,
    };
  }
}

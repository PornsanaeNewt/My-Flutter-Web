class Instructor {
  
  final String? instructorId;
  final DateTime? instructorBirthday;
  final String? instructorEmail;
  final bool instructorGender; 
  final String? instructorName;
  final String? instructorLname;
  final String? instructorPicture;
  final String? instructorTel;
  final String? schoolId;

  Instructor({
    required this.instructorId,
    required this.instructorBirthday,
    required this.instructorGender,
    required this.instructorEmail,
    required this.instructorName,
    required this.instructorLname,
    required this.instructorPicture,
    required this.instructorTel,
    required this.schoolId,
    
  });

  Map<String, dynamic> toJson() {
    return {
      'instructorId': instructorId,
      'instructorBirthday': instructorBirthday?.toIso8601String(),
      'instructorEmail': instructorEmail,
      'instructorGender': instructorGender ? 1 : 0,
      'instructorName': instructorName,
      'instructorLname': instructorLname,
      'instructorPicture': instructorPicture,
      'instructorTel': instructorTel,
      'schoolId': schoolId,
    };
  }
}
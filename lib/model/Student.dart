class Student {
  final String? stuId;
  final String? stuBirthday;
  final String? stuEmail;
  final bool stuGender;
  final String? stuName;
  final String? stuLname;
  final String? stuPassword;
  final String? stuPicture;
  final String? stuTel;

  Student({
    required this.stuId,
    required this.stuBirthday,
    required this.stuEmail,
    required this.stuGender,
    required this.stuName,
    required this.stuLname,
    required this.stuPassword,
    required this.stuPicture,
    required this.stuTel,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    final stuGenderValue = json['stuGender'];
    final bool stuGender = stuGenderValue is int 
        ? stuGenderValue == 1 
        : stuGenderValue is bool
            ? stuGenderValue
            : false; 
    return Student(
      stuId: json['stuId'] as String? ?? '',
      stuBirthday: json['stuBirthday'] as String? ?? '',
      stuEmail: json['stuEmail'] as String? ?? '', 
      stuGender: stuGender, 
      stuName: json['stuName'] as String? ?? '', 
      stuLname: json['stuLname'] as String? ?? '', 
      stuPassword: json['stuPassword'] as String? ?? '', 
      stuPicture: json['stuPicture'] as String? ?? '',
      stuTel: json['stuTel'] as String? ?? '', 
    );
  }
}
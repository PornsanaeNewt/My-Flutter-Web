class Registration {
  final int registId;
  final String address;
  final String registDate;
  final String registStatus;
  final int scheduleId;
  final String stuId;

  Registration ({
    required this.registId,
    required this.address, 
    required this.registDate, 
    required this.registStatus, 
    required this.scheduleId, 
    required this.stuId, 
  });


  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      registId: json['registId'] as int,
      address: json['address'] as String? ?? '',
      registDate: json['registDate'] as String? ?? '', 
      registStatus: json['registStatus'] as String? ?? '', 
      scheduleId: json['scheduleId'] as int, 
      stuId: json['stuId'] as String? ?? '', 
    );
  }
}
class Notifications {
  final int notiId;
  final String notiDate;
  final String notiDetails;
  final String notiType;
  final String notiStatus;
  final int registId;
  
  Notifications ({
    required this.notiId,
    required this.notiDate, 
    required this.notiDetails, 
    required this.notiType, 
    required this.notiStatus, 
    required this.registId, 
  });
  
  Map<String, dynamic> toJson() {
    return {
      'notiId': notiId,
      'notiDate': notiDate,
      'notiDetails': notiDetails, 
      'notiType': notiType,      
      'notiStatus': notiStatus,      
      'registId': registId,
    };
  }

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      notiId: json['notiId'],
      notiDate: json['notiDate'],
      notiDetails: json['notiDetails'],
      notiType: json['notiType'],
      notiStatus: json['notiStatus'],
      registId: json['registId'],
    );
  }
}
class Company {
  final String? id;
  final String companyName;
  final String? hrName;
  final String? phone;
  final String? email;
  final String? linkedin;
  final DateTime? lastContacted;
  final DateTime? followUpDate;

  Company({
    this.id,
    required this.companyName,
    this.hrName,
    this.phone,
    this.email,
    this.linkedin,
    this.lastContacted,
    this.followUpDate,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      companyName: json['company_name'] ?? '',
      hrName: json['hr_name'],
      phone: json['phone'],
      email: json['email'],
      linkedin: json['linkedin'],
      lastContacted: json['last_contacted'] != null ? DateTime.parse(json['last_contacted']) : null,
      followUpDate: json['follow_up_date'] != null ? DateTime.parse(json['follow_up_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      if (hrName != null) 'hr_name': hrName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (linkedin != null) 'linkedin': linkedin,
      if (lastContacted != null) 'last_contacted': lastContacted!.toIso8601String(),
      if (followUpDate != null) 'follow_up_date': followUpDate!.toIso8601String(),
    };
  }
}

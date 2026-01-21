class Company {
  final String? id;
  final String name;
  final String? hrName;
  final String? hrDesignation;
  final String? phone;
  final String? email;
  final String? linkedin;
  final List<String>? hiringRoles;
  final DateTime? lastContactedDate;
  final DateTime? followUpReminder;
  final String? notes;

  Company({
    this.id,
    required this.name,
    this.hrName,
    this.hrDesignation,
    this.phone,
    this.email,
    this.linkedin,
    this.hiringRoles,
    this.lastContactedDate,
    this.followUpReminder,
    this.notes,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'] ?? '',
      hrName: json['hr_name'],
      hrDesignation: json['hr_designation'],
      phone: json['hr_phone'],
      email: json['hr_email'],
      linkedin: json['hr_linkedin'],
      hiringRoles: json['hiring_roles'] != null ? List<String>.from(json['hiring_roles']) : [],
      lastContactedDate: json['last_contacted_date'] != null ? DateTime.parse(json['last_contacted_date']) : null,
      followUpReminder: json['follow_up_reminder'] != null ? DateTime.parse(json['follow_up_reminder']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (hrName != null) 'hr_name': hrName,
      if (hrDesignation != null) 'hr_designation': hrDesignation,
      if (phone != null) 'hr_phone': phone,
      if (email != null) 'hr_email': email,
      if (linkedin != null) 'hr_linkedin': linkedin,
      if (hiringRoles != null) 'hiring_roles': hiringRoles,
      if (lastContactedDate != null) 'last_contacted_date': lastContactedDate!.toIso8601String(),
      if (followUpReminder != null) 'follow_up_reminder': followUpReminder!.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }
}

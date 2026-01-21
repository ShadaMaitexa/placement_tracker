class PlacementDrive {
  final String? id;
  final String companyId;
  final String title;
  final String jobRole;
  final String? description;
  final String? location;
  final String? eligibilityCriteria;
  final DateTime? driveDate;
  final DateTime? applicationDeadline;
  final String? salaryPackage; // Maps to salary_range in DB
  final String status; // upcoming, ongoing, completed, cancelled
  
  // Read-only field for joining
  final String? companyName; 

  PlacementDrive({
    this.id,
    required this.companyId,
    required this.title,
    required this.jobRole,
    this.description,
    this.location,
    this.eligibilityCriteria,
    this.driveDate,
    this.applicationDeadline,
    this.salaryPackage,
    this.status = 'upcoming',
    this.companyName,
  });

  factory PlacementDrive.fromJson(Map<String, dynamic> json) {
    return PlacementDrive(
      id: json['id'],
      companyId: json['company_id'],
      title: json['title'] ?? json['job_role'] ?? 'Untitled Drive',
      jobRole: json['job_role'] ?? 'Not Specified',
      description: json['description'],
      location: json['location'],
      eligibilityCriteria: json['eligibility_criteria'],
      driveDate: json['drive_date'] != null ? DateTime.parse(json['drive_date']) : null,
      applicationDeadline: json['application_deadline'] != null ? DateTime.parse(json['application_deadline']) : null,
      salaryPackage: json['salary_range'],
      status: json['status'] ?? 'upcoming',
      companyName: json['companies'] != null ? json['companies']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'title': title,
      'job_role': jobRole,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (eligibilityCriteria != null) 'eligibility_criteria': eligibilityCriteria,
      if (driveDate != null) 'drive_date': driveDate!.toIso8601String(),
      if (applicationDeadline != null) 'application_deadline': applicationDeadline!.toIso8601String(),
      if (salaryPackage != null) 'salary_range': salaryPackage,
      'status': status,
    };
  }
}

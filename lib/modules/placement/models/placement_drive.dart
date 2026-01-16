class PlacementDrive {
  final String? id;
  final String companyId;
  final String jobRole;
  final String? description;
  final DateTime? driveDate;
  final String? salaryPackage;
  final String status; // scheduled, completed, cancelled
  
  // Read-only field for joining
  final String? companyName; 

  PlacementDrive({
    this.id,
    required this.companyId,
    required this.jobRole,
    this.description,
    this.driveDate,
    this.salaryPackage,
    this.status = 'scheduled',
    this.companyName,
  });

  factory PlacementDrive.fromJson(Map<String, dynamic> json) {
    return PlacementDrive(
      id: json['id'],
      companyId: json['company_id'],
      jobRole: json['job_role'],
      description: json['description'],
      driveDate: json['drive_date'] != null ? DateTime.parse(json['drive_date']) : null,
      salaryPackage: json['salary_package'],
      status: json['status'] ?? 'scheduled',
      companyName: json['companies'] != null ? json['companies']['company_name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'job_role': jobRole,
      if (description != null) 'description': description,
      if (driveDate != null) 'drive_date': driveDate!.toIso8601String(),
      if (salaryPackage != null) 'salary_package': salaryPackage,
      'status': status,
    };
  }
}

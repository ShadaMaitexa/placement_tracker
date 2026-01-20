class Student {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final String? collegeName;
  final String? qualification;
  final int? passingYear;
  final String? batch; // e.g., "2022-2026"
  final String? primaryCourse;
  final String? courseDuration;
  final List<String>? skills; // Tech & Non-Tech combined
  final String? resumeUrl; // Path or URL to PDF
  final String? eligibilityStatus; // 'Ready', 'Needs Training', 'Not Eligible'
  final String? createdBy;

  Student({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.collegeName,
    this.qualification,
    this.passingYear,
    this.batch,
    this.primaryCourse,
    this.courseDuration,
    this.skills,
    this.resumeUrl,
    this.eligibilityStatus,
    this.createdBy,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      collegeName: json['college_name'],
      qualification: json['qualification'],
      passingYear: json['passing_year'],
      batch: json['batch'],
      primaryCourse: json['primary_course'],
      courseDuration: json['course_duration'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      resumeUrl: json['resume_url'],
      eligibilityStatus: json['eligibility_status'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (collegeName != null) 'college_name': collegeName,
      if (qualification != null) 'qualification': qualification,
      if (passingYear != null) 'passing_year': passingYear,
      if (batch != null) 'batch': batch,
      if (primaryCourse != null) 'primary_course': primaryCourse,
      if (courseDuration != null) 'course_duration': courseDuration,
      if (skills != null) 'skills': skills,
      if (resumeUrl != null) 'resume_url': resumeUrl,
      if (eligibilityStatus != null) 'eligibility_status': eligibilityStatus,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}

class Student {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final String? qualification;
  final int? passingYear;
  final String? primaryCourse;
  final String? courseDuration;
  final String? eligibilityStatus;
  final String? createdBy; // Optional, if we track who created it

  Student({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.qualification,
    this.passingYear,
    this.primaryCourse,
    this.courseDuration,
    this.eligibilityStatus,
    this.createdBy,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      qualification: json['qualification'],
      passingYear: json['passing_year'],
      primaryCourse: json['primary_course'],
      courseDuration: json['course_duration'],
      eligibilityStatus: json['eligibility_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (qualification != null) 'qualification': qualification,
      if (passingYear != null) 'passing_year': passingYear,
      if (primaryCourse != null) 'primary_course': primaryCourse,
      if (courseDuration != null) 'course_duration': courseDuration,
      if (eligibilityStatus != null) 'eligibility_status': eligibilityStatus,
    };
  }
}

class MockInterview {
  final String? id;
  final String studentId;
  final String? interviewerId;
  final String interviewType; // hr, technical, managerial
  
  // Scores (1-10)
  final int communication;
  final int technical;
  final int confidence;
  final int bodyLanguage;
  
  final String? feedback;
  final String status; // ready, needs_improvement, not_ready
  final DateTime? conductedAt;

  // Joined Data
  final String? studentName;

  MockInterview({
    this.id,
    required this.studentId,
    this.interviewerId,
    required this.interviewType,
    required this.communication,
    required this.technical,
    required this.confidence,
    required this.bodyLanguage,
    this.feedback,
    required this.status,
    this.conductedAt,
    this.studentName,
  });

  factory MockInterview.fromJson(Map<String, dynamic> json) {
    return MockInterview(
      id: json['id'],
      studentId: json['student_id'],
      interviewerId: json['interviewer_id'],
      interviewType: json['interview_type'],
      communication: json['communication_score'] ?? 0,
      technical: json['technical_score'] ?? 0,
      confidence: json['confidence_score'] ?? 0,
      bodyLanguage: json['body_language_score'] ?? 0,
      feedback: json['feedback'],
      status: json['overall_status'] ?? 'ready',
      conductedAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      studentName: json['students'] != null ? json['students']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      if (interviewerId != null) 'interviewer_id': interviewerId,
      'interview_type': interviewType,
      'communication_score': communication,
      'technical_score': technical,
      'confidence_score': confidence,
      'body_language_score': bodyLanguage,
      if (feedback != null) 'feedback': feedback,
      'overall_status': status,
    };
  }
}

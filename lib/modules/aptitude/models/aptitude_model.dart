class AptitudeTest {
  final String? id;
  final String title;
  final String type; // quant, reasoning, verbal
  final String? assignedBatch;
  final int totalMarks;
  final DateTime? createdAt;

  AptitudeTest({
    this.id,
    required this.title,
    required this.type,
    this.assignedBatch,
    this.totalMarks = 100,
    this.createdAt,
  });

  factory AptitudeTest.fromJson(Map<String, dynamic> json) {
    return AptitudeTest(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      assignedBatch: json['assigned_batch'],
      totalMarks: json['total_marks'] ?? 100,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      if (assignedBatch != null) 'assigned_batch': assignedBatch,
      'total_marks': totalMarks,
    };
  }
}

class AptitudeResult {
  final String? id;
  final String studentId;
  final String testId;
  final int score;
  final int maxScore;
  final double accuracy;
  final int timeTakenMinutes;
  
  // Joins
  final String? studentName;
  final String? testTitle;

  AptitudeResult({
    this.id,
    required this.studentId,
    required this.testId,
    required this.score,
    required this.maxScore,
    this.accuracy = 0.0,
    this.timeTakenMinutes = 0,
    this.studentName,
    this.testTitle,
  });

  factory AptitudeResult.fromJson(Map<String, dynamic> json) {
    return AptitudeResult(
      id: json['id'],
      studentId: json['student_id'],
      testId: json['test_id'],
      score: json['score'],
      maxScore: json['max_score'],
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      timeTakenMinutes: json['time_taken_minutes'] ?? 0,
      studentName: json['students'] != null ? json['students']['name'] : null,
      testTitle: json['aptitude_tests'] != null ? json['aptitude_tests']['title'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'test_id': testId,
      'score': score,
      'max_score': maxScore,
      'accuracy': accuracy,
      'time_taken_minutes': timeTakenMinutes,
    };
  }
}

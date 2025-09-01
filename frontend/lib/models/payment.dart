class PaymentSlip {
  final String? id;
  final String studentId;
  final String classId;
  final double amount;
  final String month;
  final String slipFile;
  final String? status;
  final String? teacherComment;
  final DateTime? reviewedAt;

  PaymentSlip({
    this.id,
    required this.studentId,
    required this.classId,
    required this.amount,
    required this.month,
    required this.slipFile,
    this.status,
    this.teacherComment,
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'classId': classId,
      'amount': amount,
      'month': month,
      'slipFile': slipFile,
      'status': status,
      'teacherComment': teacherComment,
    };
  }

  factory PaymentSlip.fromJson(Map<String, dynamic> json) {
    return PaymentSlip(
      id: json['_id'] as String? ?? json['id'] as String?,
      studentId:
          json['studentId'] as String? ??
          (json['student'] is Map ? json['student']['_id'] as String? : null) ??
          '',
      classId:
          json['classId'] as String? ??
          (json['class'] is Map ? json['class']['_id'] as String? : null) ??
          '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] as String? ?? '',
      slipFile: json['slipFile'] as String? ?? '',
      status: json['status'] as String?, // Add to JSON parsing
      teacherComment: json['teacherComment'] as String?, // Add to JSON parsing
      reviewedAt:
          json['reviewedAt'] != null
              ? DateTime.parse(json['reviewedAt'])
              : null,
    );
  }
}

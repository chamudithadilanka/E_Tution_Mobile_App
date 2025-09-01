
class AttendanceRecord {
  final String id;
  final Student student;
  final Class classInfo;
  final String sessionId;
  final DateTime markedAt;

  AttendanceRecord({
    required this.id,
    required this.student,
    required this.classInfo,
    required this.sessionId,
    required this.markedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['_id'] ?? '',
      student: Student.fromJson(json['studentId']),
      classInfo: Class.fromJson(json['classId']),
      sessionId: json['sessionId'] ?? '',
      markedAt: DateTime.parse(json['markedAt']),
    );
  }
}

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> joinedClasses;
  final String role;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.joinedClasses,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      joinedClasses: List<String>.from(json['joinedClasses'] ?? []),
      role: json['role'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get fullName => '$firstName $lastName';
}

class Class {
  final String id;
  final String profileImage;
  final String className;
  final String subject;
  final String description;
  final String grade;
  final String teacher;
  final List<String> students;
  final DateTime createdAt;
  final DateTime updatedAt;

  Class({
    required this.id,
    required this.profileImage,
    required this.className,
    required this.subject,
    required this.description,
    required this.grade,
    required this.teacher,
    required this.students,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['_id'] ?? '',
      profileImage: json['profileImage'] ?? '',
      className: json['className'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      grade: json['grade'] ?? '',
      teacher: json['teacher'] ?? '',
      students: List<String>.from(json['students'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class AttendanceResponse {
  final bool success;
  final String classId;
  final int totalStudents;
  final List<AttendanceRecord> data;

  AttendanceResponse({
    required this.success,
    required this.classId,
    required this.totalStudents,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      classId: json['classId'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((item) => AttendanceRecord.fromJson(item))
          .toList(),
    );
  }
}
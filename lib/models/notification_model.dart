class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // success, error, info
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String? ?? 'info',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt'] as String),
      read: map['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }
}

class Escalation {
  final int? id;
  final int? taskId;
  final int? level;
  final String? title;
  final String? message;
  final DateTime? createdAt;
  final bool? isRead;
  final bool? isIgnored;
  final String? ignoreReason;
  final DateTime? ignoredAt;
  final int? ignoredById;
  final int? plannedEventId;

  Escalation({
    this.id,
    this.taskId,
    this.level,
    this.title,
    this.message,
    this.createdAt,
    this.isRead,
    this.isIgnored,
    this.ignoreReason,
    this.ignoredAt,
    this.ignoredById,
    this.plannedEventId,
  });

  factory Escalation.fromJson(Map<String, dynamic> json) {
    return Escalation(
      id: json['id'] ?? json['Id'],
      taskId: json['taskId'] ?? json['TaskId'],
      level: json['level'] ?? json['Level'],
      title: json['title'] ?? json['Title'],
      message: json['message'] ?? json['Message'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['CreatedAt'] != null
              ? DateTime.parse(json['CreatedAt'])
              : null),
      isRead: json['isRead'] ?? json['IsRead'] ?? false,
      isIgnored: json['isIgnored'] ?? json['IsIgnored'] ?? false,
      ignoreReason: json['ignoreReason'] ?? json['IgnoreReason'],
      ignoredAt: json['ignoredAt'] != null
          ? DateTime.parse(json['ignoredAt'])
          : (json['IgnoredAt'] != null
              ? DateTime.parse(json['IgnoredAt'])
              : null),
      ignoredById: json['ignoredById'] ?? json['IgnoredById'],
      plannedEventId: json['plannedEventId'] ?? json['PlannedEventId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'level': level,
      'title': title,
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
      'isRead': isRead,
      'isIgnored': isIgnored,
      'ignoreReason': ignoreReason,
      'ignoredAt': ignoredAt?.toIso8601String(),
      'ignoredById': ignoredById,
      'plannedEventId': plannedEventId,
    };
  }
}

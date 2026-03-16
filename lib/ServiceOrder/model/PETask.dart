class PETask {
  final String task;
  final String taskStatus;
  final String ola;
  final DateTime? taskCreatedDate;
  final DateTime? taskCompleteDate;
  final bool isUrgent;

  PETask({
    required this.task,
    required this.taskStatus,
    required this.ola,
    this.taskCreatedDate,
    this.taskCompleteDate,
    required this.isUrgent,
  });

  factory PETask.fromJson(Map<String, dynamic> json) {
    return PETask(
      task: json['task'] as String? ?? 'N/A',
      taskStatus: json['taskStatus'] as String? ?? 'N/A',
      ola: json['ola'] as String? ?? 'N/A',
      taskCreatedDate: json['taskCreatedDate'] != null
          ? DateTime.tryParse(json['taskCreatedDate'] as String)
          : null,
      taskCompleteDate: json['taskCompleteDate'] != null
          ? DateTime.tryParse(json['taskCompleteDate'] as String)
          : null,
      isUrgent: json['isUrgent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'taskStatus': taskStatus,
      'ola': ola,
      'taskCreatedDate': taskCreatedDate?.toIso8601String(),
      'taskCompleteDate': taskCompleteDate?.toIso8601String(),
      'isUrgent': isUrgent,
    };
  }
}
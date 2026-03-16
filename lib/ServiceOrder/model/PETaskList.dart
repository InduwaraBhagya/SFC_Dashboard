class Task {
  final int id;
  final String name;
  final int taskSeq;
  final String olaParameters;

  Task({
    required this.id,
    required this.name,
    required this.taskSeq,
    required this.olaParameters,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      taskSeq: json['taskSeq'] as int? ?? 0,
      olaParameters: json['olaParameters'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taskSeq': taskSeq,
      'olaParameters': olaParameters,
    };
  }
}
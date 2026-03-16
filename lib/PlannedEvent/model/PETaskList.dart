class Task {
  final int id;
  final String name;
  final int taskSeq;
  final String olA_Parameters;

  Task({
    required this.id,
    required this.name,
    required this.taskSeq,
    required this.olA_Parameters,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      taskSeq: json['taskSeq'] as int? ?? 0,
      olA_Parameters: json['olA_Parameters'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taskSeq': taskSeq,
      'olA_Parameters': olA_Parameters,
    };
  }
}
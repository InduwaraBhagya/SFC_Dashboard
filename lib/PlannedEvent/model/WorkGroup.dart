class WorkGroup {
  final int id;
  final String name;

  WorkGroup({
    required this.id,
    required this.name,
  });

  factory WorkGroup.fromJson(Map<String, dynamic> json) {
    return WorkGroup(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
} 
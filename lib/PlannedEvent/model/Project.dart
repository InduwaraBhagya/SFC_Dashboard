class Project {
  final int id;
  final String projectName;
  final DateTime createdDate;
  final List<ProjectPEMapping> projectPEs;

  Project({
    required this.id,
    required this.projectName,
    required this.createdDate,
    required this.projectPEs,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      projectName: json['projectName'],
      createdDate: DateTime.parse(json['createdDate']),
      projectPEs: (json['projectPEs'] as List)
          .map((e) => ProjectPEMapping.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectName': projectName,
      'createdDate': createdDate.toIso8601String(),
      'projectPEs': projectPEs.map((e) => e.toJson()).toList(),
    };
  }
}

class ProjectPEMapping {
  final int id;
  final int projectId;
  final int plannedEventId;
  final Project? project;
  final PlannedEvent? plannedEvent;

  ProjectPEMapping({
    required this.id,
    required this.projectId,
    required this.plannedEventId,
    this.project,
    this.plannedEvent,
  });

  factory ProjectPEMapping.fromJson(Map<String, dynamic> json) {
    return ProjectPEMapping(
      id: json['id'],
      projectId: json['projectId'],
      plannedEventId: json['plannedEventId'],
      project: json['project'] != null ? Project.fromJson(json['project']) : null,
      plannedEvent: json['plannedEvent'] != null ? PlannedEvent.fromJson(json['plannedEvent']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'plannedEventId': plannedEventId,
      'project': project?.toJson(),
      'plannedEvent': plannedEvent?.toJson(),
    };
  }
}

class PlannedEvent {
  final int id;
  final String name;

  PlannedEvent({
    required this.id,
    required this.name,
  });

  factory PlannedEvent.fromJson(Map<String, dynamic> json) {
    return PlannedEvent(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
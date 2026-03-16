import 'OLAViolateRecord.dart';

class ProjectDetailsDto {
  final int id;
  final String projectName;
  final DateTime createdDate;
  final List<ProjectPEViewModelDto> projectPEs;

  ProjectDetailsDto({
    required this.id,
    required this.projectName,
    required this.createdDate,
    required this.projectPEs,
  });

  factory ProjectDetailsDto.fromJson(Map<String, dynamic> json) {
    return ProjectDetailsDto(
      id: json['id'],
      projectName: json['projectName'],
      createdDate: DateTime.parse(json['createdDate']),
      projectPEs: (json['projectPEs'] as List)
          .map((e) => ProjectPEViewModelDto.fromJson(e))
          .toList(),
    );
  }
}

class ProjectPEViewModelDto {
  final int id;
  final int plannedEventId;
  final PlannedEvent plannedEvent;
  final String? currentTask;

  ProjectPEViewModelDto({
    required this.id,
    required this.plannedEventId,
    required this.plannedEvent,
    this.currentTask,
  });

  factory ProjectPEViewModelDto.fromJson(Map<String, dynamic> json) {
    return ProjectPEViewModelDto(
      id: json['id'],
      plannedEventId: json['plannedEventId'],
      plannedEvent: PlannedEvent.fromJson(json['plannedEvent']),
      currentTask: json['currentTask'],
    );
  }
}
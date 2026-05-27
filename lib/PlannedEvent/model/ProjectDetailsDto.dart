// import 'OLAViolateRecord.dart';

// class ProjectDetailsDto {
//   final int id;
//   final String projectName;
//   final DateTime createdDate;
//   final List<ProjectPEViewModelDto> projectPEs;

//   ProjectDetailsDto({
//     required this.id,
//     required this.projectName,
//     required this.createdDate,
//     required this.projectPEs,
//   });

//   factory ProjectDetailsDto.fromJson(Map<String, dynamic> json) {
//     return ProjectDetailsDto(
//       id: json['id'],
//       projectName: json['projectName'],
//       createdDate: DateTime.parse(json['createdDate']),
//       projectPEs: (json['projectPEs'] as List)
//           .map((e) => ProjectPEViewModelDto.fromJson(e))
//           .toList(),
//     );
//   }
// }

// class ProjectPEViewModelDto {
//   final int id;
//   final int plannedEventId;
//   final PlannedEvent plannedEvent;
//   final String? currentTask;

//   ProjectPEViewModelDto({
//     required this.id,
//     required this.plannedEventId,
//     required this.plannedEvent,
//     this.currentTask,
//   });

//   factory ProjectPEViewModelDto.fromJson(Map<String, dynamic> json) {
//     return ProjectPEViewModelDto(
//       id: json['id'],
//       plannedEventId: json['plannedEventId'],
//       plannedEvent: PlannedEvent.fromJson(json['plannedEvent']),
//       currentTask: json['currentTask'],
//     );
//   }
// }

// import 'OLAViolateRecord.dart';

// class ProjectDetailsDto {
//   final int id;
//   final String projectName;
//   final DateTime createdDate;
//   final List<ProjectPEViewModelDto> projectPEs;

//   ProjectDetailsDto({
//     required this.id,
//     required this.projectName,
//     required this.createdDate,
//     required this.projectPEs,
//   });

//   factory ProjectDetailsDto.fromJson(Map<String, dynamic> json) {
//     return ProjectDetailsDto(
//       id: json['id'],
//       projectName: json['projectName'],
//       createdDate: DateTime.parse(json['createdDate']),
//       projectPEs: (json['projectPEs'] as List)
//           .map((e) => ProjectPEViewModelDto.fromJson(e))
//           .toList(),
//     );
//   }
// }

// class ProjectPEViewModelDto {
//   final int id;
//   final int plannedEventId;
//   final String? peNumber;
//   final String? customer;
//   final String? jobReference;
//   final String? serviceRequiredDate;
//   final String? currentTask;
//   final String? currentWg;

//   ProjectPEViewModelDto({
//     required this.id,
//     required this.plannedEventId,
//     this.peNumber,
//     this.customer,
//     this.jobReference,
//     this.serviceRequiredDate,
//     this.currentTask,
//     this.currentWg,
//   });

//   factory ProjectPEViewModelDto.fromJson(Map<String, dynamic> json) {
//     return ProjectPEViewModelDto(
//       id: json['id'],
//       plannedEventId: json['plannedEventId'],
//       peNumber: json['peNumber'],
//       customer: json['customer'],
//       jobReference: json['jobReference'],
//       serviceRequiredDate: json['serviceRequiredDate'],
//       currentTask: json['currentTask'],
//       currentWg: json['currentWg'],
//     );
//   }
// }

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
  final PlannedEvent? plannedEvent; // Restored this
  final String? peNumber;
  final String? customer;
  final String? jobReference;
  final String? serviceRequiredDate;
  final String? currentTask;
  final String? currentWg;

  ProjectPEViewModelDto({
    required this.id,
    required this.plannedEventId,
    this.plannedEvent,
    this.peNumber,
    this.customer,
    this.jobReference,
    this.serviceRequiredDate,
    this.currentTask,
    this.currentWg,
  });

  factory ProjectPEViewModelDto.fromJson(Map<String, dynamic> json) {
    return ProjectPEViewModelDto(
      id: json['id'],
      plannedEventId: json['plannedEventId'],
      plannedEvent: json['plannedEvent'] != null
          ? PlannedEvent.fromJson(json['plannedEvent'])
          : null,
      peNumber: json['peNumber'],
      customer: json['customer'],
      jobReference: json['jobReference'],
      serviceRequiredDate: json['serviceRequiredDate'],
      currentTask: json['currentTask'],
      currentWg: json['currentWg'],
    );
  }
}

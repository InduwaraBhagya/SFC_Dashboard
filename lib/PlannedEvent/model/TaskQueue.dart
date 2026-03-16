class TaskQueueItem {
  final PETask task;
  final double priorityScore;
  final int daysUntilDue;
  final DateTime? effectiveDeadline;
  final int olaInDays;
  final double olaPercentRemaining;
  final DateTime? urgentMarkedDate;

  TaskQueueItem({
    required this.task,
    required this.priorityScore,
    required this.daysUntilDue,
    this.effectiveDeadline,
    required this.olaInDays,
    required this.olaPercentRemaining,
    this.urgentMarkedDate,
  });

  factory TaskQueueItem.fromJson(Map<String, dynamic> json) {
    return TaskQueueItem(
      task: PETask.fromJson(json['task'] as Map<String, dynamic>),
      priorityScore: (json['priorityScore'] as num).toDouble(),
      daysUntilDue: json['daysUntilDue'] as int,
      effectiveDeadline: json['effectiveDeadline'] != null ? DateTime.parse(json['effectiveDeadline'] as String) : null,
      olaInDays: json['olaInDays'] as int,
      olaPercentRemaining: (json['olaPercentRemaining'] as num).toDouble(),
      urgentMarkedDate: json['urgentMarkedDate'] != null ? DateTime.parse(json['urgentMarkedDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task.toJson(),
      'priorityScore': priorityScore,
      'daysUntilDue': daysUntilDue,
      'effectiveDeadline': effectiveDeadline?.toIso8601String(),
      'olaInDays': olaInDays,
      'olaPercentRemaining': olaPercentRemaining,
      'urgentMarkedDate': urgentMarkedDate?.toIso8601String(),
    };
  }

  bool get isOverdue => daysUntilDue < 0;

  String get dueStatus {
    if (isOverdue) {
      return 'Overdue by ${daysUntilDue.abs()} days';
    } else if (daysUntilDue == 0) {
      return 'Due today';
    } else if (daysUntilDue == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $daysUntilDue days';
    }
  }

  String get olaStatus {
    if (task.isOlaViolate) {
      return 'OLA Violated';
    } else if (olaPercentRemaining <= 10) {
      return 'Critical (≤10% OLA left)';
    } else if (olaPercentRemaining <= 30) {
      return 'Warning (≤30% OLA left)';
    } else {
      return '${olaPercentRemaining.toStringAsFixed(0)}% of OLA remains';
    }
  }

  String get priorityLevel {
    if (task.isUrgent) {
      if (task.priority?.contains('Opening Ceremony') == true) {
        return 'URGENT P1';
      } else if (task.priority?.contains('Critical Customer') == true) {
        return 'URGENT P2';
      } else {
        return 'URGENT';
      }
    } else if (task.isOlaViolate) {
      return 'OLA VIOLATION';
    } else if (daysUntilDue >= 0 && daysUntilDue <= (2 < (olaInDays * 0.3).ceil() ? 2 : (olaInDays * 0.3).ceil())) {
      return 'APPROACHING DEADLINE';
    } else {
      return 'REGULAR';
    }
  }

  String get urgencyLevel {
    if (task.isUrgent == true) {
      return 'Urgent';
    } else if (isOverdue) {
      return 'Overdue';
    } else if (daysUntilDue <= 1) {
      return 'Due Soon';
    } else {
      return 'Normal';
    }
  }
}

class PETask {
  final int id;
  final String? priority;
  final bool isUrgent;
  final bool isOlaViolate;
  final DateTime? urgentMarkedDate;
  final PlannedEvent? plannedEvent;
  final String? taskStatus;

  PETask({
    required this.id,
    this.priority,
    required this.isUrgent,
    required this.isOlaViolate,
    this.urgentMarkedDate,
    this.plannedEvent,
    this.taskStatus,
  });

  factory PETask.fromJson(Map<String, dynamic> json) {
    return PETask(
      id: json['id'] as int,
      priority: json['priority'] as String?,
      isUrgent: json['isUrgent'] as bool? ?? false, // Default to false if null
      isOlaViolate: json['isOlaViolate'] as bool? ?? false, // Default to false if null
      urgentMarkedDate: json['urgentMarkedDate'] != null ? DateTime.parse(json['urgentMarkedDate'] as String) : null,
      plannedEvent: json['plannedEvent'] != null ? PlannedEvent.fromJson(json['plannedEvent'] as Map<String, dynamic>) : null,
      taskStatus: json['taskStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priority': priority,
      'isUrgent': isUrgent,
      'isOlaViolate': isOlaViolate,
      'urgentMarkedDate': urgentMarkedDate?.toIso8601String(),
      'plannedEvent': plannedEvent?.toJson(),
      'taskStatus': taskStatus,
    };
  }
}

class PlannedEvent {
  final int id;
  final String? peNumber;

  PlannedEvent({
    required this.id,
    this.peNumber,
  });

  factory PlannedEvent.fromJson(Map<String, dynamic> json) {
    return PlannedEvent(
      id: json['id'] as int,
      peNumber: json['peNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peNumber': peNumber,
    };
  }
}
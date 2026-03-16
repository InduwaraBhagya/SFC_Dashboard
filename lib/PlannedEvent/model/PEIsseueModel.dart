class PEIssue {
  final int? id;
  final int? plannedEventId;
  final int? peTaskId;
  final int? receiverId;
  final int? senderId;
  final String? issueText;
  final String? attachmentPath;
  final DateTime? createdAt;
  final bool? isRead;
  final bool? isReply;
  final int? originalIssueId;
  final bool? isResolved;
  final bool? isResolutionRequest;
  final bool? isHiddenFromInbox;
  final bool? isReminder;

  PEIssue({
    this.id,
    this.plannedEventId,
    this.peTaskId,
    this.receiverId,
    this.senderId,
    this.issueText,
    this.attachmentPath,
    this.createdAt,
    this.isRead,
    this.isReply,
    this.originalIssueId,
    this.isResolved,
    this.isResolutionRequest,
    this.isHiddenFromInbox,
    this.isReminder,
  });

  factory PEIssue.fromJson(Map<String, dynamic> json) {
    return PEIssue(
      id: json['id'] as int?,
      plannedEventId: json['plannedEventId'] as int?,
      peTaskId: json['peTaskId'] as int?,
      receiverId: json['receiverId'] as int?,
      senderId: json['senderId'] as int?,
      issueText: json['issueText'] as String?,
      attachmentPath: json['attachmentPath'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      isRead: json['isRead'] as bool?,
      isReply: json['isReply'] as bool?,
      originalIssueId: json['originalIssueId'] as int?,
      isResolved: json['isResolved'] as bool?,
      isResolutionRequest: json['isResolutionRequest'] as bool?,
      isHiddenFromInbox: json['isHiddenFromInbox'] as bool?,
      isReminder: json['isReminder'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plannedEventId': plannedEventId,
      'peTaskId': peTaskId,
      'receiverId': receiverId,
      'senderId': senderId,
      'issueText': issueText,
      'attachmentPath': attachmentPath,
      'createdAt': createdAt?.toIso8601String(),
      'isRead': isRead,
      'isReply': isReply,
      'originalIssueId': originalIssueId,
      'isResolved': isResolved,
      'isResolutionRequest': isResolutionRequest,
      'isHiddenFromInbox': isHiddenFromInbox,
      'isReminder': isReminder,
    };
  }
}

class PEIssueResolution {
  final int? id;
  final int? issueId;
  final String? resolutionDetails;
  final DateTime? resolutionDate;
  final bool? isConfirmed;
  final DateTime? confirmationRequestedDate;
  final DateTime? confirmedDate;
  final int? plannedEventId;

  PEIssueResolution({
    this.id,
    this.issueId,
    this.resolutionDetails,
    this.resolutionDate,
    this.isConfirmed,
    this.confirmationRequestedDate,
    this.confirmedDate,
    this.plannedEventId,
  });

  factory PEIssueResolution.fromJson(Map<String, dynamic> json) {
    return PEIssueResolution(
      id: json['id'] as int?,
      issueId: json['issueId'] as int?,
      resolutionDetails: json['resolutionDetails'] as String?,
      resolutionDate: json['resolutionDate'] != null ? DateTime.parse(json['resolutionDate'] as String) : null,
      isConfirmed: json['isConfirmed'] as bool?,
      confirmationRequestedDate: json['confirmationRequestedDate'] != null
          ? DateTime.parse(json['confirmationRequestedDate'] as String)
          : null,
      confirmedDate: json['confirmedDate'] != null ? DateTime.parse(json['confirmedDate'] as String) : null,
      plannedEventId: json['plannedEventId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issueId': issueId,
      'resolutionDetails': resolutionDetails,
      'resolutionDate': resolutionDate?.toIso8601String(),
      'isConfirmed': isConfirmed,
      'confirmationRequestedDate': confirmationRequestedDate?.toIso8601String(),
      'confirmedDate': confirmedDate?.toIso8601String(),
      'plannedEventId': plannedEventId,
    };
  }
}
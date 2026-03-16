class OLAViolateRecord {
  final int? id;
  final String? peNumber;
  final String? customer;
  final String? cusType;
  final String? accountManager;
  final String? sectionHandledBy;
  final String? contractorName;
  final String? peActivity;
  final String? peNature;
  final String? peTitle;
  final String? peObjective;
  final String? peArea;
  final String? province;
  final String? region;
  final String? rtom;
  final String? rtomDescription;
  final String? locationAAddress;
  final String? locationBAddress;
  final String? serviceType;
  final String? serviceCategory;
  final String? taskWg;
  final String? soNumber;
  final String? soId;
  final String? requestReferenceNo;
  final String? woActualStartDate;
  final String? soCreateDate;
  final String? orderType;
  final int? taskSeq;
  final String? woId;
  final String? woStatus;
  final String? taskName; // Added from HoldRecordScreen
  final String? peStatus; // Added from UrgentRecordScreen
  final PlannedEvent? plannedEvent;
  final PETask? peTask;
  final Map<String, dynamic>? additionalData;

  OLAViolateRecord({
    this.id,
    this.peNumber,
    this.customer,
    this.cusType,
    this.accountManager,
    this.sectionHandledBy,
    this.contractorName,
    this.peActivity,
    this.peNature,
    this.peTitle,
    this.peObjective,
    this.peArea,
    this.province,
    this.region,
    this.rtom,
    this.rtomDescription,
    this.locationAAddress,
    this.locationBAddress,
    this.serviceType,
    this.serviceCategory,
    this.taskWg,
    this.soNumber,
    this.soId,
    this.requestReferenceNo,
    this.woActualStartDate,
    this.soCreateDate,
    this.orderType,
    this.taskSeq,
    this.woId,
    this.woStatus,
    this.taskName,
    this.peStatus,
    this.plannedEvent,
    this.peTask,
    this.additionalData,
  });

  factory OLAViolateRecord.fromJson(Map<String, dynamic> json) {
    return OLAViolateRecord(
      id: json['id'] as int?,
      peNumber: json['peNumber'] as String?,
      customer: json['customer'] as String?,
      cusType: json['cusType'] as String?,
      accountManager: json['accountManager'] as String?,
      sectionHandledBy: json['sectionHandledBy'] as String?,
      contractorName: json['contractorName'] as String?,
      peActivity: json['peActivity'] as String?,
      peNature: json['peNature'] as String?,
      peTitle: json['peTitle'] as String?,
      peObjective: json['peObjective'] as String?,
      peArea: json['peArea'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      rtom: json['rtom'] as String?,
      rtomDescription: json['rtomDescription'] as String?,
      locationAAddress: json['locationAAddress'] as String?,
      locationBAddress: json['locationBAddress'] as String?,
      serviceType: json['serviceType'] as String?,
      serviceCategory: json['serviceCategory'] as String?,
      taskWg: json['taskWg'] as String?,
      soNumber: json['soNumber'] as String?,
      soId: json['soId'] as String?,
      requestReferenceNo: json['requestReferenceNo'] as String?,
      woActualStartDate: json['woActualStartDate'] as String?,
      soCreateDate: json['soCreateDate'] as String?,
      orderType: json['orderType'] as String?,
      taskSeq: json['taskSeq'] as int?,
      woId: json['woId'] as String?,
      woStatus: json['woStatus'] as String?,
      taskName: json['taskName'] as String?,
      peStatus: json['peStatus'] as String?,
      plannedEvent: json['plannedEvent'] != null
          ? PlannedEvent.fromJson(json['plannedEvent'] as Map<String, dynamic>)
          : null,
      peTask: json['peTask'] != null
          ? PETask.fromJson(json['peTask'] as Map<String, dynamic>)
          : null,
      additionalData: json['additionalData'] != null
          ? Map<String, dynamic>.from(json['additionalData'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peNumber': peNumber,
      'customer': customer,
      'cusType': cusType,
      'accountManager': accountManager,
      'sectionHandledBy': sectionHandledBy,
      'contractorName': contractorName,
      'peActivity': peActivity,
      'peNature': peNature,
      'peTitle': peTitle,
      'peObjective': peObjective,
      'peArea': peArea,
      'province': province,
      'region': region,
      'rtom': rtom,
      'rtomDescription': rtomDescription,
      'locationAAddress': locationAAddress,
      'locationBAddress': locationBAddress,
      'serviceType': serviceType,
      'serviceCategory': serviceCategory,
      'taskWg': taskWg,
      'soNumber': soNumber,
      'soId': soId,
      'requestReferenceNo': requestReferenceNo,
      'woActualStartDate': woActualStartDate,
      'soCreateDate': soCreateDate,
      'orderType': orderType,
      'taskSeq': taskSeq,
      'woId': woId,
      'woStatus': woStatus,
      'taskName': taskName,
      'peStatus': peStatus,
      'plannedEvent': plannedEvent?.toJson(),
      'peTask': peTask?.toJson(),
      'additionalData': additionalData,
    };
  }
}

class PlannedEvent {
  final String? serviceSpeed;
  final String? serviceRequiredDate;
  final String? ntuType;
  final String? accessMedium;
  final String? pendingTaskName;
  final String? pendingWg;
  final String? cctId;
  final String? lea;
  final String? crmOrder;
  final String? woComments;
  final String? peWoComments;
  final String? fiberPeNo;
  final String? fiberSoId;
  final String? productSoId;
  final String? fiberPeTaskName;
  final String? fiberPeTaskWg;
  final String? peCreatedDate;
  final bool? isHold;

  PlannedEvent({
    this.serviceSpeed,
    this.serviceRequiredDate,
    this.ntuType,
    this.accessMedium,
    this.pendingTaskName,
    this.pendingWg,
    this.cctId,
    this.lea,
    this.crmOrder,
    this.woComments,
    this.peWoComments,
    this.fiberPeNo,
    this.fiberSoId,
    this.productSoId,
    this.fiberPeTaskName,
    this.fiberPeTaskWg,
    this.peCreatedDate,
    this.isHold,
  });

  factory PlannedEvent.fromJson(Map<String, dynamic> json) {
    return PlannedEvent(
      serviceSpeed: json['serviceSpeed'] as String?,
      serviceRequiredDate: json['serviceRequiredDate'] as String?,
      ntuType: json['ntuType'] as String?,
      accessMedium: json['accessMedium'] as String?,
      pendingTaskName: json['pendingTaskName'] as String?,
      pendingWg: json['pendingWg'] as String?,
      cctId: json['cctId'] as String?,
      lea: json['lea'] as String?,
      crmOrder: json['crmOrder'] as String?,
      woComments: json['woComments'] as String?,
      peWoComments: json['peWoComments'] as String?,
      fiberPeNo: json['fiberPeNo'] as String?,
      fiberSoId: json['fiberSoId'] as String?,
      productSoId: json['productSoId'] as String?,
      fiberPeTaskName: json['fiberPeTaskName'] as String?,
      fiberPeTaskWg: json['fiberPeTaskWg'] as String?,
      peCreatedDate: json['peCreatedDate'] as String?,
      isHold: json['isHold'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceSpeed': serviceSpeed,
      'serviceRequiredDate': serviceRequiredDate,
      'ntuType': ntuType,
      'accessMedium': accessMedium,
      'pendingTaskName': pendingTaskName,
      'pendingWg': pendingWg,
      'cctId': cctId,
      'lea': lea,
      'crmOrder': crmOrder,
      'woComments': woComments,
      'peWoComments': peWoComments,
      'fiberPeNo': fiberPeNo,
      'fiberSoId': fiberSoId,
      'productSoId': productSoId,
      'fiberPeTaskName': fiberPeTaskName,
      'fiberPeTaskWg': fiberPeTaskWg,
      'peCreatedDate': peCreatedDate,
      'isHold': isHold,
    };
  }
}

class PETask {
  final int? id;
  final String? task;
  final int? taskSeq;
  final String? taskWorkGroup;
  final String? ola;
  final String? taskStatus;
  final String? taskCreatedDate;
  final String? taskCompleteDate;
  final String? actualTaskCreatedDate;
  final String? aCtualTaskCompleteDate; // Matching case from OLAViolateRecordDetailsScreen
  final bool? isUrgent;
  final bool? urgentRequested;
  final String? priority;
  final String? estimatedTime;
  final bool? isOLAViolate;

  PETask({
    this.id,
    this.task,
    this.taskSeq,
    this.taskWorkGroup,
    this.ola,
    this.taskStatus,
    this.taskCreatedDate,
    this.taskCompleteDate,
    this.actualTaskCreatedDate,
    this.aCtualTaskCompleteDate,
    this.isUrgent,
    this.urgentRequested,
    this.priority,
    this.estimatedTime,
    this.isOLAViolate,
  });

  factory PETask.fromJson(Map<String, dynamic> json) {
    return PETask(
      id: json['id'] as int?,
      task: json['task'] as String?,
      taskSeq: json['taskSeq'] as int?,
      taskWorkGroup: json['taskWorkGroup'] as String?,
      ola: json['ola'] as String?,
      taskStatus: json['taskStatus'] as String?,
      taskCreatedDate: json['taskCreatedDate'] as String?,
      taskCompleteDate: json['taskCompleteDate'] as String?,
      actualTaskCreatedDate: json['actualTaskCreatedDate'] as String?,
      aCtualTaskCompleteDate: json['aCtualTaskCompleteDate'] as String?,
      isUrgent: json['isUrgent'] as bool?,
      urgentRequested: json['urgentRequested'] as bool?,
      priority: json['priority'] as String?,
      estimatedTime: json['estimatedTime'] as String?,
      isOLAViolate: json['isOLAViolate'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'taskSeq': taskSeq,
      'taskWorkGroup': taskWorkGroup,
      'ola': ola,
      'taskStatus': taskStatus,
      'taskCreatedDate': taskCreatedDate,
      'taskCompleteDate': taskCompleteDate,
      'actualTaskCreatedDate': actualTaskCreatedDate,
      'aCtualTaskCompleteDate': aCtualTaskCompleteDate,
      'isUrgent': isUrgent,
      'urgentRequested': urgentRequested,
      'priority': priority,
      'estimatedTime': estimatedTime,
      'isOLAViolate': isOLAViolate,
    };
  }
}
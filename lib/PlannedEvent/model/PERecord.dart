class PERecord {
  final int? id;
  final String? province;
  final String? region;
  final String? rtom;
  final String? rtomDescription;
  final String? jobReference;
  final String? contractorName;
  final String? peNumber;
  final String? peActivity;
  final String? peNature;
  final String? peTitle;
  final String? peObjective;
  final String? peArea;
  final String? soNumber;
  final int? taskSeq;
  final String? taskName;
  final String? taskWg;
  final String? woActualStartDate;
  final String? requestReferenceNo;
  final String? soId;
  final String? region1;
  final String? province1;
  final String? rtom1;
  final String? lea;
  final String? cctId;
  final String? serviceCategory;
  final String? serviceType;
  final String? soCreateDate;
  final String? orderType;
  final String? crmOrder;
  final String? woId;
  final String? pendingTaskName;
  final String? pendingWg;
  final String? woStatus;
  final String? woStartDate;
  final String? serviceSpeed;
  final String? serviceRequiredDate;
  final String? fiberPeNo;
  final String? fiberSoId;
  final String? productSoId;
  final String? fiberPeTaskName;
  final String? fiberPeTaskWg;
  final String? peWoComments;
  final String? customer;
  final String? cusType;
  final String? accountManager;
  final String? sectionHandledBy;
  final String? locationAAddress;
  final String? locationBAddress;
  final String? ntuType;
  final String? accessMedium;
  final String? accessMediumAEnd;
  final String? accessMediumBEnd;
  final String? woComments;
  final String? peStatus;
  final String? priority;
  final String? peCreatedDate;
  final bool? isHold;
  final String? createdDateFromPE;
  final String? urgentRequestedByName;
  final int? urgentRequestedById;
  final int? systemUserId;
  final int? workGroupId;

  PERecord({
    this.id,
    this.province,
    this.region,
    this.rtom,
    this.rtomDescription,
    this.jobReference,
    this.contractorName,
    this.peNumber,
    this.peActivity,
    this.peNature,
    this.peTitle,
    this.peObjective,
    this.peArea,
    this.soNumber,
    this.taskSeq,
    this.taskName,
    this.taskWg,
    this.woActualStartDate,
    this.requestReferenceNo,
    this.soId,
    this.region1,
    this.province1,
    this.rtom1,
    this.lea,
    this.cctId,
    this.serviceCategory,
    this.serviceType,
    this.soCreateDate,
    this.orderType,
    this.crmOrder,
    this.woId,
    this.pendingTaskName,
    this.pendingWg,
    this.woStatus,
    this.woStartDate,
    this.serviceSpeed,
    this.serviceRequiredDate,
    this.fiberPeNo,
    this.fiberSoId,
    this.productSoId,
    this.fiberPeTaskName,
    this.fiberPeTaskWg,
    this.peWoComments,
    this.customer,
    this.cusType,
    this.accountManager,
    this.sectionHandledBy,
    this.locationAAddress,
    this.locationBAddress,
    this.ntuType,
    this.accessMedium,
    this.accessMediumAEnd,
    this.accessMediumBEnd,
    this.woComments,
    this.peStatus,
    this.priority,
    this.peCreatedDate,
    this.isHold,
    this.createdDateFromPE,
    this.urgentRequestedByName,
    this.urgentRequestedById,
    this.systemUserId,
    this.workGroupId,
  });

  factory PERecord.fromJson(Map<String, dynamic> json) {
    return PERecord(
      id: json['id'] as int?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      rtom: json['rtom'] as String?,
      rtomDescription: json['rtomDescription'] as String?,
      jobReference: json['jobReference'] as String?,
      contractorName: json['contractorName'] as String?,
      peNumber: json['peNumber'] as String?,
      peActivity: json['peActivity'] as String?,
      peNature: json['peNature'] as String?,
      peTitle: json['peTitle'] as String?,
      peObjective: json['peObjective'] as String?,
      peArea: json['peArea'] as String?,
      soNumber: json['soNumber'] as String?,
      taskSeq: json['taskSeq'] as int?,
      taskName: json['taskName'] as String?,
      taskWg: json['taskWg'] as String?,
      woActualStartDate: json['woActualStartDate'] as String?,
      requestReferenceNo: json['requestReferenceNo'] as String?,
      soId: json['soId'] as String?,
      region1: json['region1'] as String?,
      province1: json['province1'] as String?,
      rtom1: json['rtom1'] as String?,
      lea: json['lea'] as String?,
      cctId: json['cctId'] as String?,
      serviceCategory: json['serviceCategory'] as String?,
      serviceType: json['serviceType'] as String?,
      soCreateDate: json['soCreateDate'] as String?,
      orderType: json['orderType'] as String?,
      crmOrder: json['crmOrder'] as String?,
      woId: json['woId'] as String?,
      pendingTaskName: json['pendingTaskName'] as String?,
      pendingWg: json['pendingWg'] as String?,
      woStatus: json['woStatus'] as String?,
      woStartDate: json['woStartDate'] as String?,
      serviceSpeed: json['serviceSpeed'] as String?,
      serviceRequiredDate: json['serviceRequiredDate'] as String?,
      fiberPeNo: json['fiberPeNo'] as String?,
      fiberSoId: json['fiberSoId'] as String?,
      productSoId: json['productSoId'] as String?,
      fiberPeTaskName: json['fiberPeTaskName'] as String?,
      fiberPeTaskWg: json['fiberPeTaskWg'] as String?,
      peWoComments: json['peWoComments'] as String?,
      customer: json['customer'] as String?,
      cusType: json['cusType'] as String?,
      accountManager: json['accountManager'] as String?,
      sectionHandledBy: json['sectionHandledBy'] as String?,
      locationAAddress: json['locationAAddress'] as String?,
      locationBAddress: json['locationBAddress'] as String?,
      ntuType: json['ntuType'] as String?,
      accessMedium: json['accessMedium'] as String?,
      accessMediumAEnd: json['accessMediumAEnd'] as String?,
      accessMediumBEnd: json['accessMediumBEnd'] as String?,
      woComments: json['woComments'] as String?,
      peStatus: json['peStatus'] as String?,
      priority: json['priority'] as String?,
      peCreatedDate: json['peCreatedDate'] as String?,
      isHold: json['isHold'] as bool?,
      createdDateFromPE: json['createdDateFromPE'] as String?,
      urgentRequestedByName: json['urgentRequestedByName'] as String?,
      urgentRequestedById: json['urgentRequestedById'] as int?,
      systemUserId: json['systemUserId'] as int?,
      workGroupId: json['workGroupId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province,
      'region': region,
      'rtom': rtom,
      'rtomDescription': rtomDescription,
      'jobReference': jobReference,
      'contractorName': contractorName,
      'peNumber': peNumber,
      'peActivity': peActivity,
      'peNature': peNature,
      'peTitle': peTitle,
      'peObjective': peObjective,
      'peArea': peArea,
      'soNumber': soNumber,
      'taskSeq': taskSeq,
      'taskName': taskName,
      'taskWg': taskWg,
      'woActualStartDate': woActualStartDate,
      'requestReferenceNo': requestReferenceNo,
      'soId': soId,
      'region1': region1,
      'province1': province1,
      'rtom1': rtom1,
      'lea': lea,
      'cctId': cctId,
      'serviceCategory': serviceCategory,
      'serviceType': serviceType,
      'soCreateDate': soCreateDate,
      'orderType': orderType,
      'crmOrder': crmOrder,
      'woId': woId,
      'pendingTaskName': pendingTaskName,
      'pendingWg': pendingWg,
      'woStatus': woStatus,
      'woStartDate': woStartDate,
      'serviceSpeed': serviceSpeed,
      'serviceRequiredDate': serviceRequiredDate,
      'fiberPeNo': fiberPeNo,
      'fiberSoId': fiberSoId,
      'productSoId': productSoId,
      'fiberPeTaskName': fiberPeTaskName,
      'fiberPeTaskWg': fiberPeTaskWg,
      'peWoComments': peWoComments,
      'customer': customer,
      'cusType': cusType,
      'accountManager': accountManager,
      'sectionHandledBy': sectionHandledBy,
      'locationAAddress': locationAAddress,
      'locationBAddress': locationBAddress,
      'ntuType': ntuType,
      'accessMedium': accessMedium,
      'accessMediumAEnd': accessMediumAEnd,
      'accessMediumBEnd': accessMediumBEnd,
      'woComments': woComments,
      'peStatus': peStatus,
      'priority': priority,
      'peCreatedDate': peCreatedDate,
      'isHold': isHold,
      'createdDateFromPE': createdDateFromPE,
      'urgentRequestedByName': urgentRequestedByName,
      'urgentRequestedById': urgentRequestedById,
      'systemUserId': systemUserId,
      'workGroupId': workGroupId,
    };
  }
}

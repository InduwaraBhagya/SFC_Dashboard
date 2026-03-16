class RegularRecord {
  final int? id;
  final String? peNumber;
  final String? province;
  final String? region;
  final String? rtom;
  final String? rtomDescription;
  final String? jobReference;
  final String? contractorName;
  final String? peActivity;
  final String? peNature;
  final String? peTitle;
  final String? peObjective;
  final String? peArea;
  final int? taskSeq;
  final String? taskName;
  final String? taskWg;
  final String? pendingTaskName;
  final String? pendingWg;
  final String? woActualStartDate;
  final String? woStartDate;
  final String? woStatus;
  final String? woId;
  final String? requestReferenceNo;
  final String? serviceCategory;
  final String? serviceType;
  final String? serviceSpeed;
  final String? serviceRequiredDate;
  final String? soNumber;
  final String? soId;
  final String? soCreateDate;
  final String? orderType;
  final String? crmOrder;
  final String? fiberPeNo;
  final String? fiberSoId;
  final String? productSoId;
  final String? fiberPeTaskName;
  final String? fiberPeTaskWg;
  final String? region1;
  final String? province1;
  final String? rtom1;
  final String? lea;
  final String? cctId;

  RegularRecord({
    this.id,
    this.peNumber,
    this.province,
    this.region,
    this.rtom,
    this.rtomDescription,
    this.jobReference,
    this.contractorName,
    this.peActivity,
    this.peNature,
    this.peTitle,
    this.peObjective,
    this.peArea,
    this.taskSeq,
    this.taskName,
    this.taskWg,
    this.pendingTaskName,
    this.pendingWg,
    this.woActualStartDate,
    this.woStartDate,
    this.woStatus,
    this.woId,
    this.requestReferenceNo,
    this.serviceCategory,
    this.serviceType,
    this.serviceSpeed,
    this.serviceRequiredDate,
    this.soNumber,
    this.soId,
    this.soCreateDate,
    this.orderType,
    this.crmOrder,
    this.fiberPeNo,
    this.fiberSoId,
    this.productSoId,
    this.fiberPeTaskName,
    this.fiberPeTaskWg,
    this.region1,
    this.province1,
    this.rtom1,
    this.lea,
    this.cctId,
  });

  factory RegularRecord.fromJson(Map<String, dynamic> json) {
    return RegularRecord(
      id: json['id'] as int?,
      peNumber: json['peNumber'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      rtom: json['rtom'] as String?,
      rtomDescription: json['rtomDescription'] as String?,
      jobReference: json['jobReference'] as String?,
      contractorName: json['contractorName'] as String?,
      peActivity: json['peActivity'] as String?,
      peNature: json['peNature'] as String?,
      peTitle: json['peTitle'] as String?,
      peObjective: json['peObjective'] as String?,
      peArea: json['peArea'] as String?,
      taskSeq: json['taskSeq'] as int?,
      taskName: json['taskName'] as String?,
      taskWg: json['taskWg'] as String?,
      pendingTaskName: json['pendingTaskName'] as String?,
      pendingWg: json['pendingWg'] as String?,
      woActualStartDate: json['woActualStartDate'] as String?,
      woStartDate: json['woStartDate'] as String?,
      woStatus: json['woStatus'] as String?,
      woId: json['woId'] as String?,
      requestReferenceNo: json['requestReferenceNo'] as String?,
      serviceCategory: json['serviceCategory'] as String?,
      serviceType: json['serviceType'] as String?,
      serviceSpeed: json['serviceSpeed'] as String?,
      serviceRequiredDate: json['serviceRequiredDate'] as String?,
      soNumber: json['soNumber'] as String?,
      soId: json['soId'] as String?,
      soCreateDate: json['soCreateDate'] as String?,
      orderType: json['orderType'] as String?,
      crmOrder: json['crmOrder'] as String?,
      fiberPeNo: json['fiberPeNo'] as String?,
      fiberSoId: json['fiberSoId'] as String?,
      productSoId: json['productSoId'] as String?,
      fiberPeTaskName: json['fiberPeTaskName'] as String?,
      fiberPeTaskWg: json['fiberPeTaskWg'] as String?,
      region1: json['region1'] as String?,
      province1: json['province1'] as String?,
      rtom1: json['rtom1'] as String?,
      lea: json['lea'] as String?,
      cctId: json['cctId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peNumber': peNumber,
      'province': province,
      'region': region,
      'rtom': rtom,
      'rtomDescription': rtomDescription,
      'jobReference': jobReference,
      'contractorName': contractorName,
      'peActivity': peActivity,
      'peNature': peNature,
      'peTitle': peTitle,
      'peObjective': peObjective,
      'peArea': peArea,
      'taskSeq': taskSeq,
      'taskName': taskName,
      'taskWg': taskWg,
      'pendingTaskName': pendingTaskName,
      'pendingWg': pendingWg,
      'woActualStartDate': woActualStartDate,
      'woStartDate': woStartDate,
      'woStatus': woStatus,
      'woId': woId,
      'requestReferenceNo': requestReferenceNo,
      'serviceCategory': serviceCategory,
      'serviceType': serviceType,
      'serviceSpeed': serviceSpeed,
      'serviceRequiredDate': serviceRequiredDate,
      'soNumber': soNumber,
      'soId': soId,
      'soCreateDate': soCreateDate,
      'orderType': orderType,
      'crmOrder': crmOrder,
      'fiberPeNo': fiberPeNo,
      'fiberSoId': fiberSoId,
      'productSoId': productSoId,
      'fiberPeTaskName': fiberPeTaskName,
      'fiberPeTaskWg': fiberPeTaskWg,
      'region1': region1,
      'province1': province1,
      'rtom1': rtom1,
      'lea': lea,
      'cctId': cctId,
    };
  }
}
class PERecord {
  final int? id;
  final String? province;
  final String? region;
  final String? rtom;
  final String? rtoM_DESCRIPTION;
  final String? joB_REFERENCE;
  final String? contractoR_NAME;
  final String? pENUMBER;
  final String? pE_ACTIVITY;
  final String? pE_NATURE;
  final String? pETITLE;
  final String? pE_OBJECTIVE;
  final String? pE_AREA;
  final String? sONUMBER;
  final int? tasK_SEQ;
  final String? tasK_NAME;
  final String? tasK_WG;
  final String? wO_ACTUAL_START_DATE;
  final String? requesT_REFERENCE_NO;
  final String? sO_ID;
  final String? regioN_1;
  final String? provincE_1;
  final String? rtoM_1;
  final String? lea;
  final String? ccT_ID;
  final String? servicE_CATEGORY;
  final String? servicE_TYPE;
  final String? sO_CREATE_DATE;
  final String? ordeR_TYPE;
  final String? crM_ORDER;
  final String? wO_ID;
  final String? pendinG_TASK_NAME;
  final String? pendinG_WG;
  final String? wO_STATUS;
  final String? wO_START_DATE;
  final String? servicE_SPEED;
  final String? servicE_REQUIRED_DATE;
  final String? fibeR_PE_NO;
  final String? fibeR_SO_ID;
  final String? producT_SO_ID;
  final String? fibeR_PE_TASK_NAME;
  final String? fibeR_PE_TASK_WG;
  final String? pE_WO_COMMENTS;
  final String? cUSTOMER;
  final String? cuS_TYPE;
  final String? accounT_MANAGER;
  final String? sectioN_HANDLED_BY;
  final String? locatioN_A_ADDRESS;
  final String? locatioN_B_ADDRESS;
  final String? nTUTYPE;
  final String? accesS_MEDIUM;
  final String? accesS_MEDIUM_A_END;
  final String? accesS_MEDIUM_B_END;
  final String? wO_COMMENTS;

  PERecord({
    this.id,
    this.province,
    this.region,
    this.rtom,
    this.rtoM_DESCRIPTION,
    this.joB_REFERENCE,
    this.contractoR_NAME,
    this.pENUMBER,
    this.pE_ACTIVITY,
    this.pE_NATURE,
    this.pETITLE,
    this.pE_OBJECTIVE,
    this.pE_AREA,
    this.sONUMBER,
    this.tasK_SEQ,
    this.tasK_NAME,
    this.tasK_WG,
    this.wO_ACTUAL_START_DATE,
    this.requesT_REFERENCE_NO,
    this.sO_ID,
    this.regioN_1,
    this.provincE_1,
    this.rtoM_1,
    this.lea,
    this.ccT_ID,
    this.servicE_CATEGORY,
    this.servicE_TYPE,
    this.sO_CREATE_DATE,
    this.ordeR_TYPE,
    this.crM_ORDER,
    this.wO_ID,
    this.pendinG_TASK_NAME,
    this.pendinG_WG,
    this.wO_STATUS,
    this.wO_START_DATE,
    this.servicE_SPEED,
    this.servicE_REQUIRED_DATE,
    this.fibeR_PE_NO,
    this.fibeR_SO_ID,
    this.producT_SO_ID,
    this.fibeR_PE_TASK_NAME,
    this.fibeR_PE_TASK_WG,
    this.pE_WO_COMMENTS,
    this.cUSTOMER,
    this.cuS_TYPE,
    this.accounT_MANAGER,
    this.sectioN_HANDLED_BY,
    this.locatioN_A_ADDRESS,
    this.locatioN_B_ADDRESS,
    this.nTUTYPE,
    this.accesS_MEDIUM,
    this.accesS_MEDIUM_A_END,
    this.accesS_MEDIUM_B_END,
    this.wO_COMMENTS,
  });

  factory PERecord.fromJson(Map<String, dynamic> json) {
    return PERecord(
      id: json['id'] as int?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      rtom: json['rtom'] as String?,
      rtoM_DESCRIPTION: json['rtoM_DESCRIPTION'] as String?,
      joB_REFERENCE: json['joB_REFERENCE'] as String?,
      contractoR_NAME: json['contractoR_NAME'] as String?,
      pENUMBER: json['pE_NUMBER'] as String?,
      pE_ACTIVITY: json['pE_ACTIVITY'] as String?,
      pE_NATURE: json['pE_NATURE'] as String?,
      pETITLE: json['pE_TITLE'] as String?,
      pE_OBJECTIVE: json['pE_OBJECTIVE'] as String?,
      pE_AREA: json['pE_AREA'] as String?,
      sONUMBER: json['sO_NUMBER'] as String?,
      tasK_SEQ: json['tasK_SEQ'] as int?,
      tasK_NAME: json['tasK_NAME'] as String?,
      tasK_WG: json['tasK_WG'] as String?,
      wO_ACTUAL_START_DATE: json['wO_ACTUAL_START_DATE'] as String?,
      requesT_REFERENCE_NO: json['requesT_REFERENCE_NO'] as String?,
      sO_ID: json['sO_ID'] as String?,
      regioN_1: json['regioN_1'] as String?,
      provincE_1: json['provincE_1'] as String?,
      rtoM_1: json['rtoM_1'] as String?,
      lea: json['lea'] as String?,
      ccT_ID: json['ccT_ID'] as String?,
      servicE_CATEGORY: json['servicE_CATEGORY'] as String?,
      servicE_TYPE: json['servicE_TYPE'] as String?,
      sO_CREATE_DATE: json['sO_CREATE_DATE'] as String?,
      ordeR_TYPE: json['ordeR_TYPE'] as String?,
      crM_ORDER: json['crM_ORDER'] as String?,
      wO_ID: json['wO_ID'] as String?,
      pendinG_TASK_NAME: json['pendinG_TASK_NAME'] as String?,
      pendinG_WG: json['pendinG_WG'] as String?,
      wO_STATUS: json['wO_STATUS'] as String?,
      wO_START_DATE: json['wO_START_DATE'] as String?,
      servicE_SPEED: json['servicE_SPEED'] as String?,
      servicE_REQUIRED_DATE: json['servicE_REQUIRED_DATE'] as String?,
      fibeR_PE_NO: json['fibeR_PE_NO'] as String?,
      fibeR_SO_ID: json['fibeR_SO_ID'] as String?,
      producT_SO_ID: json['producT_SO_ID'] as String?,
      fibeR_PE_TASK_NAME: json['fibeR_PE_TASK_NAME'] as String?,
      fibeR_PE_TASK_WG: json['fibeR_PE_TASK_WG'] as String?,
      pE_WO_COMMENTS: json['pE_WO_COMMENTS'] as String?,
      cUSTOMER: json['customer'] as String?,
      cuS_TYPE: json['cuS_TYPE'] as String?,
      accounT_MANAGER: json['accounT_MANAGER'] as String?,
      sectioN_HANDLED_BY: json['sectioN_HANDLED_BY'] as String?,
      locatioN_A_ADDRESS: json['locatioN_A_ADDRESS'] as String?,
      locatioN_B_ADDRESS: json['locatioN_B_ADDRESS'] as String?,
      nTUTYPE: json['nTUTYPE'] as String?,
      accesS_MEDIUM: json['accesS_MEDIUM'] as String?,
      accesS_MEDIUM_A_END: json['accesS_MEDIUM_A_END'] as String?,
      accesS_MEDIUM_B_END: json['accesS_MEDIUM_B_END'] as String?,
      wO_COMMENTS: json['wO_COMMENTS'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province,
      'region': region,
      'rtom': rtom,
      'rtoM_DESCRIPTION': rtoM_DESCRIPTION,
      'joB_REFERENCE': joB_REFERENCE,
      'contractoR_NAME': contractoR_NAME,
      'pE_NUMBER': pENUMBER,
      'pE_ACTIVITY': pE_ACTIVITY,
      'pE_NATURE': pE_NATURE,
      'pE_TITLE': pETITLE,
      'pE_OBJECTIVE': pE_OBJECTIVE,
      'pE_AREA': pE_AREA,
      'sO_NUMBER': sONUMBER,
      'tasK_SEQ': tasK_SEQ,
      'tasK_NAME': tasK_NAME,
      'tasK_WG': tasK_WG,
      'wO_ACTUAL_START_DATE': wO_ACTUAL_START_DATE,
      'requesT_REFERENCE_NO': requesT_REFERENCE_NO,
      'sO_ID': sO_ID,
      'regioN_1': regioN_1,
      'provincE_1': provincE_1,
      'rtoM_1': rtoM_1,
      'lea': lea,
      'ccT_ID': ccT_ID,
      'servicE_CATEGORY': servicE_CATEGORY,
      'servicE_TYPE': servicE_TYPE,
      'sO_CREATE_DATE': sO_CREATE_DATE,
      'ordeR_TYPE': ordeR_TYPE,
      'crM_ORDER': crM_ORDER,
      'wO_ID': wO_ID,
      'pendinG_TASK_NAME': pendinG_TASK_NAME,
      'pendinG_WG': pendinG_WG,
      'wO_STATUS': wO_STATUS,
      'wO_START_DATE': wO_START_DATE,
      'servicE_SPEED': servicE_SPEED,
      'servicE_REQUIRED_DATE': servicE_REQUIRED_DATE,
      'fibeR_PE_NO': fibeR_PE_NO,
      'fibeR_SO_ID': fibeR_SO_ID,
      'producT_SO_ID': producT_SO_ID,
      'fibeR_PE_TASK_NAME': fibeR_PE_TASK_NAME,
      'fibeR_PE_TASK_WG': fibeR_PE_TASK_WG,
      'pE_WO_COMMENTS': pE_WO_COMMENTS,
      'customer': cUSTOMER,
      'cuS_TYPE': cuS_TYPE,
      'accounT_MANAGER': accounT_MANAGER,
      'sectioN_HANDLED_BY': sectioN_HANDLED_BY,
      'locatioN_A_ADDRESS': locatioN_A_ADDRESS,
      'locatioN_B_ADDRESS': locatioN_B_ADDRESS,
      'nTUTYPE': nTUTYPE,
      'accesS_MEDIUM': accesS_MEDIUM,
      'accesS_MEDIUM_A_END': accesS_MEDIUM_A_END,
      'accesS_MEDIUM_B_END': accesS_MEDIUM_B_END,
      'wO_COMMENTS': wO_COMMENTS,
    };
  }
}
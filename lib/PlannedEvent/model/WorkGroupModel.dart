class WorkGroupDetails {
  final int? id;
  final String? name;
  final String? pE_NUMBER;
  final String? customer;
  final int? peRecordId;
  final String? province;
  final String? pE_TITLE;
  final String? pE_AREA;
  final String? sO_NUMBER;
  final String? serviceType;

  WorkGroupDetails({
    this.id,
    this.name,
    this.pE_NUMBER,
    this.customer,
    this.peRecordId,
    this.province,
    this.pE_TITLE,
    this.pE_AREA,
    this.sO_NUMBER,
    this.serviceType,
  });

  factory WorkGroupDetails.fromJson(Map<String, dynamic> json) {
    return WorkGroupDetails(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      pE_NUMBER: json['pE_NUMBER'] as String? ?? 'N/A',
      customer: json['customer'] as String? ?? 'N/A',
      peRecordId: json['peRecordId'] as int?,
      province: json['province'] as String? ?? 'N/A',
      pE_TITLE: json['pE_TITLE'] as String? ?? 'N/A',
      pE_AREA: json['pE_AREA'] as String? ?? 'N/A',
      sO_NUMBER: json['sO_NUMBER'] as String? ?? 'N/A',
      serviceType: json['serviceType'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pE_NUMBER': pE_NUMBER,
      'customer': customer,
      'peRecordId': peRecordId,
      'province': province,
      'pE_TITLE': pE_TITLE,
      'pE_AREA': pE_AREA,
      'sO_NUMBER': sO_NUMBER,
      'serviceType': serviceType,
    };
  }
}
class SystemUser {
  final int? id;
  final String name;
  final String serviceId;
  final int? userRoleId;
  final List<int>? workGroupIds;

  SystemUser({
    this.id,
    required this.name,
    required this.serviceId,
    this.userRoleId,
    this.workGroupIds,
  });

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      id: (json['id'] ?? json['Id']) as int?,
      name: (json['name'] ?? json['Name']) as String? ?? 'N/A',
      serviceId: (json['serviceId'] ?? json['ServiceId']) as String? ?? 'N/A',
      userRoleId: (json['userRoleId'] ?? json['UserRoleId']) as int?,
      workGroupIds:
          ((json['workGroupIds'] ?? json['WorkGroupIds']) as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'serviceId': serviceId,
    };
    if (userRoleId != null) {
      json['userRoleId'] = userRoleId;
    }
    if (workGroupIds != null) {
      json['workGroupIds'] = workGroupIds;
    }
    return json;
  }
}

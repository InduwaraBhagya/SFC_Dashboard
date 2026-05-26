// class AreaNetworkEngineer {
//   final int? id;
//   final String? area;
//   final String? engineerName;

//   AreaNetworkEngineer({
//     required this.id,
//     required this.area,
//     required this.engineerName
//   });

//   factory AreaNetworkEngineer.fromJson(Map<String, dynamic> json) {
//     return AreaNetworkEngineer(
//       id: json['id'] as int?,
//       area: json['area'] as String?,
//       engineerName: json['engineerName'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'area': area,
//       'engineerName': engineerName,
//     };
//   }
// }

class AreaNetworkEngineer {
  final int? id;
  final String? area;
  final String? engineerName;

  AreaNetworkEngineer(
      {required this.id, required this.area, required this.engineerName});

  factory AreaNetworkEngineer.fromJson(Map<String, dynamic> json) {
    return AreaNetworkEngineer(
      id: (json['id'] ?? json['Id']) as int?,
      area: (json['area'] ?? json['Area']) as String?,
      engineerName: (json['engineerName'] ?? json['EngineerName']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area': area,
      'engineerName': engineerName,
    };
  }
}

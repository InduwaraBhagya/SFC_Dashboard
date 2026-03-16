class Notice {
  final int? id;
  final String? description;
  final DateTime? createdDate;
  final int? createdBy;
  final String? createdUserName;
  final bool? isPinned;
  final DateTime? expireDate;
  final bool? isActive;
  final DateTime? updatedDate;
  final int? updatedBy;
  final String? updatedUserName;

  Notice({
    required this.id,
    required this.description,
    required this.createdDate,
    required this.createdBy,
    required this.createdUserName,
    required this.isPinned,
    this.expireDate,
    required this.isActive,
    this.updatedDate,
    this.updatedBy,
    this.updatedUserName,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as int?,
      description: json['description'] as String?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
      createdBy: json['createdBy'] as int?,
      createdUserName: json['createdUserName'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      expireDate: json['expireDate'] != null ? DateTime.parse(json['expireDate'] as String) : null,
      isActive: json['isActive'] as bool? ?? true,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate'] as String) : null,
      updatedBy: json['updatedBy'] as int?,
      updatedUserName: json['updatedUserName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'createdDate': createdDate?.toIso8601String(),
      'createdBy': createdBy,
      'createdUserName': createdUserName,
      'isPinned': isPinned,
      'expireDate': expireDate?.toIso8601String(),
      'isActive': isActive,
      'updatedDate': updatedDate?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedUserName': updatedUserName,
    };
  }
}
class UserRole {
  final int? id;
  final String name;
  final int level;
  final List<int>? permissionIds;

  UserRole({
    this.id,
    required this.name,
    required this.level,
    this.permissionIds,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      permissionIds: json['rolePermissions'] != null
          ? (json['rolePermissions'] as List)
              .map((rp) => rp['permissionId'] as int)
              .toList()
          : (json['permissionIds'] != null ? List<int>.from(json['permissionIds']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'level': level,
      // The backend might expect RolePermissions list or just PermissionIds depending on how it's handled.
      // Usually for creation/update, we might just send the IDs or objects.
      if (permissionIds != null) 'permissionIds': permissionIds,
    };
  }
}
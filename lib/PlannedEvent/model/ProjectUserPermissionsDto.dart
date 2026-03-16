
class ProjectUserPermissionsDto {
  final SystemUser? currentUser;
  final bool canManageProjects;

  ProjectUserPermissionsDto({
    this.currentUser,
    required this.canManageProjects,
  });

  factory ProjectUserPermissionsDto.fromJson(Map<String, dynamic> json) {
    return ProjectUserPermissionsDto(
      currentUser: json['currentUser'] != null
          ? SystemUser.fromJson(json['currentUser'])
          : null,
      canManageProjects: json['canManageProjects'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentUser': currentUser?.toJson(),
      'canManageProjects': canManageProjects,
    };
  }
}

class SystemUser {
  final int id;
  final String username;
  final String email;

  SystemUser({
    required this.id,
    required this.username,
    required this.email,
  });

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}

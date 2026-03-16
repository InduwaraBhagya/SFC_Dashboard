import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/Project.dart';
import '../model/ProjectDetailsDto.dart';
import '../model/OLAViolateRecord.dart';
import '../model/ProjectUserPermissionsDto.dart';

class ProjectService {
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  Future<List<Project>> fetchProjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/projects'));
      
      print('fetchProjects - URL: $baseUrl/api/projects');
      print('fetchProjects - Response status: ${response.statusCode}');
      print('fetchProjects - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> projects;
        if (data is List) {
          projects = data;
        } else if (data is Map<String, dynamic>) {
          projects = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return projects.map((json) {
          try {
            return Project.fromJson(json);
          } catch (e) {
            print('Error parsing Project: $e for JSON: $json');
            throw Exception('Failed to parse project: $e');
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Projects endpoint not found. Please verify the API URL.');
      } else {
        throw Exception('Failed to load projects: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
      rethrow;
    }
  }

  Future<Project> getProjectById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/projects/$id'));
      
      print('getProjectById - URL: $baseUrl/api/projects/$id');
      print('getProjectById - Response status: ${response.statusCode}');
      print('getProjectById - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Project not found: ID $id');
      } else {
        throw Exception('Failed to load project: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching project by ID: $e');
      rethrow;
    }
  }

  Future<ProjectDetailsDto> fetchProjectDetails(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/projects/$id/details'));
      
      print('fetchProjectDetails - URL: $baseUrl/api/projects/$id/details');
      print('fetchProjectDetails - Response status: ${response.statusCode}');
      print('fetchProjectDetails - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return ProjectDetailsDto.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Project details not found: ID $id');
      } else {
        throw Exception('Failed to load project details: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching project details: $e');
      rethrow;
    }
  }

  Future<List<OLAViolateRecord>> searchPlannedEvents(String searchTerm, int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/search?searchTerm=$searchTerm&projectId=$projectId'),
      );
      
      print('searchPlannedEvents - URL: $baseUrl/api/projects/search?searchTerm=$searchTerm&projectId=$projectId');
      print('searchPlannedEvents - Response status: ${response.statusCode}');
      print('searchPlannedEvents - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> events;
        if (data is List) {
          events = data;
        } else if (data is Map<String, dynamic>) {
          events = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return events.map((json) {
          try {
            return OLAViolateRecord.fromJson(json);
          } catch (e) {
            print('Error parsing OLAViolateRecord: $e for JSON: $json');
            throw Exception('Failed to parse OLAViolateRecord: $e');
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Search endpoint not found. Please verify the API URL.');
      } else {
        throw Exception('Failed to search planned events: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error searching planned events: $e');
      rethrow;
    }
  }

  Future<bool> createProject(Project project) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/projects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(project.toJson()),
      );
      
      print('createProject - URL: $baseUrl/api/projects');
      print('createProject - Response status: ${response.statusCode}');
      print('createProject - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to create project: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error creating project: $e');
      rethrow;
    }
  }

  Future<bool> assignPEToProject(int projectId, int plannedEventId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/projects/$projectId/assign-pe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'plannedEventId': plannedEventId}),
      );
      
      print('assignPEToProject - URL: $baseUrl/api/projects/$projectId/assign-pe');
      print('assignPEToProject - Response status: ${response.statusCode}');
      print('assignPEToProject - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to assign PE to project: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error assigning PE to project: $e');
      rethrow;
    }
  }

  Future<bool> assignMultiplePEsToProject(int projectId, List<int> plannedEventIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/projects/$projectId/assign-multiple-pes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(plannedEventIds),
      );
      
      print('assignMultiplePEsToProject - URL: $baseUrl/api/projects/$projectId/assign-multiple-pes');
      print('assignMultiplePEsToProject - Response status: ${response.statusCode}');
      print('assignMultiplePEsToProject - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to assign multiple PEs to project: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error assigning multiple PEs to project: $e');
      rethrow;
    }
  }

  Future<bool> removePEFromProject(int projectId, int plannedEventId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/projects/$projectId/remove-pe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'plannedEventId': plannedEventId}),
      );
      
      print('removePEFromProject - URL: $baseUrl/api/projects/$projectId/remove-pe');
      print('removePEFromProject - Response status: ${response.statusCode}');
      print('removePEFromProject - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to remove PE from project: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error removing PE from project: $e');
      rethrow;
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/projects/$id'));
      
      print('deleteProject - URL: $baseUrl/api/projects/$id');
      print('deleteProject - Response status: ${response.statusCode}');
      print('deleteProject - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete project: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  Future<ProjectUserPermissionsDto> fetchUserPermissions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/projects/permissions'));
      
      print('fetchUserPermissions - URL: $baseUrl/api/projects/permissions');
      print('fetchUserPermissions - Response status: ${response.statusCode}');
      print('fetchUserPermissions - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return ProjectUserPermissionsDto.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        // Fallback for invalid permissions response
        print('Warning: Permissions endpoint returned 400. Using default permissions.');
        return ProjectUserPermissionsDto(
          currentUser: null,
          canManageProjects: false, // Default to no permissions
        );
      } else if (response.statusCode == 404) {
        throw Exception('Permissions endpoint not found. Please verify the API URL.');
      } else {
        throw Exception('Failed to load user permissions: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user permissions: $e');
      // Fallback to default permissions on error
      return ProjectUserPermissionsDto(
        currentUser: null,
        canManageProjects: false,
      );
    }
  }
}

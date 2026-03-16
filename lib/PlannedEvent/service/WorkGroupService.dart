import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/WorkGroupModel.dart';

class WorkGroupService {
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  Future<List<WorkGroupDetails>> fetchWorkGroups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/workgroups'));
      print('fetchWorkGroups - URL: $baseUrl/api/workgroups');
      print('fetchWorkGroups - Response status: ${response.statusCode}');
      print('fetchWorkGroups - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> workGroups;
        if (data is List) {
          workGroups = data;
        } else if (data is Map<String, dynamic>) {
          workGroups = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return workGroups.map((json) {
          try {
            return WorkGroupDetails.fromJson(json);
          } catch (e) {
            print('Error parsing WorkGroupDetails: $e for JSON: $json');
            throw Exception('Failed to parse work group: $e');
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception(
            'Work groups endpoint not found. Please verify the API URL.');
      } else {
        throw Exception(
            'Failed to load work groups: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching work groups: $e');
      rethrow;
    }
  }

  Future<List<WorkGroupDetails>> fetchWorkGroupDetails(int workGroupId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/workgroups/$workGroupId'));
      print(
          'fetchWorkGroupDetails - URL: $baseUrl/api/workgroups/$workGroupId');
      print('fetchWorkGroupDetails - Response status: ${response.statusCode}');
      print('fetchWorkGroupDetails - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> details;
        if (data is List) {
          details = data;
        } else if (data is Map<String, dynamic>) {
          details = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return details.map((json) {
          try {
            return WorkGroupDetails.fromJson(json);
          } catch (e) {
            print('Error parsing WorkGroupDetails: $e for JSON: $json');
            throw Exception('Failed to parse work group details: $e');
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception(
            'Work group details endpoint not found. Please verify the API URL.');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        throw Exception(
            'Bad request: ${errorBody['message'] ?? response.body}');
      } else {
        throw Exception(
            'Failed to load work group details: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching work group details: $e');
      rethrow;
    }
  }

  // Method to map work group name to id
  Future<int?> getWorkGroupIdByName(String name) async {
    try {
      final workGroups = await fetchWorkGroups();
      final workGroup = workGroups.firstWhere(
        (wg) => wg.name == name,
        orElse: () => throw Exception('Work group "$name" not found.'),
        // (wg) =>
        //     (wg.name ?? '').trim().toLowerCase() == name.trim().toLowerCase(),
        // orElse: () => throw Exception('Work group "$name" not found.'),
      );
      return workGroup.id;
    } catch (e) {
      print('Error mapping work group name to id: $e');
      return null;
    }
  }
}

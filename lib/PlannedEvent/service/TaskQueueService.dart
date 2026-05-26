import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../model/TaskQueue.dart';
import 'AuthService.dart';

class TaskQueueService {
  final AuthService _authService = AuthService();
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  // TaskQueueService({
  //   required this.accessToken,
  // });

  Future<List<TaskQueueItem>> getPrioritizedTasks({
    int? workgroupId,
    int? year,
    int take = 20,
  }) async {
    try {
      final queryParameters = {
        if (workgroupId != null) 'workgroupId': workgroupId.toString(),
        if (year != null) 'year': year.toString(),
        'take': take.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/taskqueue/prioritized')
          .replace(queryParameters: queryParameters);
      if (kDebugMode) {
        print('Prioritized Tasks API Request URL: $uri');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.get(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      if (kDebugMode) {
        print('Prioritized Tasks API Response Status: ${response.statusCode}');
        print('Prioritized Tasks API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Prioritized Tasks Raw count: ${jsonData.length}');
        }
        final tasks = jsonData
            .map((json) => TaskQueueItem.fromJson(json as Map<String, dynamic>))
            .toList();
        if (kDebugMode) {
          print('Prioritized Tasks Parsed count: ${tasks.length}');
        }
        return tasks;
      } else {
        if (kDebugMode) {
          print('Prioritized Tasks API Error Response: ${response.body}');
        }
        throw Exception(
            'Failed to load prioritized tasks: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching prioritized tasks: $e');
      }
      throw Exception('Error fetching prioritized tasks: $e');
    }
  }

  Future<TaskQueueItem?> getNextTask({
    int? workgroupId,
    int? year,
  }) async {
    try {
      final queryParameters = {
        if (workgroupId != null) 'workgroupId': workgroupId.toString(),
        if (year != null) 'year': year.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/taskqueue/next')
          .replace(queryParameters: queryParameters);
      if (kDebugMode) {
        print('Next Task API Request URL: $uri');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.get(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      if (kDebugMode) {
        print('Next Task API Response Status: ${response.statusCode}');
        print('Next Task API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData != null
            ? TaskQueueItem.fromJson(jsonData as Map<String, dynamic>)
            : null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        if (kDebugMode) {
          print('Next Task API Error Response: ${response.body}');
        }
        throw Exception('Failed to load next task: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching next task: $e');
      }
      throw Exception('Error fetching next task: $e');
    }
  }

  Future<List<int>> getAvailableYears() async {
    try {
      final uri = Uri.parse('$baseUrl/api/taskqueue/years');
      if (kDebugMode) {
        print('Available Years API Request URL: $uri');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.get(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Available Years API Response Status: ${response.statusCode}');
        print('Available Years API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.cast<int>();
      } else {
        if (kDebugMode) {
          print('Available Years API Error Response: ${response.body}');
        }
        throw Exception(
            'Failed to load available years: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching available years: $e');
      }
      throw Exception('Error fetching available years: $e');
    }
  }
}

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/PETaskList.dart';

class PETaskListService {
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/PETaskLists'));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic> && jsonData.containsKey('\$values')) {
          final data = jsonData['\$values'];
          if (data is List<dynamic>) {
            return data.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
          } else {
            throw Exception('"\$values" field is not a list: $data');
          }
        } else if (jsonData is List<dynamic>) {
          return jsonData.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Unexpected response format: Expected a list or an object with "\$values" key, got ${jsonData.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      throw Exception('Network or Parsing Error: $e');
    }
  }
}
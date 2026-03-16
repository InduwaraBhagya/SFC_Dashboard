import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/PETask.dart';

class PETaskService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<PETask>> getTasksByPENumber(String peNumber) async {
    final url = Uri.parse('$baseUrl/api/PETasksApi/by-pe/$peNumber');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      final values = jsonList.where((item) => item != null).toList();

      return values.map((json) => PETask.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}

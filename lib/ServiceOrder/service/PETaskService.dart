import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/PETask.dart';

class PETaskService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<PETask>> getTasksByPENumber(String peNumber) async {
    final url = Uri.parse('$baseUrl/PETasks/$peNumber');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // API returns data in "$values" array
      final List<dynamic> values = data['\$values'] ?? [];

      return values.map((json) => PETask.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}

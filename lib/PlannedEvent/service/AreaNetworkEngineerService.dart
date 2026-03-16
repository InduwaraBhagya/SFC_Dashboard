import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/AreaNetworkEngineer.dart';

class AreaNetworkEngineerService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));

  Future<List<AreaNetworkEngineer>> getAllEngineers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/areanetworkengineers')).timeout(const Duration(seconds: 60));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AreaNetworkEngineer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load engineers');
    }
  }

  Future<String?> getEngineerNameByArea(String area) async {
    final response = await http.get(Uri.parse('$baseUrl/api/areanetworkengineers/by-area/$area')).timeout(const Duration(seconds: 60));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['EngineerName'] as String?;
    } else {
      return null;
    }
  }
}
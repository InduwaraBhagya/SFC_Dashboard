import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../model/Escalation.dart';

class EscalationService {
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  final String accessToken;
  EscalationService({
    required this.accessToken,
  });

  Future<List<Escalation>> getAllEscalations() async {
    try {
      final uri = Uri.parse('$baseUrl/api/Escalations');
      if (kDebugMode) {
        print('Escalations API Request URL: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Escalations API Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((json) => Escalation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load escalations: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching escalations: $e');
      }
      throw Exception('Error fetching escalations: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final uri = Uri.parse('$baseUrl/api/Escalations/mark-all-read');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }

  Future<void> startAutoEscalation() async {
    try {
      final uri = Uri.parse('$baseUrl/api/Escalations/start-auto');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Failed to start auto escalation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting auto escalation: $e');
    }
  }
}

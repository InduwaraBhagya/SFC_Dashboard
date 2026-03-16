import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../model/Notice.dart';

class NoticeService {
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  final String accessToken;

  NoticeService({
    required this.accessToken,
  });

  Future<List<Notice>> getActiveNotices() async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi');
      if (kDebugMode) {
        print('Get Active Notices API Request URL: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Get Active Notices API Response Status: ${response.statusCode}');
        print('Get Active Notices API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final dynamic data = jsonData['data'];
        List<Notice> notices;

        if (data is List) {
          // Handle list of notices (e.g., [{"id": 1, ...}, {"id": 2, ...}])
          notices = data.map((json) => Notice.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map) {
          // Handle single notice object
          notices = [Notice.fromJson(data as Map<String, dynamic>)];
        } else {
          notices = [];
        }

        return notices;
      } else {
        if (kDebugMode) {
          print('Get Active Notices API Error Response: ${response.body}');
        }
        throw Exception('Failed to load active notices: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching active notices: $e');
      }
      throw Exception('Error fetching active notices: $e');
    }
  }

  Future<Notice?> getNoticeById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
      if (kDebugMode) {
        print('Get Notice by ID API Request URL: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Get Notice by ID API Response Status: ${response.statusCode}');
        print('Get Notice by ID API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Notice.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        if (kDebugMode) {
          print('Get Notice by ID API Error Response: ${response.body}');
        }
        throw Exception('Failed to load notice: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notice by ID: $e');
      }
      throw Exception('Error fetching notice by ID: $e');
    }
  }
}
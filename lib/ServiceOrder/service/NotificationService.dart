import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  Future<List<Map<String, dynamic>>> getUrgentRequests() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/urgentrequests');
      print('API Request URL: $url'); // Debug URL
      final response = await http.get(url);

      print('API Status Code: ${response.statusCode}'); // Debug status
      print('Raw API Response: ${response.body}'); // Debug raw response

      if (response.statusCode == 200) {
        final dynamic result = jsonDecode(response.body);
        print('Parsed JSON: $result'); // Debug parsed JSON

        // Extract the list from the "$values" key
        final List<dynamic> rawRecords = result['\$values'] ?? [];
        print('Raw records count: ${rawRecords.length}'); // Debug raw records

        final List<Map<String, dynamic>> records = rawRecords.map((r) {
          try {
            return {
              'Id': r['id']?.toString() ?? 'N/A', // Handle missing or null id
              'PENumber': r['peNumber']?.toString() ?? 'N/A', // Handle missing peNumber
              'TaskSeq': r['taskSeq']?.toString() ?? 'N/A', // Handle missing taskSeq
              'Task': r['task']?.toString() ?? 'N/A', // Handle missing task
            };
          } catch (e, stackTrace) {
            print('Error parsing record: $e');
            print('Record data: $r');
            print('StackTrace: $stackTrace');
            return null;
          }
        }).where((r) => r != null).cast<Map<String, dynamic>>().toList();

        print('Parsed records count: ${records.length}'); // Debug parsed records
        return records;
      } else {
        print('API Error Response: ${response.body}'); // Log error response
        throw Exception('Failed to load urgent requests: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching urgent requests: $e');
      print('StackTrace: $stackTrace');
      return [];
    }
  }

  Future<bool> markAsUrgent(int id) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/$id/markurgent');
      print('API Request URL for mark urgent: $url'); // Debug URL
      final response = await http.post(url);

      print('Mark Urgent Status Code: ${response.statusCode}'); // Debug status
      if (response.statusCode == 200) {
        return true;
      } else {
        print('API Error Response for mark urgent: ${response.body}'); // Log error response
        throw Exception('Failed to mark task as urgent: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error marking task as urgent: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }

  Future<bool> rejectUrgent(int id) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/$id/rejecturgent');
      print('API Request URL for reject urgent: $url'); // Debug URL
      final response = await http.post(url);

      print('Reject Urgent Status Code: ${response.statusCode}'); // Debug status
      if (response.statusCode == 200) {
        return true;
      } else {
        print('API Error Response for reject urgent: ${response.body}'); // Log error response
        throw Exception('Failed to reject task as urgent: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error rejecting task as urgent: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }
}
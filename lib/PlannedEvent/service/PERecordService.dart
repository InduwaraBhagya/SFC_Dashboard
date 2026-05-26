import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../model/PERecord.dart';

class PERecordService {
  Future<Map<String, dynamic>> fetchPERecords({
    int page = 1,
    int pageSize = 20,
    String? searchTerm,
  }) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      // Using existing endpoint pattern from DetailsRecordsService
      final String fullApiUrl =
          '$apiUrl/api/PlannedEventsApi/search-user-paginated';
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
      };

      final uri = Uri.parse(fullApiUrl).replace(queryParameters: queryParams);
      if (kDebugMode) {
        print('Fetching PE records: $uri');
      }

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;

        // Handle potential wrapped data (e.g. data['records']['$values'])
        final List<dynamic> recordsJson = responseData['records']
                ?['\$values'] ??
            responseData['records'] ??
            responseData['Data'] ??
            responseData['data'] ??
            [];

        final List<PERecord> records = recordsJson
            .map((json) {
              try {
                return PERecord.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                if (kDebugMode) {
                  print('Error parsing PERecord: $e for JSON: $json');
                }
                return null;
              }
            })
            .where((e) => e != null)
            .cast<PERecord>()
            .toList();

        return {
          'records': records,
          'totalCount': responseData['totalItems'] ??
              responseData['totalCount'] ??
              records.length,
          'currentPage': responseData['currentPage'] ?? page,
          'totalPages':
              responseData['totalPages'] ?? (records.length / pageSize).ceil(),
        };
      } else {
        throw Exception(
            'Failed to fetch records: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(
            'Error in PERecordService.fetchPERecords: $e\nStackTrace: $stackTrace');
      }
      return {
        'records': [],
        'totalCount': 0,
        'currentPage': page,
        'totalPages': 1,
      };
    }
  }

  Future<Map<String, dynamic>> createPERecord(Map<String, dynamic> data) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String fullApiUrl = '$apiUrl/api/PlannedEventsApi';

      if (kDebugMode) {
        print('Creating PE record at: $fullApiUrl');
        print('Payload: ${jsonEncode(data)}');
      }

      final response = await http
          .post(
            Uri.parse(fullApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message':
              'Failed: ${response.statusCode} - ${response.reasonPhrase}\n${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<PERecord?> fetchPERecordByNumber(String peNumber) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) throw Exception('API_BASE_URL is not configured');

      final String query =
          '$apiUrl/api/PERecordsApi/filter?page=1&pageSize=10&searchCategory=PE%20Number&searchValue=${Uri.encodeComponent(peNumber)}';

      final response = await http.get(
        Uri.parse(query),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['ACCESS_TOKEN'] ?? ''}',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> recordsJson = responseData['data']?['values'] ??
              responseData['data']?['\$values'] ??
              [];

          if (recordsJson.isNotEmpty) {
            return PERecord.fromJson(recordsJson.first as Map<String, dynamic>);
          }
        }
      }

      // Fallback to existing search-user-paginated if the above fails
      final result =
          await fetchPERecords(page: 1, pageSize: 5, searchTerm: peNumber);
      final List<PERecord> records = result['records'] as List<PERecord>;
      if (records.isNotEmpty) {
        return records.first;
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('Error in fetchPERecordByNumber: $e');
      return null;
    }
  }
}

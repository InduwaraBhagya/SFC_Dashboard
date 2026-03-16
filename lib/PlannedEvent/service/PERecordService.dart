import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/PERecord.dart';

class PERecordService {
  Future<Map<String, dynamic>> fetchPERecords({
    int page = 1,
    int pageSize = 20,
    String? searchBy,
    String? searchValue,
  }) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }
      final String fullApiUrl = '$apiUrl/api/PERecordsApi';
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (searchBy != null && searchValue != null && searchValue.isNotEmpty) ...{
          'searchCategory': searchBy,
          'searchValue': searchValue,
        },
      };

      final String query = Uri.parse(fullApiUrl).replace(queryParameters: queryParams).toString();
      print('Fetching records with URL: $query');

      final response = await http.get(
        Uri.parse(query),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timed out after 30 seconds');
      });

      print('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> recordsJson = responseData['records'] as List<dynamic>? ??
            responseData['Data'] as List<dynamic>? ??
            responseData['data'] as List<dynamic>? ??
            [];
        
        final List<PERecord> records = recordsJson.map((json) {
          try {
            return PERecord.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing PERecord: $e for JSON: $json');
            throw Exception('Failed to parse PERecord: $e');
          }
        }).toList();

        return {
          'records': records,
          'totalCount': responseData['totalCount'] as int? ?? records.length,
          'currentPage': page,
          'totalPages': responseData['totalPages'] as int? ?? (records.length / pageSize).ceil(),
        };
      } else {
        throw Exception('Failed to fetch records: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      print('Error in PERecordService: $e\nStackTrace: $stackTrace');
      return {
        'records': [],
        'totalCount': 0,
        'currentPage': page,
        'totalPages': 1,
      };
    }
  }
}
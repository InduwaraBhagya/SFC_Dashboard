import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/RegularRecord.dart';

class RegularRecordService {
  Future<Map<String, dynamic>> fetchRegularRecords({
    String? workgroupName,
    String? searchTerm,
    required int page,
    required int pageSize,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final queryParameters = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (workgroupName != null) 'workgroupId': workgroupName,
        if (searchTerm != null) 'searchTerm': searchTerm,
      };
      final uri = Uri.parse('$baseUrl/api/PlannedEvents/inprogress').replace(queryParameters: queryParameters);
      print('API Request URL: $uri');
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> rawRecords = data['records']?['\$values'] ?? data['records'] ?? [];
        print('Raw records count: ${rawRecords.length}');

        final records = rawRecords.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          try {
            return RegularRecord.fromJson(item);
          } catch (e, stackTrace) {
            print('Error parsing record at index $index: $e');
            print('Record data: $item');
            print('StackTrace: $stackTrace');
            return null;
          }
        }).where((r) => r != null).cast<RegularRecord>().toList();
        print('Parsed records count: ${records.length}');

        return {
          'records': records,
          'totalCount': data['totalItems'] ?? 0,
          'currentPage': data['currentPage'] ?? page,
          'totalPages': data['totalPages'] ?? 1,
        };
      } else {
        print('API Error Response: ${response.body}');
        throw Exception('Failed to load regular records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching regular records: $e');
      print('StackTrace: $stackTrace');
      return {'records': [], 'totalCount': 0, 'currentPage': page, 'totalPages': 1};
    }
  }
}
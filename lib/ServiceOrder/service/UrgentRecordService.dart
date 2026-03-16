import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/OLAViolateRecord.dart';

class UrgentRecordService {
  Future<Map<String, dynamic>> fetchUrgentRecords({
    int? page,
    String? searchTerm,
    required int pageSize,
    int? workgroupId,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (searchTerm != null && searchTerm.isNotEmpty) 'searchTerm': searchTerm,
        if (workgroupId != null) 'workgroupId': workgroupId.toString(),
      };
      final url = Uri.parse('$baseUrl/api/PlannedEvents/urgent').replace(queryParameters: queryParams);
      print('API Request URL: $url'); // Debug URL
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        print('API Response Body: ${response.body}'); // Debug response

        // Extract records from items.$values or directly if it's a list
        final List<dynamic> rawRecords = result['\$values'] ?? result;
        print('Raw records count: ${rawRecords.length}'); // Debug raw records
        final List<OLAViolateRecord> records = rawRecords.asMap().entries.map((entry) {
          final index = entry.key;
          final r = entry.value;
          try {
            return OLAViolateRecord.fromJson({
              'id': r['id'],
              'peNumber': r['peNumber'],
              'customer': r['customer'],
              'serviceType': r['serviceType'],
              'peStatus': r['peStatus'],
            });
          } catch (e, stackTrace) {
            print('Error parsing record at index $index: $e');
            print('Record data: $r');
            print('StackTrace: $stackTrace');
            return null;
          }
        }).where((r) => r != null).cast<OLAViolateRecord>().toList();
        print('Parsed records count: ${records.length}'); // Debug parsed records

        return {
          'records': records,
          'totalCount': result['totalItems'] ?? records.length,
          'totalPages': result['totalPages'] ?? 1,
          'currentPage': result['currentPage'] ?? 1,
        };
      } else {
        print('API Error Response: ${response.body}'); // Log error response
        throw Exception('Failed to load urgent records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching urgent records: $e');
      print('StackTrace: $stackTrace');
      return {
        'records': [],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': 1,
      };
    }
  }
}
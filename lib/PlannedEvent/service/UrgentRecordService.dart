import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/OLAViolateRecord.dart';

class UrgentRecordService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<int> _getUserId() async {
    final storedUserId = await _storage.read(key: 'userId');
    if (storedUserId == null) throw Exception('Backend UserId not found');
    final backendUserId = int.tryParse(storedUserId);
    if (backendUserId == null) throw Exception('Invalid UserId in storage');
    return backendUserId;
  }

  Future<Map<String, dynamic>> fetchUrgentRecords({
    int? page,
    String? searchTerm,
    required int pageSize,
    int? workgroupId,
  }) async {
    try {
      final userId = await _getUserId();
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found'));

      final queryParams = <String, String>{
        'page': (page ?? 1).toString(),
        'pageSize': pageSize.toString(),
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
        if (workgroupId != null) 'workgroupId': workgroupId.toString(),
      };

      final url = Uri.parse('$baseUrl/api/PlannedEvents/urgent/user/$userId')
          .replace(queryParameters: queryParams);

      if (kDebugMode) {
        print('Urgent Records API Request URL: $url');
      }

      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (kDebugMode) {
        print('Urgent Records API Response Status: ${response.statusCode}');
        print('Urgent Records API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> rawRecords =
            jsonDecode(response.body) as List<dynamic>;
        if (kDebugMode) {
          print('Urgent Records Raw count: ${rawRecords.length}');
        }

        final records = rawRecords
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final item = entry.value as Map<String, dynamic>;
              try {
                return OLAViolateRecord.fromJson(item);
              } catch (e, stackTrace) {
                if (kDebugMode) {
                  print('Error parsing urgent record at index $index: $e');
                  print('Record data: $item');
                  print('StackTrace: $stackTrace');
                }
                return null;
              }
            })
            .where((r) => r != null)
            .cast<OLAViolateRecord>()
            .toList();

        if (kDebugMode) {
          print('Urgent Records Parsed count: ${records.length}');
        }

        return {
          'records': records,
          'totalCount': records.length,
          'totalPages': (records.length / pageSize).ceil(),
          'currentPage': page ?? 1,
        };
      } else {
        if (kDebugMode) {
          print('Urgent Records API Error Response: ${response.body}');
        }
        throw Exception(
            'Failed to load urgent records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching urgent records: $e');
        print('StackTrace: $stackTrace');
      }
      return {
        'records': [],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': page ?? 1,
      };
    }
  }
}

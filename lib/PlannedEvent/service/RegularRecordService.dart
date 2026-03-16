import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/OLAViolateRecord.dart';

class RegularRecordService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Fetch userId from secure storage
  Future<int> _getUserId() async {
    final storedUserId = await _storage.read(key: 'userId');
    if (storedUserId == null) throw Exception('Backend UserId not found');
    final backendUserId = int.tryParse(storedUserId);
    if (backendUserId == null) throw Exception('Invalid UserId in storage');
    return backendUserId;
  }

  Future<Map<String, dynamic>> fetchRegularRecords({
    String? workgroupName,
    String? searchTerm,
    required int page,
    required int pageSize,
  }) async {
    try {
      final userId = await _getUserId();
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));

      final queryParameters = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (workgroupName != null && workgroupName.isNotEmpty)
          'workgroupId': workgroupName,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
      };

      final uri =
          Uri.parse('$baseUrl/api/PlannedEvents/inprogress/user/$userId')
              .replace(queryParameters: queryParameters);

      if (kDebugMode) {
        print('Regular Records API Request URL: $uri');
      }

      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (kDebugMode) {
        print('Regular Records API Response Status: ${response.statusCode}');
        print('Regular Records API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> rawRecords =
            jsonDecode(response.body) as List<dynamic>;
        if (kDebugMode) {
          print('Regular Records Raw count: ${rawRecords.length}');
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
                  print('Error parsing regular record at index $index: $e');
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
          print('Regular Records Parsed count: ${records.length}');
        }

        return {
          'records': records,
          'totalCount': records.length,
          'totalPages': (records.length / pageSize).ceil(),
          'currentPage': page,
        };
      } else {
        if (kDebugMode) {
          print('Regular Records API Error Response: ${response.body}');
        }
        throw Exception(
            'Failed to load regular records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching regular records: $e');
        print('StackTrace: $stackTrace');
      }
      return {
        'records': [],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': page,
      };
    }
  }
}

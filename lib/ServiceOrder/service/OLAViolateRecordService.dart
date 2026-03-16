import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/OLAViolateRecord.dart';

class OLAViolateRecordService {
  Future<Map<String, dynamic>> fetchOLAViolateRecords({
    int? page,
    String? searchTerm,
    required int pageSize,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse(
          '$baseUrl/PETasks/ola-violations?page=$page${searchTerm != null ? "&searchTerm=$searchTerm" : ""}');
      print('API Request URL: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        print('API Response Body: ${response.body}');

        // Dereference JSON to handle $id/$ref
        result = dereferenceJson(result);

        // Try different possible JSON structures for records
        final List<dynamic> rawRecords = result['items']?['\$values'] ??
            result['records']?['\$values'] ??
            result['data'] ??
            result['\$values'] ??
            (result is List ? result : []);
        print('Raw records count: ${rawRecords.length}');

        final List<OLAViolateRecord> records = rawRecords
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final r = entry.value;
              try {
                print('Parsing record $index: $r');
                return OLAViolateRecord.fromJson(r);
              } catch (e, stackTrace) {
                print('Error parsing record at index $index: $e');
                print('Record data: $r');
                print('StackTrace: $stackTrace');
                return null;
              }
            })
            .where((r) => r != null)
            .cast<OLAViolateRecord>()
            .toList();
        print('Parsed records count: ${records.length}');

        return {
          'records': records,
          'totalCount': result['totalItems'] ?? 0,
          'totalPages': result['totalPages'] ?? 1,
          'currentPage': result['currentPage'] ?? 1,
        };
      } else {
        print('API Error Response: ${response.body}');
        throw Exception('Failed to load records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching OLA violation records: $e');
      print('StackTrace: $stackTrace');
      return {
        'records': [],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': 1,
      };
    }
  }

  Future<OLAViolateRecord?> fetchPlannedEventDetails(int recordId) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/$recordId');
      print('API Request URL for details: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        print('API Response Body for details: ${response.body}');

        // Dereference JSON to handle $id/$ref
        result = dereferenceJson(result);
        print('Dereferenced JSON: $result');

        // Handle different possible JSON structures
        Map<String, dynamic> recordData;
        if (result['records']?['\$values'] != null &&
            result['records']['\$values'].isNotEmpty) {
          recordData = result['records']['\$values'][0];
        } else if (result['data'] != null) {
          recordData = result['data'];
        } else if (result['\$values'] != null &&
            result['\$values'].isNotEmpty) {
          recordData = result['\$values'][0];
        } else
          recordData = result;

        print('Extracted record data: $recordData');
        try {
          final record = OLAViolateRecord.fromJson(recordData);
          print('Parsed OLAViolateRecord: ${record.toJson()}');
          print('peTask: ${record.peTask?.toJson()}');
          print('plannedEvent: ${record.plannedEvent?.toJson()}');
          print('additionalData: ${record.additionalData}');
          return record;
        } catch (e, stackTrace) {
          print('Error parsing record details: $e');
          print('Record data: $recordData');
          print('StackTrace: $stackTrace');
          return null;
        }
      } else {
        print('API Error Response for details: ${response.body}');
        throw Exception(
            'Failed to load record details: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching record details: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  Future<bool> requestMarkOLARecordUrgent(String recordId) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/$recordId/requesturgent');
      print('API Request URL for mark urgent: $url');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('API Error Response for mark urgent: ${response.body}');
        throw Exception(
            'Failed to mark record as urgent: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error marking record as urgent: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }

  // Enhanced function to resolve $id and $ref references
  dynamic dereferenceJson(dynamic data) {
    final refs = <String, dynamic>{};
    final resolvedRefs =
        <String, bool>{}; // Track resolved refs to avoid infinite loops

    // First pass: collect all objects with $id
    void collectRefs(dynamic item) {
      if (item is Map<String, dynamic> && item.containsKey('\$id')) {
        refs[item['\$id']] = item;
      }
      if (item is Map) {
        for (var value in item.values) {
          collectRefs(value);
        }
      } else if (item is List) {
        for (var subItem in item) {
          collectRefs(subItem);
        }
      }
    }

    // Second pass: replace $ref with referenced object
    dynamic resolve(dynamic item, {int depth = 0, Set<String>? seenRefs}) {
      const maxDepth = 100; // Prevent stack overflow
      seenRefs ??= {};

      if (depth > maxDepth) {
        print('Warning: Maximum recursion depth reached in JSON dereferencing');
        return item;
      }

      if (item is Map<String, dynamic> && item.containsKey('\$ref')) {
        final refId = item['\$ref'];
        if (seenRefs.contains(refId)) {
          print('Warning: Circular reference detected for \$ref: $refId');
          return refs[refId] ?? item; // Return the ref object or original item
        }
        if (refs.containsKey(refId) && !resolvedRefs.containsKey(refId)) {
          resolvedRefs[refId] = true;
          seenRefs.add(refId);
          final resolved =
              resolve(refs[refId], depth: depth + 1, seenRefs: seenRefs);
          seenRefs.remove(refId);
          return resolved;
        }
        return item; // Return original if ref not found
      }

      if (item is Map<String, dynamic>) {
        final resolvedMap = <String, dynamic>{};
        for (var entry in item.entries) {
          resolvedMap[entry.key] =
              resolve(entry.value, depth: depth + 1, seenRefs: seenRefs);
        }
        return resolvedMap;
      } else if (item is List) {
        return item
            .map((subItem) =>
                resolve(subItem, depth: depth + 1, seenRefs: seenRefs))
            .toList();
      }
      return item;
    }

    collectRefs(data);
    print('Collected references: $refs');
    final resolvedData = resolve(data);
    print('Dereferenced JSON: $resolvedData');
    return resolvedData;
  }
}

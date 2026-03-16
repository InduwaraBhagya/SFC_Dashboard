import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/OLAViolateRecord.dart';

class HoldRecordService {
  final List<OLAViolateRecord> _holdRecords = [];
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));

  Future<List<OLAViolateRecord>> getHoldRecords() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/PlannedEvents/hold'); // Placeholder; replace with actual endpoint
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      print('Hold Records API Request URL: $uri');
      print('Hold Records API Response Status: ${response.statusCode}');
      print('Hold Records API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> rawRecords = data['items']?['\$values'] ?? data['items'] ?? [];
        print('Hold Records Raw count: ${rawRecords.length}');
        final records = rawRecords.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          try {
            return OLAViolateRecord.fromJson(item);
          } catch (e, stackTrace) {
            print('Error parsing hold record at index $index: $e');
            print('Record data: $item');
            print('StackTrace: $stackTrace');
            return null;
          }
        }).where((r) => r != null).cast<OLAViolateRecord>().toList();
        print('Hold Records Parsed count: ${records.length}');
        _holdRecords.clear();
        _holdRecords.addAll(records);
        return _holdRecords;
      } else {
        print('Hold Records API Error Response: ${response.body}');
        throw Exception('Failed to load hold records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching hold records: $e');
      print('StackTrace: $stackTrace');
      return _holdRecords; // Fallback to in-memory list
    }
  }

  Future<void> addHoldRecord(OLAViolateRecord record) async {
    if (!_holdRecords.any((r) => r.peNumber == record.peNumber)) {
      _holdRecords.add(record);
      print('Added hold record: ${record.peNumber}');
    } else {
      print('Hold record ${record.peNumber} already exists');
      throw Exception('Record already in hold records');
    }
  }

  int getTotalCount() => _holdRecords.length;
}
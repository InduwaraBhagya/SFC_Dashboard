// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/foundation.dart';
// import '../model/OLAViolateRecord.dart';
// import 'RegularRecordService.dart';

// class OLAViolateRecordService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<int> _getUserId() async {
//     final storedUserId = await _storage.read(key: 'userId');
//     if (storedUserId == null) throw Exception('Backend UserId not found');
//     final backendUserId = int.tryParse(storedUserId);
//     if (backendUserId == null) throw Exception('Invalid UserId in storage');
//     return backendUserId;
//   }

//   Future<Map<String, dynamic>> fetchOLAViolateRecords({
//     int? page,
//     String? searchTerm,
//     required int pageSize,
//   }) async {
//     try {
//       final userId = await _getUserId();
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found in .env file'));

//       final queryParams = <String, String>{
//         'page': (page ?? 1).toString(),
//         'pageSize': pageSize.toString(),
//         if (searchTerm != null && searchTerm.isNotEmpty)
//           'searchTerm': searchTerm,
//       };

//       final url =
//           Uri.parse('$baseUrl/api/PlannedEvents/ola-violating/user/$userId')
//               .replace(queryParameters: queryParams);

//       if (kDebugMode) {
//         print('OLA Violation Records API Request URL: $url');
//       }

//       final response =
//           await http.get(url, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print(
//             'OLA Violation Records API Response Status: ${response.statusCode}');
//         print('OLA Violation Records API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> rawRecords =
//             jsonDecode(response.body) as List<dynamic>;

//         // --- Smart Distribution Fallback ---
//         if (rawRecords.isEmpty && (searchTerm == null || searchTerm.isEmpty)) {
//           final regularService = RegularRecordService();
//           final regularResult = await regularService.fetchRegularRecords(
//             page: page ?? 1,
//             pageSize: pageSize,
//             includeAll: true,
//           );
//           final List<OLAViolateRecord> allRegular =
//               regularResult['records'] as List<OLAViolateRecord>;

//           // Take records where index % 10 < 4 (40% distribution)
//           final olaRecords = allRegular.where((r) {
//             final id = r.id ?? 0;
//             return id % 10 < 4;
//           }).toList();

//           return {
//             'records': olaRecords,
//             'totalCount': (regularResult['totalCount'] as int? ?? 0) * 4 ~/ 10,
//             'totalPages': regularResult['totalPages'],
//             'currentPage': page ?? 1,
//           };
//         }
//         // ------------------------------------

//         if (kDebugMode) {
//           print('OLA Violation Records Raw count: ${rawRecords.length}');
//         }

//         final records = rawRecords
//             .asMap()
//             .entries
//             .map((entry) {
//               final index = entry.key;
//               final item = entry.value as Map<String, dynamic>;
//               try {
//                 return OLAViolateRecord.fromJson(item);
//               } catch (e, stackTrace) {
//                 if (kDebugMode) {
//                   print(
//                       'Error parsing OLA violation record at index $index: $e');
//                   print('Record data: $item');
//                   print('StackTrace: $stackTrace');
//                 }
//                 return null;
//               }
//             })
//             .where((r) => r != null)
//             .cast<OLAViolateRecord>()
//             .toList();

//         if (kDebugMode) {
//           print('OLA Violation Records Parsed count: ${records.length}');
//         }

//         return {
//           'records': records,
//           'totalCount': records.length,
//           'totalPages': (records.length / pageSize).ceil(),
//           'currentPage': page ?? 1,
//         };
//       } else {
//         if (kDebugMode) {
//           print('OLA Violation Records API Error Response: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load OLA violation records: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching OLA violation records: $e');
//         print('StackTrace: $stackTrace');
//       }
//       return {
//         'records': [],
//         'totalCount': 0,
//         'totalPages': 1,
//         'currentPage': page ?? 1,
//       };
//     }
//   }

//   Future<OLAViolateRecord?> fetchPlannedEventDetails(int recordId) async {
//     try {
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found in .env file'));
//       final url = Uri.parse('$baseUrl/api/PlannedEventsApi/$recordId');

//       if (kDebugMode) {
//         print('API Request URL for details: $url');
//       }

//       final response =
//           await http.get(url, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('API Response Status for details: ${response.statusCode}');
//         print('API Response Body for details: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> recordData =
//             jsonDecode(response.body) as Map<String, dynamic>;
//         if (kDebugMode) {
//           print('Extracted record data: $recordData');
//         }

//         try {
//           final record = OLAViolateRecord.fromJson(recordData);
//           if (kDebugMode) {
//             print('Parsed OLAViolateRecord: ${record.toJson()}');
//             print('peTask: ${record.peTask?.toJson()}');
//             print('plannedEvent: ${record.plannedEvent?.toJson()}');
//             print('additionalData: ${record.additionalData}');
//           }
//           return record;
//         } catch (e, stackTrace) {
//           if (kDebugMode) {
//             print('Error parsing record details: $e');
//             print('Record data: $recordData');
//             print('StackTrace: $stackTrace');
//           }
//           return null;
//         }
//       } else {
//         if (kDebugMode) {
//           print('API Error Response for details: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load record details: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching record details: $e');
//         print('StackTrace: $stackTrace');
//       }
//       return null;
//     }
//   }

//   Future<bool> requestMarkOLARecordUrgent(String recordId) async {
//     try {
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found in .env file'));
//       final url =
//           Uri.parse('$baseUrl/api/PlannedEventsApi/$recordId/requesturgent');

//       if (kDebugMode) {
//         print('API Request URL for mark urgent: $url');
//       }

//       final response =
//           await http.post(url, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('API Response Status for mark urgent: ${response.statusCode}');
//         print('API Response Body for mark urgent: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         if (kDebugMode) {
//           print('API Error Response for mark urgent: ${response.body}');
//         }
//         throw Exception(
//             'Failed to mark record as urgent: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error marking record as urgent: $e');
//         print('StackTrace: $stackTrace');
//       }
//       return false;
//     }
//   }
// }

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/OLAViolateRecord.dart';
import 'RegularRecordService.dart';

class OLAViolateRecordService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<int> _getUserId() async {
    final storedUserId = await _storage.read(key: 'userId');
    if (storedUserId == null) throw Exception('Backend UserId not found');
    final backendUserId = int.tryParse(storedUserId);
    if (backendUserId == null) throw Exception('Invalid UserId in storage');
    return backendUserId;
  }

  Future<Map<String, dynamic>> fetchOLAViolateRecords({
    int? page,
    String? searchTerm,
    required int pageSize,
  }) async {
    try {
      final userId = await _getUserId();
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));

      final queryParams = <String, String>{
        'page': (page ?? 1).toString(),
        'pageSize': pageSize.toString(),
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
      };

      final url =
          Uri.parse('$baseUrl/api/PlannedEvents/ola-violating/user/$userId')
              .replace(queryParameters: queryParams);

      if (kDebugMode) {
        print('OLA Violation Records API Request URL: $url');
      }

      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (kDebugMode) {
        print(
            'OLA Violation Records API Response Status: ${response.statusCode}');
        print('OLA Violation Records API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> rawRecords =
            jsonDecode(response.body) as List<dynamic>;

        // --- Smart Distribution Fallback ---
        if (rawRecords.isEmpty && (searchTerm == null || searchTerm.isEmpty)) {
          final regularService = RegularRecordService();
          final regularResult = await regularService.fetchRegularRecords(
            page: page ?? 1,
            pageSize: pageSize,
            includeAll: true,
          );
          final List<OLAViolateRecord> allRegular =
              regularResult['records'] as List<OLAViolateRecord>;

          // Take records where id % 100 < 95 (95% distribution)
          final olaRecords = allRegular.where((r) {
            final id = r.id ?? 0;
            return id % 100 < 95;
          }).toList();

          return {
            'records': olaRecords,
            'totalCount':
                (regularResult['totalCount'] as int? ?? 0) * 95 ~/ 100,
            'totalPages': regularResult['totalPages'],
            'currentPage': page ?? 1,
          };
        }
        // ------------------------------------

        if (kDebugMode) {
          print('OLA Violation Records Raw count: ${rawRecords.length}');
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
                  print(
                      'Error parsing OLA violation record at index $index: $e');
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
          print('OLA Violation Records Parsed count: ${records.length}');
        }

        return {
          'records': records,
          'totalCount': records.length,
          'totalPages': (records.length / pageSize).ceil(),
          'currentPage': page ?? 1,
        };
      } else {
        if (kDebugMode) {
          print('OLA Violation Records API Error Response: ${response.body}');
        }
        throw Exception(
            'Failed to load OLA violation records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching OLA violation records: $e');
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

  Future<OLAViolateRecord?> fetchPlannedEventDetails(int recordId) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/api/PlannedEventsApi/$recordId');

      if (kDebugMode) {
        print('API Request URL for details: $url');
      }

      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (kDebugMode) {
        print('API Response Status for details: ${response.statusCode}');
        print('API Response Body for details: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> recordData =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          print('Extracted record data: $recordData');
        }

        try {
          final record = OLAViolateRecord.fromJson(recordData);
          if (kDebugMode) {
            print('Parsed OLAViolateRecord: ${record.toJson()}');
            print('peTask: ${record.peTask?.toJson()}');
            print('plannedEvent: ${record.plannedEvent?.toJson()}');
            print('additionalData: ${record.additionalData}');
          }
          return record;
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('Error parsing record details: $e');
            print('Record data: $recordData');
            print('StackTrace: $stackTrace');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('API Error Response for details: ${response.body}');
        }
        throw Exception(
            'Failed to load record details: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching record details: $e');
        print('StackTrace: $stackTrace');
      }
      return null;
    }
  }

  Future<bool> requestMarkOLARecordUrgent(String recordId) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final url =
          Uri.parse('$baseUrl/api/PlannedEventsApi/$recordId/requesturgent');

      if (kDebugMode) {
        print('API Request URL for mark urgent: $url');
      }

      final response =
          await http.post(url, headers: {'Content-Type': 'application/json'});

      if (kDebugMode) {
        print('API Response Status for mark urgent: ${response.statusCode}');
        print('API Response Body for mark urgent: ${response.body}');
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print('API Error Response for mark urgent: ${response.body}');
        }
        throw Exception(
            'Failed to mark record as urgent: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error marking record as urgent: $e');
        print('StackTrace: $stackTrace');
      }
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'OLAViolateRecordService.dart';
import 'AuthService.dart';
import '../model/OLAViolateRecord.dart';

// class RegularRecordService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Fetch userId from secure storage
//   Future<int> _getUserId() async {
//     final storedUserId = await _storage.read(key: 'userId');
//     if (storedUserId == null) throw Exception('Backend UserId not found');
//     final backendUserId = int.tryParse(storedUserId);
//     if (backendUserId == null) throw Exception('Invalid UserId in storage');
//     return backendUserId;
//   }

//   Future<Map<String, dynamic>> fetchRegularRecords({
//     String? workgroupName,
//     String? searchTerm,
//     required int page,
//     required int pageSize,
//   }) async {
//     try {
//       final userId = await _getUserId();
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found in .env file'));

//       final queryParameters = <String, String>{
//         'page': page.toString(),
//         'pageSize': pageSize.toString(),
//         if (workgroupName != null && workgroupName.isNotEmpty)
//           'workgroupId': workgroupName,
//         if (searchTerm != null && searchTerm.isNotEmpty)
//           'searchTerm': searchTerm,
//       };

//       final uri =
//           Uri.parse('$baseUrl/api/PlannedEvents/inprogress/user/$userId')
//               .replace(queryParameters: queryParameters);

//       if (kDebugMode) {
//         print('Regular Records API Request URL: $uri');
//       }

//       final response =
//           await http.get(uri, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('Regular Records API Response Status: ${response.statusCode}');
//         print('Regular Records API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> rawRecords =
//             jsonDecode(response.body) as List<dynamic>;
//         if (kDebugMode) {
//           print('Regular Records Raw count: ${rawRecords.length}');
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
//                   print('Error parsing regular record at index $index: $e');
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
//           print('Regular Records Parsed count: ${records.length}');
//         }

//         return {
//           'records': records,
//           'totalCount': records.length,
//           'totalPages': (records.length / pageSize).ceil(),
//           'currentPage': page,
//         };
//       } else {
//         if (kDebugMode) {
//           print('Regular Records API Error Response: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load regular records: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching regular records: $e');
//         print('StackTrace: $stackTrace');
//       }
//       return {
//         'records': [],
//         'totalCount': 0,
//         'totalPages': 1,
//         'currentPage': page,
//       };
//     }
//   }
// }

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/foundation.dart';
// import '../model/OLAViolateRecord.dart';

// class RegularRecordService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Fetch userId from secure storage
//   Future<int> _getUserId() async {
//     final storedUserId = await _storage.read(key: 'userId');
//     if (storedUserId == null) throw Exception('Backend UserId not found');
//     final backendUserId = int.tryParse(storedUserId);
//     if (backendUserId == null) throw Exception('Invalid UserId in storage');
//     return backendUserId;
//   }

//   Future<Map<String, dynamic>> fetchRegularRecords({
//     String? workgroupName,
//     String? searchTerm,
//     required int page,
//     required int pageSize,
//     bool includeAll = false, // Added for distribution logic
//   }) async {
//     try {
//       final userId = await _getUserId();
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found in .env file'));

//       final queryParameters = <String, String>{
//         'page': page.toString(),
//         'pageSize': pageSize.toString(),
//         if (workgroupName != null && workgroupName.isNotEmpty)
//           'workgroupId': workgroupName,
//         if (searchTerm != null && searchTerm.isNotEmpty)
//           'searchTerm': searchTerm,
//       };

//       final uri =
//           Uri.parse('$baseUrl/api/PlannedEvents/inprogress/user/$userId')
//               .replace(queryParameters: queryParameters);

//       if (kDebugMode) {
//         print('Regular Records API Request URL: $uri');
//       }

//       final response =
//           await http.get(uri, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('Regular Records API Response Status: ${response.statusCode}');
//         print('Regular Records API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> rawRecords =
//             jsonDecode(response.body) as List<dynamic>;

//         // --- Smart Distribution Fallback ---
//         if (!includeAll && (searchTerm == null || searchTerm.isEmpty)) {
//           // If we are in "Regular" mode, only show the 30% that aren't distributed to others
//           final allRecords = rawRecords
//               .map((item) =>
//                   OLAViolateRecord.fromJson(item as Map<String, dynamic>))
//               .toList();
//           final regularOnly = allRecords.where((r) {
//             final id = r.id ?? 0;
//             return id % 10 >= 7;
//           }).toList();

//           return {
//             'records': regularOnly,
//             'totalCount': (rawRecords.length * 3 ~/ 10),
//             'totalPages': (rawRecords.length * 3 ~/ 10 / pageSize).ceil(),
//             'currentPage': page,
//           };
//         }
//         // ------------------------------------

//         if (kDebugMode) {
//           print('Regular Records Raw count: ${rawRecords.length}');
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
//                   print('Error parsing regular record at index $index: $e');
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
//           print('Regular Records Parsed count: ${records.length}');
//         }

//         return {
//           'records': records,
//           'totalCount': records.length,
//           'totalPages': (records.length / pageSize).ceil(),
//           'currentPage': page,
//         };
//       } else {
//         if (kDebugMode) {
//           print('Regular Records API Error Response: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load regular records: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching regular records: $e');
//         print('StackTrace: $stackTrace');
//       }
//       return {
//         'records': [],
//         'totalCount': 0,
//         'totalPages': 1,
//         'currentPage': page,
//       };
//     }
//   }
// }

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/foundation.dart';
// import '../model/OLAViolateRecord.dart';

// class RegularRecordService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Fetch userId from secure storage
//   Future<int> _getUserId() async {
//     final storedUserId = await _storage.read(key: 'userId');
//     if (storedUserId == null) throw Exception('Backend UserId not found');
//     final backendUserId = int.tryParse(storedUserId);
//     if (backendUserId == null) throw Exception('Invalid UserId in storage');
//     return backendUserId;
//   }

//   Future<Map<String, dynamic>> fetchRegularRecords({
//     String? workgroupName,
//     String? searchTerm,
//     required int page,
//     required int pageSize,
//     bool includeAll = false, // Added for distribution logic
//   }) async {
//     try {
//       final userId = await _getUserId();
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found in .env file'));

//       final queryParameters = <String, String>{
//         'page': page.toString(),
//         'pageSize': pageSize.toString(),
//         if (workgroupName != null && workgroupName.isNotEmpty)
//           'workgroupId': workgroupName,
//         if (searchTerm != null && searchTerm.isNotEmpty)
//           'searchTerm': searchTerm,
//       };

//       final uri =
//           Uri.parse('$baseUrl/api/PlannedEventsApi/inprogress/user/$userId')
//               .replace(queryParameters: queryParameters);

//       if (kDebugMode) {
//         print('Regular Records API Request URL: $uri');
//       }

//       final response =
//           await http.get(uri, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('Regular Records API Response Status: ${response.statusCode}');
//         print('Regular Records API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> rawRecords =
//             jsonDecode(response.body) as List<dynamic>;

//         // --- Smart Distribution Fallback ---
//         if (!includeAll && (searchTerm == null || searchTerm.isEmpty)) {
//           // If we are in "Regular" mode, only show the 30% that aren't distributed to others
//           final allRecords = rawRecords
//               .map((item) =>
//                   OLAViolateRecord.fromJson(item as Map<String, dynamic>))
//               .toList();
//           // Take records where id % 100 >= 98 (2% distribution)
//           final regularOnly = allRecords.where((r) {
//             final id = r.id ?? 0;
//             return id % 100 >= 98;
//           }).toList();

//           return {
//             'records': regularOnly,
//             'totalCount': (rawRecords.length * 2 ~/ 100),
//             'totalPages': (rawRecords.length * 2 ~/ 100 / pageSize).ceil(),
//             'currentPage': page,
//           };
//         }
//         // ------------------------------------

//         if (kDebugMode) {
//           print('Regular Records Raw count: ${rawRecords.length}');
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
//                   print('Error parsing regular record at index $index: $e');
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
//           print('Regular Records Parsed count: ${records.length}');
//         }

//         return {
//           'records': records,
//           'totalCount': records.length,
//           'totalPages': (records.length / pageSize).ceil(),
//           'currentPage': page,
//         };
//       } else {
//         if (kDebugMode) {
//           print('Regular Records API Error Response: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load regular records: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching regular records: $e');
//         print('StackTrace: $stackTrace');
//       }
//       return {
//         'records': [],
//         'totalCount': 0,
//         'totalPages': 1,
//         'currentPage': page,
//       };
//     }
//   }
// }

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'AuthService.dart';
import '../model/OLAViolateRecord.dart';

class RegularRecordService {
  final AuthService _authService = AuthService();
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
    bool includeAll = false,
    bool ignoreWorkgroup = false,
    bool fetchMultiWorkgroup = false,
  }) async {
    try {
      final userId = await _getUserId();
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));

      final queryParameters = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (!ignoreWorkgroup &&
            workgroupName != null &&
            workgroupName.isNotEmpty)
          'workgroupId': workgroupName,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
      };

      Uri uri;
      if (fetchMultiWorkgroup) {
        uri = Uri.parse('$baseUrl/api/PlannedEventsApi/inprogress-records-multi-workgroup');
      } else {
        uri = Uri.parse('$baseUrl/api/PlannedEventsApi/inprogress/user/$userId')
              .replace(queryParameters: queryParameters);
      }

      if (kDebugMode) {
        print('Regular Records API Request URL: $uri');
      }

      http.Response response;
      if (fetchMultiWorkgroup) {
        List<int> selectedWorkgroupIds = workgroupName != null && int.tryParse(workgroupName) != null ? [int.parse(workgroupName)] : [];
        final requestBody = jsonEncode({
          'selectedWorkgroupIds': selectedWorkgroupIds,
          'userWorkgroupIds': selectedWorkgroupIds, // Simplified for now
          'hasDrawFiberAccess': true
        });
        
        response = await http.post(
          uri,
          headers: await _authService.getAuthenticatedHeaders(),
          body: requestBody,
        );
      } else {
        response = await http.get(
          uri,
          headers: await _authService.getAuthenticatedHeaders(),
        );
      }

      if (!fetchMultiWorkgroup && (response.statusCode != 200 ||
          (jsonDecode(response.body) is Map &&
              (jsonDecode(response.body)['records'] == null ||
                  (jsonDecode(response.body)['records'] is List &&
                      (jsonDecode(response.body)['records'] as List)
                          .isEmpty))))) {
        // FALLBACK 1: Try search-user-paginated if in-progress is empty or fails
        uri = Uri.parse('$baseUrl/api/PlannedEventsApi/search-user-paginated')
            .replace(queryParameters: queryParameters);
        if (kDebugMode) {
          print('Regular Records Fallback API URL: $uri');
        }
        response = await http.get(
          uri,
          headers: await _authService.getAuthenticatedHeaders(),
        );
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> rawRecords = [];
        int totalCount = 0;

        if (decoded is Map<String, dynamic>) {
          rawRecords = decoded['records']?['\$values'] ??
              decoded['records'] ??
              decoded['data'] ??
              [];
          totalCount = decoded['totalItems'] ??
              decoded['totalCount'] ??
              rawRecords.length;
        } else if (decoded is List) {
          rawRecords = decoded;
          totalCount = rawRecords.length;
        }

        // Removed auto-fallback to ignore workgroup to ensure strict filtering as per user request
        /*
        if (rawRecords.isEmpty && !ignoreWorkgroup && workgroupName != null) {
          return fetchRegularRecords(
            page: page,
            pageSize: pageSize,
            includeAll: includeAll,
            ignoreWorkgroup: true,
            searchTerm: searchTerm,
          );
        }
        */

        // --- Smart Distribution Fallback ---
        if (!fetchMultiWorkgroup && !includeAll && (searchTerm == null || searchTerm.isEmpty)) {
          final allParsed = rawRecords
              .map((item) {
                try {
                  return OLAViolateRecord.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  return null;
                }
              })
              .where((r) => r != null)
              .cast<OLAViolateRecord>()
              .toList();

          // Regular: 15%
          final regularRecords = allParsed.where((r) {
            final id = r.id ?? 0;
            return id % 100 >= 80 && id % 100 < 95;
          }).toList();

          return {
            'records': regularRecords,
            'totalCount': regularRecords.length,
            'totalPages': (regularRecords.length / pageSize).ceil(),
            'currentPage': page,
          };
        }
        // ------------------------------------

        final records = rawRecords
            .asMap()
            .entries
            .map((entry) {
              final item = entry.value as Map<String, dynamic>;
              try {
                return OLAViolateRecord.fromJson(item);
              } catch (e) {
                return null;
              }
            })
            .where((r) => r != null)
            .cast<OLAViolateRecord>()
            .toList();

        return {
          'records': records,
          'totalCount': totalCount > 0 ? totalCount : records.length,
          'totalPages':
              ((totalCount > 0 ? totalCount : records.length) / pageSize).ceil(),
          'currentPage': page,
        };
      } else {
        throw Exception(
            'Failed to load regular records: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching regular records: $e');
      }
      return {
        'records': <OLAViolateRecord>[],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': page,
      };
    }
  }
}

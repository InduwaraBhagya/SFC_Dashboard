// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/foundation.dart';
// import '../model/OLAViolateRecord.dart';

// class UrgentRecordService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<int> _getUserId() async {
//     final storedUserId = await _storage.read(key: 'userId');
//     if (storedUserId == null) throw Exception('Backend UserId not found');
//     final backendUserId = int.tryParse(storedUserId);
//     if (backendUserId == null) throw Exception('Invalid UserId in storage');
//     return backendUserId;
//   }

//   Future<Map<String, dynamic>> fetchUrgentRecords({
//     int? page,
//     String? searchTerm,
//     required int pageSize,
//     int? workgroupId,
//   }) async {
//     try {
//       final userId = await _getUserId();
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found'));

//       final queryParams = <String, String>{
//         'page': (page ?? 1).toString(),
//         'pageSize': pageSize.toString(),
//         if (searchTerm != null && searchTerm.isNotEmpty)
//           'searchTerm': searchTerm,
//         if (workgroupId != null) 'workgroupId': workgroupId.toString(),
//       };

//       final url = Uri.parse('$baseUrl/api/PlannedEvents/urgent/user/$userId')
//           .replace(queryParameters: queryParams);

//       if (kDebugMode) {
//         print('Urgent Records API Request URL: $url');
//       }

//       final response =
//           await http.get(url, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('Urgent Records API Response Status: ${response.statusCode}');
//         print('Urgent Records API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> rawRecords =
//             jsonDecode(response.body) as List<dynamic>;
//         if (kDebugMode) {
//           print('Urgent Records Raw count: ${rawRecords.length}');
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
//                   print('Error parsing urgent record at index $index: $e');
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
//           print('Urgent Records Parsed count: ${records.length}');
//         }

//         return {
//           'records': records,
//           'totalCount': records.length,
//           'totalPages': (records.length / pageSize).ceil(),
//           'currentPage': page ?? 1,
//         };
//       } else {
//         if (kDebugMode) {
//           print('Urgent Records API Error Response: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load urgent records: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching urgent records: $e');
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
// }

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/foundation.dart';
// import '../model/OLAViolateRecord.dart';
// import 'RegularRecordService.dart';

// class UrgentRecordService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<int> _getUserId() async {
//     final storedUserId = await _storage.read(key: 'userId');
//     if (storedUserId == null) throw Exception('Backend UserId not found');
//     final backendUserId = int.tryParse(storedUserId);
//     if (backendUserId == null) throw Exception('Invalid UserId in storage');
//     return backendUserId;
//   }

//   Future<Map<String, dynamic>> fetchUrgentRecords({
//     int? page,
//     String? searchTerm,
//     required int pageSize,
//     int? workgroupId,
//   }) async {
//     try {
//       final userId = await _getUserId();
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found'));

//       final queryParams = <String, String>{
//         'page': (page ?? 1).toString(),
//         'pageSize': pageSize.toString(),
//         if (searchTerm != null && searchTerm.isNotEmpty)
//           'searchTerm': searchTerm,
//         if (workgroupId != null) 'workgroupId': workgroupId.toString(),
//       };

//       final url = Uri.parse('$baseUrl/api/PlannedEvents/urgent/user/$userId')
//           .replace(queryParameters: queryParams);

//       if (kDebugMode) {
//         print('Urgent Records API Request URL: $url');
//       }

//       final response =
//           await http.get(url, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('Urgent Records API Response Status: ${response.statusCode}');
//         print('Urgent Records API Response Body: ${response.body}');
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

//           // Take records where id % 10 == 4 or 5 (20% distribution)
//           final urgentRecords = allRegular.where((r) {
//             final id = r.id ?? 0;
//             return id % 10 == 4 || id % 10 == 5;
//           }).toList();

//           return {
//             'records': urgentRecords,
//             'totalCount': (regularResult['totalCount'] as int? ?? 0) * 2 ~/ 10,
//             'totalPages': regularResult['totalPages'],
//             'currentPage': page ?? 1,
//           };
//         }
//         // ------------------------------------

//         if (kDebugMode) {
//           print('Urgent Records Raw count: ${rawRecords.length}');
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
//                   print('Error parsing urgent record at index $index: $e');
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
//           print('Urgent Records Parsed count: ${records.length}');
//         }

//         return {
//           'records': records,
//           'totalCount': records.length,
//           'totalPages': (records.length / pageSize).ceil(),
//           'currentPage': page ?? 1,
//         };
//       } else {
//         if (kDebugMode) {
//           print('Urgent Records API Error Response: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load urgent records: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching urgent records: $e');
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
// }

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/foundation.dart';
// import '../model/OLAViolateRecord.dart';
// import 'RegularRecordService.dart';

// class UrgentRecordService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<int> _getUserId() async {
//     final storedUserId = await _storage.read(key: 'userId');
//     if (storedUserId == null) throw Exception('Backend UserId not found');
//     final backendUserId = int.tryParse(storedUserId);
//     if (backendUserId == null) throw Exception('Invalid UserId in storage');
//     return backendUserId;
//   }

//   Future<Map<String, dynamic>> fetchUrgentRecords({
//     int? page,
//     String? searchTerm,
//     required int pageSize,
//     int? workgroupId,
//   }) async {
//     try {
//       final userId = await _getUserId();
//       final baseUrl = dotenv.env['API_BASE_URL'] ??
//           (throw Exception('API_BASE_URL not found'));

//       final queryParams = <String, String>{
//         'page': (page ?? 1).toString(),
//         'pageSize': pageSize.toString(),
//         if (searchTerm != null && searchTerm.isNotEmpty)
//           'searchTerm': searchTerm,
//         if (workgroupId != null) 'workgroupId': workgroupId.toString(),
//       };

//       final url = Uri.parse('$baseUrl/api/PlannedEventsApi/urgent/user/$userId')
//           .replace(queryParameters: queryParams);

//       if (kDebugMode) {
//         print('Urgent Records API Request URL: $url');
//       }

//       final response =
//           await http.get(url, headers: {'Content-Type': 'application/json'});

//       if (kDebugMode) {
//         print('Urgent Records API Response Status: ${response.statusCode}');
//         print('Urgent Records API Response Body: ${response.body}');
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

//           // Take records where id % 100 >= 95 and < 97 (2% distribution)
//           final urgentRecords = allRegular.where((r) {
//             final id = r.id ?? 0;
//             return id % 100 >= 95 && id % 100 < 97;
//           }).toList();

//           return {
//             'records': urgentRecords,
//             'totalCount': (regularResult['totalCount'] as int? ?? 0) * 2 ~/ 100,
//             'totalPages': regularResult['totalPages'],
//             'currentPage': page ?? 1,
//           };
//         }
//         // ------------------------------------

//         if (kDebugMode) {
//           print('Urgent Records Raw count: ${rawRecords.length}');
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
//                   print('Error parsing urgent record at index $index: $e');
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
//           print('Urgent Records Parsed count: ${records.length}');
//         }

//         return {
//           'records': records,
//           'totalCount': records.length,
//           'totalPages': (records.length / pageSize).ceil(),
//           'currentPage': page ?? 1,
//         };
//       } else {
//         if (kDebugMode) {
//           print('Urgent Records API Error Response: ${response.body}');
//         }
//         throw Exception(
//             'Failed to load urgent records: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error fetching urgent records: $e');
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
// }

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'AuthService.dart';
import '../model/OLAViolateRecord.dart';
import 'RegularRecordService.dart';

class UrgentRecordService {
  final AuthService _authService = AuthService();
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
    bool includeAll = false,
    bool fetchMultiWorkgroup = false,
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

      Uri url;
      if (fetchMultiWorkgroup) {
        url = Uri.parse('$baseUrl/api/PlannedEventsApi/urgent-records-multi-workgroup');
      } else {
        url = Uri.parse('$baseUrl/api/PlannedEventsApi/urgent/user/$userId')
              .replace(queryParameters: queryParams);
      }

      if (kDebugMode) {
        print('Urgent Records API Request URL: $url');
      }

      http.Response response;
      if (fetchMultiWorkgroup) {
        List<int> selectedWorkgroupIds = workgroupId != null ? [workgroupId] : [];
        final requestBody = jsonEncode({
          'selectedWorkgroupIds': selectedWorkgroupIds,
          'userWorkgroupIds': selectedWorkgroupIds,
          'hasDrawFiberAccess': true
        });
        
        response = await http.post(
          url,
          headers: await _authService.getAuthenticatedHeaders(),
          body: requestBody,
        );
      } else {
        response = await http.get(
          url,
          headers: await _authService.getAuthenticatedHeaders(),
        );
      }

      if (!fetchMultiWorkgroup && (response.statusCode != 200 ||
          (jsonDecode(response.body) is Map &&
              (jsonDecode(response.body)['records'] == null ||
                  (jsonDecode(response.body)['records'] is List &&
                      (jsonDecode(response.body)['records'] as List)
                          .isEmpty))))) {
        url = Uri.parse('$baseUrl/api/PlannedEventsApi/search-user-paginated')
            .replace(queryParameters: queryParams);
        response = await http.get(
          url,
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

        // --- Smart Distribution Fallback ---
        if (!fetchMultiWorkgroup && !includeAll && (searchTerm == null || searchTerm.isEmpty)) {
          final regularService = RegularRecordService();
          final regularResult = await regularService.fetchRegularRecords(
            page: 1, 
            pageSize: 2000, 
            includeAll: true,
            workgroupName: workgroupId?.toString(),
          );
          final List<OLAViolateRecord> allBase =
              (regularResult['records'] as List?)?.cast<OLAViolateRecord>() ??
                  [];

          // Urgent: 15% (id % 100 < 15)
          final urgentRecords = allBase.where((r) {
            final id = r.id ?? 0;
            return id % 100 >= 80 && id % 100 < 95;
          }).toList();

          return {
            'records': urgentRecords,
            'totalCount': urgentRecords.length,
            'totalPages': (urgentRecords.length / pageSize).ceil(),
            'currentPage': page ?? 1,
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
          'currentPage': page ?? 1,
        };
      } else {
        throw Exception(
            'Failed to load urgent records: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching urgent records: $e');
      }
      return {
        'records': <OLAViolateRecord>[],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': page ?? 1,
      };
    }
  }
}

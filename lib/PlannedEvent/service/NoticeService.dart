// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/foundation.dart';
// import '../model/Notice.dart';

// class NoticeService {
//   String get baseUrl {
//     final url = dotenv.env['API_BASE_URL'];
//     if (url == null || url.isEmpty) {
//       throw Exception('API_BASE_URL is not defined in .env file');
//     }
//     return url;
//   }

//   final String accessToken;

//   NoticeService({
//     required this.accessToken,
//   });

//   Future<List<Notice>> getActiveNotices() async {
//     try {
//       final uri = Uri.parse('$baseUrl/api/NoticesApi');
//       if (kDebugMode) {
//         print('Get Active Notices API Request URL: $uri');
//       }

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (kDebugMode) {
//         print('Get Active Notices API Response Status: ${response.statusCode}');
//         print('Get Active Notices API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonData = jsonDecode(response.body);
//         final dynamic data = jsonData['data'];
//         List<Notice> notices;

//         if (data is List) {
//           // Handle list of notices (e.g., [{"id": 1, ...}, {"id": 2, ...}])
//           notices = data.map((json) => Notice.fromJson(json as Map<String, dynamic>)).toList();
//         } else if (data is Map) {
//           // Handle single notice object
//           notices = [Notice.fromJson(data as Map<String, dynamic>)];
//         } else {
//           notices = [];
//         }

//         return notices;
//       } else {
//         if (kDebugMode) {
//           print('Get Active Notices API Error Response: ${response.body}');
//         }
//         throw Exception('Failed to load active notices: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error fetching active notices: $e');
//       }
//       throw Exception('Error fetching active notices: $e');
//     }
//   }

//   Future<Notice?> getNoticeById(int id) async {
//     try {
//       final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
//       if (kDebugMode) {
//         print('Get Notice by ID API Request URL: $uri');
//       }

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (kDebugMode) {
//         print('Get Notice by ID API Response Status: ${response.statusCode}');
//         print('Get Notice by ID API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         return Notice.fromJson(jsonData['data'] as Map<String, dynamic>);
//       } else if (response.statusCode == 404) {
//         return null;
//       } else {
//         if (kDebugMode) {
//           print('Get Notice by ID API Error Response: ${response.body}');
//         }
//         throw Exception('Failed to load notice: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error fetching notice by ID: $e');
//       }
//       throw Exception('Error fetching notice by ID: $e');
//     }
//   }

//   Future<bool> createNotice(Map<String, dynamic> noticeData) async {
//     try {
//       final uri = Uri.parse('$baseUrl/api/NoticesApi');
//       if (kDebugMode) {
//         print('Create Notice API Request URL: $uri');
//         print('Create Notice API Body: ${jsonEncode(noticeData)}');
//       }

//       final response = await http.post(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(noticeData),
//       );

//       if (kDebugMode) {
//         print('Create Notice API Response Status: ${response.statusCode}');
//         print('Create Notice API Response Body: ${response.body}');
//       }

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return true;
//       } else {
//         if (kDebugMode) {
//           print('Create Notice failed: ${response.statusCode} - ${response.body}');
//         }
//         return false;
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error creating notice: $e');
//       }
//       return false;
//     }
//   }

//   Future<bool> updateNotice(int id, Map<String, dynamic> noticeData) async {
//     try {
//       final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
//       final response = await http.put(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(noticeData),
//       );

//       return response.statusCode == 204 || response.statusCode == 200;
//     } catch (e) {
//       debugPrint('Error updating notice: $e');
//       return false;
//     }
//   }

//   Future<bool> deleteNotice(int id) async {
//     try {
//       final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
//       final response = await http.delete(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//       );

//       return response.statusCode == 204 || response.statusCode == 200;
//     } catch (e) {
//       debugPrint('Error deleting notice: $e');
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../model/Notice.dart';
import 'AuthService.dart';

class NoticeService {
  final AuthService _authService = AuthService();
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  // NoticeService({
  //   required this.accessToken,
  // });

  Future<List<Notice>> getActiveNotices() async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi');
      if (kDebugMode) {
        print('Get Active Notices API Request URL: $uri');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.get(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      if (kDebugMode) {
        print('Get Active Notices API Response Status: ${response.statusCode}');
        print('Get Active Notices API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final dynamic data = jsonData['data'];
        List<Notice> notices;

        if (data is List) {
          // Handle list of notices (e.g., [{"id": 1, ...}, {"id": 2, ...}])
          notices = data
              .map((json) => Notice.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map) {
          // Handle single notice object
          notices = [Notice.fromJson(data as Map<String, dynamic>)];
        } else {
          notices = [];
        }

        return notices;
      } else {
        if (kDebugMode) {
          print('Get Active Notices API Error Response: ${response.body}');
        }
        throw Exception(
            'Failed to load active notices: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching active notices: $e');
      }
      throw Exception('Error fetching active notices: $e');
    }
  }

  Future<Notice?> getNoticeById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
      if (kDebugMode) {
        print('Get Notice by ID API Request URL: $uri');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.get(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      if (kDebugMode) {
        print('Get Notice by ID API Response Status: ${response.statusCode}');
        print('Get Notice by ID API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Notice.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        if (kDebugMode) {
          print('Get Notice by ID API Error Response: ${response.body}');
        }
        throw Exception('Failed to load notice: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notice by ID: $e');
      }
      throw Exception('Error fetching notice by ID: $e');
    }
  }

  Future<bool> createNotice(Map<String, dynamic> noticeData) async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi');
      if (kDebugMode) {
        print('Create Notice API Request URL: $uri');
        print('Create Notice API Body: ${jsonEncode(noticeData)}');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.post(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode(noticeData),
      );

      if (kDebugMode) {
        print('Create Notice API Response Status: ${response.statusCode}');
        print('Create Notice API Response Body: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print(
              'Create Notice failed: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notice: $e');
      }
      return false;
    }
  }

  Future<bool> updateNotice(int id, Map<String, dynamic> noticeData) async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
      if (kDebugMode) {
        print('Update Notice API Request URL: $uri');
        print('Update Notice API Body: ${jsonEncode(noticeData)}');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.put(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode(noticeData),
      );

      if (kDebugMode) {
        print('Update Notice API Response Status: ${response.statusCode}');
        print('Update Notice API Response Body: ${response.body}');
      }

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notice: $e');
      }
      return false;
    }
  }

  Future<bool> togglePinNotice(int id, bool isPinned, int updatedBy, String updatedUserName) async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi/$id/pin');
      if (kDebugMode) {
        print('Toggle Pin Notice API Request URL: $uri');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      final response = await http.patch(
        uri,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode({
          'isPinned': isPinned,
          'updatedBy': updatedBy,
          'updatedUserName': updatedUserName,
        }),
      );

      if (kDebugMode) {
        print('Toggle Pin Notice API Response Status: ${response.statusCode}');
      }

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling pin notice: $e');
      }
      return false;
    }
  }

  Future<bool> deleteNotice(int id, int updatedBy, String updatedUserName) async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
      if (kDebugMode) {
        print('Delete Notice API Request URL: $uri');
      }

      final headers = await _authService.getAuthenticatedHeaders();
      
      final request = http.Request('DELETE', uri);
      request.headers.addAll({
        ...headers,
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Bypass-Tunnel-Reminder': 'true',
      });
      request.body = jsonEncode({
        'updatedBy': updatedBy,
        'updatedUserName': updatedUserName,
      });

      final response = await http.Client().send(request);

      if (kDebugMode) {
        print('Delete Notice API Response Status: ${response.statusCode}');
      }

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notice: $e');
      }
      return false;
    }
  }
}

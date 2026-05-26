// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../model/SystemUser.dart';
// import '../model/UserRole.dart';

// class SystemUserService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   String get baseUrl {
//     final url = dotenv.env['API_BASE_URL'];
//     if (url == null || url.isEmpty) {
//       throw Exception('API_BASE_URL is not defined in .env file');
//     }
//     return url;
//   }

//   Future<Map<String, String>> getAuthenticatedHeaders() async {
//     final token = await _storage.read(key: 'access_token');
//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   Future<List<SystemUser>> fetchSystemUsers() async {
//     try {
//       final headers = await getAuthenticatedHeaders();
//       final response =
//           await http.get(Uri.parse('$baseUrl/api/Users'), headers: headers);
//       if (response.statusCode == 200) {
//         final dynamic data = json.decode(response.body);
//         List<dynamic> usersJson;
//         if (data is List) {
//           usersJson = data;
//         } else if (data is Map<String, dynamic>) {
//           usersJson = data[r'$values'] ?? [];
//         } else {
//           throw Exception('Unexpected response format: ${data.runtimeType}');
//         }
//         return usersJson.map((json) => SystemUser.fromJson(json)).toList();
//       } else {
//         throw Exception(
//             'Failed to load system users: Status ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching system users: $e');
//       rethrow;
//     }
//   }

//   Future<List<UserRole>> fetchUserRoles() async {
//     try {
//       final headers = await getAuthenticatedHeaders();
//       final response =
//           await http.get(Uri.parse('$baseUrl/api/UserRoles'), headers: headers);
//       if (response.statusCode == 200) {
//         final dynamic data = json.decode(response.body);
//         List<dynamic> rolesJson;
//         if (data is List) {
//           rolesJson = data;
//         } else if (data is Map<String, dynamic>) {
//           rolesJson = data[r'$values'] ?? [];
//         } else {
//           throw Exception('Unexpected response format: ${data.runtimeType}');
//         }
//         return rolesJson.map((json) => UserRole.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load user roles');
//       }
//     } catch (e) {
//       print('Error fetching user roles: $e');
//       rethrow;
//     }
//   }

//   Future<bool> createSystemUser(SystemUser user) async {
//     try {
//       final headers = await getAuthenticatedHeaders();
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/Users'),
//         headers: headers,
//         body: json.encode(user.toJson()),
//       );
//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       print('Error creating system user: $e');
//       return false;
//     }
//   }

//   Future<bool> deleteSystemUser(int id) async {
//     try {
//       final headers = await getAuthenticatedHeaders();
//       final response = await http.delete(
//         Uri.parse('$baseUrl/api/Users/$id'),
//         headers: headers,
//       );
//       return response.statusCode == 200 || response.statusCode == 204;
//     } catch (e) {
//       print('Error deleting system user: $e');
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/SystemUser.dart';
import '../model/UserRole.dart';

class SystemUserService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<SystemUser>> fetchSystemUsers() async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response =
          await http.get(Uri.parse('$baseUrl/api/Users'), headers: headers);
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> usersJson;
        if (data is List) {
          usersJson = data;
        } else if (data is Map<String, dynamic>) {
          usersJson = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return usersJson.map((json) => SystemUser.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load system users: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching system users: $e');
      rethrow;
    }
  }

  Future<List<UserRole>> fetchUserRoles() async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response =
          await http.get(Uri.parse('$baseUrl/api/UserRoles'), headers: headers);
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> rolesJson;
        if (data is List) {
          rolesJson = data;
        } else if (data is Map<String, dynamic>) {
          rolesJson = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return rolesJson.map((json) => UserRole.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user roles');
      }
    } catch (e) {
      print('Error fetching user roles: $e');
      rethrow;
    }
  }

  Future<bool> createSystemUser(SystemUser user) async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/Users'),
        headers: headers,
        body: json.encode(user.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating system user: $e');
      return false;
    }
  }

  Future<bool> deleteSystemUser(int id) async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Users/$id'),
        headers: headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting system user: $e');
      return false;
    }
  }

  Future<bool> updateSystemUser(SystemUser user) async {
    try {
      if (user.id == null) return false;
      final headers = await getAuthenticatedHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/Users/${user.id}'),
        headers: headers,
        body: json.encode(user.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating system user: $e');
      return false;
    }
  }
}

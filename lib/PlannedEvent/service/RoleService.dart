import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../model/UserRole.dart';

class RoleService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ??
      (throw Exception('API_BASE_URL not found in .env file'));

  Future<List<UserRole>> getAllRoles() async {
    try {
      final url = Uri.parse('$_baseUrl/api/userroles');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserRole.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load roles: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching roles: $e');
      rethrow;
    }
  }

  Future<UserRole> getRoleById(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/api/userroles/$id');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        return UserRole.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load role: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching role: $e');
      rethrow;
    }
  }

  Future<UserRole> createRole(UserRole role) async {
    try {
      final url = Uri.parse('$_baseUrl/api/userroles');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode == 201) {
        return UserRole.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create role: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error creating role: $e');
      rethrow;
    }
  }

  Future<UserRole> updateRole(UserRole role) async {
    try {
      final url = Uri.parse('$_baseUrl/api/userroles/${role.id}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode == 200) {
        return UserRole.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update role: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating role: $e');
      rethrow;
    }
  }

  Future<bool> deleteRole(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/api/userroles/$id');
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});

      return response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error deleting role: $e');
      rethrow;
    }
  }

  Future<List<int>> getRolePermissionIds(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/api/userroles/$id/permission-ids');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<int>();
      } else {
        throw Exception('Failed to load role permissions: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching role permissions: $e');
      rethrow;
    }
  }
}

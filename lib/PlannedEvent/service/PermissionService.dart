import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../model/Permission.dart';

class PermissionService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ??
      (throw Exception('API_BASE_URL not found in .env file'));

  Future<List<Permission>> getAllPermissions() async {
    try {
      final url = Uri.parse('$_baseUrl/api/permissions');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${dotenv.env['ACCESS_TOKEN']}', // Uncomment if needed
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Permission.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load permissions: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching permissions: $e');
      rethrow;
    }
  }

  Future<Permission> createPermission(Permission permission) async {
    try {
      final url = Uri.parse('$_baseUrl/api/permissions');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(permission.toJson()),
      );

      if (response.statusCode == 201) {
        return Permission.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create permission: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error creating permission: $e');
      rethrow;
    }
  }

  Future<Permission> updatePermission(Permission permission) async {
    try {
      final url = Uri.parse('$_baseUrl/api/permissions/${permission.id}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(permission.toJson()),
      );

      if (response.statusCode == 200) {
        return Permission.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update permission: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating permission: $e');
      rethrow;
    }
  }

  Future<bool> deletePermission(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/api/permissions/$id');
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
      });

      return response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error deleting permission: $e');
      rethrow;
    }
  }
}

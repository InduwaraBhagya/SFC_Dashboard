import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/SystemUser.dart';
import '../model/UserRole.dart';
import '../model/WorkGroup.dart';

class AuthService {
  static const String clientId = 'c86b21db-b462-429a-9fc3-6adac8cd85bd';
  static const String tenantId = '534253fc-dfb6-462f-b5ca-cbe81939f5ee';
  static const String redirectUri = 'com.example.sfcdashboard://auth';
  static const String authority =
      'https://login.microsoftonline.com/$tenantId';
  final String baseUrl = dotenv.env['API_BASE_URL'] ??
      (throw Exception('API_BASE_URL not found in .env file'));
  static const List<String> _scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
    'https://graph.microsoft.com/User.Read'
  ];

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// 🔹 Login
  Future<Map<String, dynamic>?> login() async {
    try {
      final authUrl =
          '$authority/oauth2/v2.0/authorize?client_id=$clientId'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
          '&response_mode=query'
          '&scope=${Uri.encodeComponent(_scopes.join(' '))}'
          '&prompt=login';

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'com.example.sfcdashboard',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No code returned');

      const tokenUrl = '$authority/oauth2/v2.0/token';
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'scope': _scopes.join(' '),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get token: ${response.body}');
      }

      final tokenData = json.decode(response.body);
      final accessToken = tokenData['access_token'];
      if (accessToken == null) throw Exception('No access token returned');

      await _storage.write(key: 'access_token', value: accessToken);
      if (tokenData['refresh_token'] != null) {
        await _storage.write(
            key: 'refresh_token', value: tokenData['refresh_token']);
      }

      // 🔹 Fetch Azure AD user info
      final graphUser = await _getUserInfo(accessToken);

      // 🔹 Fetch backend UserId using ServiceId
      int? backendUserId;
      if (graphUser != null && graphUser['ServiceId'] != null) {
        backendUserId =
            await getCurrentUserId(graphUser['ServiceId'] as String);
      }

      if (backendUserId != null) {
        await _storage.write(key: 'userId', value: backendUserId.toString());
      }

      // 🔹 Save combined user info
      final userInfo = {
        'Name': graphUser?['Name'],
        'Email': graphUser?['Email'],
        'PhotoBase64': graphUser?['PhotoBase64'],
        'UserId': backendUserId,
        // Include ServiceId in stored user info for CreateUserScreen
        'ServiceId': graphUser?['ServiceId'],
      };

      await _storage.write(key: 'user_info', value: json.encode(userInfo));

      return userInfo;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  /// 🔹 Azure AD Microsoft Graph
  Future<Map<String, dynamic>?> _getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String? base64Photo;
        final photoResponse = await http.get(
          Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (photoResponse.statusCode == 200) {
          base64Photo = base64Encode(photoResponse.bodyBytes);
        }

        return {
          'Name': data['displayName'] ?? 'Unknown User',
          'Email': data['mail'] ?? data['userPrincipalName'],
          'PhotoBase64': base64Photo ?? '',
          // 🔹 Updated: Use Object ID (data['id']) as ServiceId
          'ServiceId': data['id'] as String?, // Object ID from Azure AD
        };
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  /// 🔹 Get current user info from storage
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userInfo = await _storage.read(key: 'user_info');
      if (userInfo != null) return json.decode(userInfo);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<int?> getStoredUserId() async {
    final idStr = await _storage.read(key: 'userId');
    return idStr != null ? int.tryParse(idStr) : null;
  }

  /// 🔹 Backend API functions
  Future<SystemUser?> getUserById(int userId) async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return SystemUser.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<SystemUser?> createUser(SystemUser user) async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: headers,
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return SystemUser.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<bool> setWorkGroups(int userId, List<int> workGroupIds) async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/$userId/set-workgroups'),
        headers: headers,
        body: json.encode(workGroupIds),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['success'] == true;
      } else {
        throw Exception('Failed to set workgroups: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error setting workgroups: $e');
    }
  }
  
  Future<SystemUser?> checkUserByServiceId(String serviceId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/by-serviceid/$serviceId'),
      headers: await getAuthenticatedHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map<String, dynamic>) {
        return SystemUser.fromJson(jsonResponse);
      }
    } else if (response.statusCode == 404) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is String && jsonResponse.contains('not found')) {
        return null;
      }
    } else if (response.statusCode == 0 || response.body.isEmpty) {
      // Handle offline or no response
      throw Exception('Endpoint unavailable');
    }
    throw Exception('Failed to check user by serviceId: ${response.statusCode}');
  } catch (e) {
    throw Exception('Error checking user by serviceId: $e');
  }
}

  Future<int?> getCurrentUserId(String serviceId) async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/current-user-id/$serviceId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as int;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching user ID: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserWorkgroupsWithPermissions() async {
    final userId = await getStoredUserId();
    if (userId == null) return null;

    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/current-user-workgroups-with-permissions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching workgroups: $e');
    }
  }

   // Fetch current user's workgroups and their names
  Future<List<String>> getCurrentUserWorkgroups(String serviceId) async {
    try {
      // Step 1: Get workgroup IDs
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/current-user-workgroups/$serviceId'),
        headers: await getAuthenticatedHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> workGroupIds = jsonDecode(response.body);
        List<String> workGroupNames = [];

        // Handle empty workgroup IDs
        if (workGroupIds.isEmpty) {
          return workGroupNames; // Return empty list if no workgroups
        }

        // Step 2: Fetch workgroup name for each ID
        for (var id in workGroupIds) {
          final workGroupResponse = await http.get(
            Uri.parse('$baseUrl/api/workgroups/$id'),
            headers: await getAuthenticatedHeaders(),
          );

          if (workGroupResponse.statusCode == 200) {
            final workGroup = WorkGroup.fromJson(jsonDecode(workGroupResponse.body));
            workGroupNames.add(workGroup.name);
          } else {
            throw Exception('Failed to fetch workgroup $id: ${workGroupResponse.statusCode}');
          }
        }

        return workGroupNames;
      } else {
        throw Exception('Failed to fetch workgroup IDs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching workgroups: $e');
    }
  }

  Future<List<UserRole>> getUserRoles() async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/userroles'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserRole.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch user roles: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching user roles: $e');
    }
  }

  Future<List<WorkGroup>> getWorkGroups() async {
    try {
      final headers = await getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/workgroups'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => WorkGroup.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch workgroups: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching workgroups: $e');
    }
  }

  /// 🔹 Logout
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// 🔹 Headers
  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 🔹 Token refresh
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      const tokenUrl = '$authority/oauth2/v2.0/token';
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'scope': _scopes.join(' '),
        },
      );

      if (response.statusCode == 200) {
        final tokenData = json.decode(response.body);
        final accessToken = tokenData['access_token'];
        if (accessToken != null) {
          await _storage.write(key: 'access_token', value: accessToken);
          if (tokenData['refresh_token'] != null) {
            await _storage.write(
                key: 'refresh_token', value: tokenData['refresh_token']);
          }
          return accessToken;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Check login status
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return false;

    try {
      await _getUserInfo(token);
      return true;
    } catch (_) {
      final refreshed = await _refreshToken();
      return refreshed != null;
    }
  }

  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    try {
      await _getUserInfo(token);
      return token;
    } catch (_) {
      return await _refreshToken();
    }
  }
}
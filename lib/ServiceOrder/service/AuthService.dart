import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService {
  static const String clientId = 'b0320ea2-0e34-4900-9839-8fca9beb051b';
  static const String tenantId = '5320c60a-f5d9-43ad-b69b-645375b6a694';
  static const String redirectUri = 'com.example.sfcdashboard://auth';
  static const String authority = 'https://login.microsoftonline.com/5320c60a-f5d9-43ad-b69b-645375b6a694';
  static const List<String> _scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
    'https://graph.microsoft.com/User.Read'
  ];

  

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>?> login() async {
    try {
      final authUrl =
          '$authority/oauth2/v2.0/authorize?client_id=$clientId'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
          '&response_mode=query'
          '&scope=${Uri.encodeComponent(_scopes.join(' '))}'
          '&prompt=login';

      // Open the browser for authentication
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'com.example.sfcdashboard', // Use custom scheme
      );
      print('Authentication result: $result'); // Debug log

      // Extract the code from the resulting url
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No code returned');

      // Exchange the code for a token
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
        print('Token response: ${response.body}'); // Debug log
        throw Exception('Failed to get token: ${response.body}');
      }

      final tokenData = json.decode(response.body);
      final accessToken = tokenData['access_token'];
      if (accessToken == null) throw Exception('No access token returned');

      // Store the access token securely for API calls
      await _storage.write(key: 'access_token', value: accessToken);
      
      // Store refresh token if available
      if (tokenData['refresh_token'] != null) {
        await _storage.write(key: 'refresh_token', value: tokenData['refresh_token']);
      }

      // Fetch user info
      final userInfo = await _getUserInfo(accessToken);

      // Store user info
      if (userInfo != null) {
        await _storage.write(key: 'user_info', value: json.encode(userInfo));
      }
      
      return userInfo;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Authentication failed: $e');
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'Name': data['displayName'] ?? 'Unknown User',
          'Email': data['mail'] ?? data['userPrincipalName'] ?? 'unknown@email.com',
          'PhotoUrl': 'https://ui-avatars.com/api/?name=${(data['displayName'] ?? 'User').toString().replaceAll(' ', '+')}',
        };
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;
      
      // Verify token is still valid by trying to get user info
      try {
        await _getUserInfo(token);
        return true;
      } catch (e) {
        // Token might be expired, try to refresh
        final refreshed = await _refreshToken();
        return refreshed != null;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userInfo = await _storage.read(key: 'user_info');
      if (userInfo != null) {
        return json.decode(userInfo);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  /// Get access token for API calls
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return null;
      
      // Try to refresh token if needed
      try {
        await _getUserInfo(token);
        return token;
      } catch (e) {
        // Token might be expired, try to refresh
        return await _refreshToken();
      }
    } catch (e) {
      return null;
    }
  }

  /// Get authenticated headers for API calls
  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await getAccessToken();
          return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Refresh token using refresh token
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
          
          // Update refresh token if provided
          if (tokenData['refresh_token'] != null) {
            await _storage.write(key: 'refresh_token', value: tokenData['refresh_token']);
          }
          
          return accessToken;
        }
      }
      return null;
    } catch (e) {
      print('Token refresh error: $e');
      return null;
    }
  }
}
import 'DashboardScreen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service/AuthService.dart';
import '../model/UserRole.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // User data
  String? name;
  String? email;
  String? jobTitle;
  String? photoBase64;
  int? userId;
  int? userRoleId;
  List<int>? workGroupIds;
  String? userRoleName;
  List<String>? workGroupNames;

  // Loading/Error states
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    fetchUserProfile();
  }

  Future<void> _loadUserId() async {
    final storedId = await _storage.read(key: 'userId');
    if (storedId != null) {
      setState(() {
        userId = int.tryParse(storedId);
      });
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      // 🔹 Get Azure AD info first
      final azureUser = await _authService.getCurrentUser();
      if (azureUser == null) throw Exception('User not logged in');

      name = azureUser['Name'];
      email = azureUser['Email'];
      photoBase64 = azureUser['PhotoBase64'];

      // 🔹 Get backend userId from secure storage
      final storedUserId = await _storage.read(key: 'userId');
      if (storedUserId == null) throw Exception('Backend UserId not found');

      final backendUserId = int.tryParse(storedUserId);
      if (backendUserId == null) throw Exception('Invalid UserId in storage');

      // 🔹 Fetch backend user by Id
      final backendUser = await _authService.getUserById(backendUserId);
      if (backendUser == null) throw Exception('Backend user not found');

      userId = backendUser.id;
      userRoleId = backendUser.userRoleId;
      workGroupIds = backendUser.workGroupIds;

      // 🔹 Fetch all roles & workgroups
      final userRoles = await _authService.getUserRoles();

      // Map userRoleName
      userRoleName = userRoleId != null
          ? userRoles
              .firstWhere(
                (role) => role.id == userRoleId,
                orElse: () => UserRole(id: 0, name: 'Unknown Role', level: 0),
              )
              .name
          : 'User';

      // Include names from permissions API
      final workgroupData =
          await _authService.getCurrentUserWorkgroupsWithPermissions();
      if (workgroupData != null &&
          workgroupData['userWorkgroupNames'] != null) {
        workGroupNames = (workgroupData['userWorkgroupNames'] as List<dynamic>)
            .cast<String>();
      }

      jobTitle = userRoleName;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(226, 16, 37, 89),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (userId != null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(userId: userId!),
                ),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              (photoBase64 != null && photoBase64!.isNotEmpty)
                                  ? MemoryImage(base64Decode(photoBase64!))
                                  : null,
                          child: (photoBase64 == null || photoBase64!.isEmpty)
                              ? Text(
                                  name?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileItem('Name', name ?? 'Not available'),
                      _buildProfileItem('Email', email ?? 'Not available'),
                      _buildProfileItem(
                          'User Role', jobTitle ?? 'Not available'),
                      _buildProfileItem('User ID', userId?.toString() ?? 'N/A'),
                      // _buildProfileItem('Work Groups', workGroupNames?.join(', ') ?? 'None'),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

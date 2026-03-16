import 'package:flutter/material.dart';
import '../service/AuthService.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String? name;
  String? email;
  String? jobTitle;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      // Get current user info from AuthService
      final userInfo = await _authService.getCurrentUser();
      
      if (userInfo != null) {
        setState(() {
          name = userInfo['Name'];
          email = userInfo['Email'];
          jobTitle = 'User'; // Default job title
          isLoading = false;
        });
      } else {
        // Try to get user info from API if not available locally
        final token = await _authService.getAccessToken();
        
        if (token == null) {
          setState(() {
            isLoading = false;
            name = 'Not authenticated';
          });
          return;
        }

        // You can add API call here if needed
        // const String apiUrl = 'https://your-api-url.com/api/profile';
        // final response = await http.get(
        //   Uri.parse(apiUrl),
        //   headers: {
        //     'Authorization': 'Bearer $token',
        //     'Accept': 'application/json',
        //   },
        // );

        setState(() {
          name = 'User';
          email = 'user@example.com';
          jobTitle = 'User';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        name = 'Error loading profile';
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileItem('Name', name ?? 'Not available'),
                  _buildProfileItem('Email', email ?? 'Not available'),
                  _buildProfileItem('Job Title', jobTitle ?? 'Not available'),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _authService.logout();
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
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

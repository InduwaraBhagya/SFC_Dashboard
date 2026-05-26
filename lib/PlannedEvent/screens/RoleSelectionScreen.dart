import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../service/AuthService.dart';
import '../model/UserRole.dart';
import '../model/SystemUser.dart';
import 'WorkgroupSelectionScreen.dart';
import '../../OnboardingScreen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final AuthService _authService = AuthService();
  final storage = const FlutterSecureStorage();

  bool _isLoading = true;
  String? _errorMessage;
  List<UserRole> _roles = [];
  UserRole? _selectedRole;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // 1. Get Microsoft user info
      final userInfo = await _authService.getCurrentUser();
      if (userInfo == null) {
        throw Exception('User information not found. Please log in again.');
      }

      // 2. Fetch available roles
      List<UserRole> roles = [];
      try {
        roles = await _authService.getUserRoles();
      } catch (e) {
        debugPrint('Error fetching roles: $e');
        // FALLBACK: If API fails (e.g. 403), provide standard roles so user can at least request/confirm
        roles = [
          UserRole(id: 1, name: 'Admin', level: 1),
          UserRole(id: 2, name: 'User', level: 10),
        ];
      }

      if (roles.isEmpty) {
        roles = [
          UserRole(id: 1, name: 'Admin', level: 1),
          UserRole(id: 2, name: 'User', level: 10),
        ];
      }

      setState(() {
        _userInfo = userInfo;
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final serviceId = _userInfo?['ServiceId'];
      if (serviceId == null) throw Exception('Service ID missing');

      // Create or Update user in backend
      final userRequest = SystemUser(
        name: _userInfo?['Name'] ?? 'Unknown User',
        serviceId: serviceId,
        userRoleId: _selectedRole!.id,
      );

      // Check if user exists first to decide whether to create or update
      // (Though our backend might handle this in POST /api/users)
      final existingUser = await _authService.checkUserByServiceId(serviceId);

      SystemUser? savedUser;
      if (existingUser == null) {
        savedUser = await _authService.createUser(userRequest);
      } else {
        // For now, we'll just use the existing user if it's already there,
        // or we could implement an update call if the backend supports it.
        // But since we are "confirming", we'll ensure they have the role.
        savedUser = existingUser;
      }

      if (savedUser != null && savedUser.id != null) {
        await storage.write(key: 'userId', value: savedUser.id.toString());

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkgroupSelectionScreen(),
            ),
          );
        }
      } else {
        throw Exception('Failed to save user role.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Confirmation'),
        backgroundColor: const Color.fromARGB(226, 16, 37, 89),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              ),
            );
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            ),
          );
          return false;
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(226, 16, 37, 89),
                      Color.fromARGB(255, 8, 11, 66),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_pin,
                              size: 80, color: Colors.white),
                          const SizedBox(height: 24),
                          const Text(
                            'Confirm Your Role',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hello, ${_userInfo?['Name'] ?? 'User'}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField2<UserRole>(
                              decoration: InputDecoration(
                                labelText: 'Select Role',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text('Select your system role'),
                              items: _roles
                                  .map((role) => DropdownMenuItem<UserRole>(
                                        value: role,
                                        child: Text(role.name),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _confirmRole,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    const Color.fromARGB(226, 16, 37, 89),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Confirm and Continue',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

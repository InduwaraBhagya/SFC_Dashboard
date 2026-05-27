import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'PlannedEvent/service/AuthService.dart';
import 'PlannedEvent/model/SystemUser.dart';
import 'PlannedEvent/model/UserRole.dart';
import 'PlannedEvent/model/WorkGroup.dart';
import 'OnboardingScreen.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final AuthService _authService = AuthService();
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serviceIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<UserRole> _userRoles = [];
  List<WorkGroup> _workGroups = [];
  UserRole? _selectedUserRole;
  final List<WorkGroup> _selectedWorkGroups = [];

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userInfo = await _authService.getCurrentUser();
      if (userInfo != null) {
        final serviceId = userInfo['ServiceId'] ?? '';
        if (serviceId.isNotEmpty) {
          // Check if user with serviceId already exists
          final existingUser =
              await _authService.checkUserByServiceId(serviceId);
          if (existingUser != null && existingUser.id != null) {
            // User exists, navigate to OnboardingScreen
            await storage.write(
                key: 'userId', value: existingUser.id.toString());
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const OnboardingScreen()),
              );
              return;
            }
          }
        }
        // If user doesn't exist, populate fields and fetch dropdown data
        setState(() {
          _nameController.text = userInfo['Name'] ?? '';
          _serviceIdController.text = serviceId;
        });
        await _fetchDropdownData();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check user: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDropdownData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userRoles = await _authService.getUserRoles();
      final workGroups = await _authService.getWorkGroups();
      setState(() {
        _userRoles = userRoles;
        _workGroups = workGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load roles and workgroups: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final user = SystemUser(
          name: _nameController.text.trim(),
          serviceId: _serviceIdController.text.trim(),
          userRoleId: _selectedUserRole?.id,
        );

        final createdUser = await _authService.createUser(user);
        if (createdUser == null || createdUser.id == null) {
          throw Exception('Failed to retrieve created user ID');
        }

        await storage.write(key: 'userId', value: createdUser.id.toString());

        if (_selectedWorkGroups.isNotEmpty) {
          final workGroupIds = _selectedWorkGroups.map((wg) => wg.id).toList();
          final success =
              await _authService.setWorkGroups(createdUser.id!, workGroupIds);
          if (!success) {
            throw Exception('Failed to set workgroups for user');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('User created and workgroups assigned successfully')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const OnboardingScreen()),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e
              .toString()
              .replaceFirst('Exception: Error creating user: Exception: ', '');
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
        backgroundColor: const Color.fromARGB(226, 16, 37, 89),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Name is required'
                              : null,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceIdController,
                      decoration: const InputDecoration(
                          labelText: 'Service ID (Object ID)'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Service ID is required'
                              : null,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField2<UserRole>(
                      decoration: const InputDecoration(
                        labelText: 'User Role',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      hint: const Text('Select a role'),
                      items: _userRoles
                          .map((role) => DropdownMenuItem<UserRole>(
                                value: role,
                                child: Text(role.name),
                              ))
                          .toList(),
                      value: _selectedUserRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserRole = value;
                        });
                      },
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField2<WorkGroup>(
                      decoration: const InputDecoration(
                        labelText: 'Work Groups',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      hint: const Text('Select work groups'),
                      items: _workGroups
                          .map((wg) => DropdownMenuItem<WorkGroup>(
                                value: wg,
                                child: Text(wg.name),
                              ))
                          .toList(),
                      value: null,
                      onChanged: (value) {
                        if (value != null &&
                            !_selectedWorkGroups.contains(value)) {
                          setState(() {
                            _selectedWorkGroups.add(value);
                          });
                        }
                      },
                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200,
                      ),
                      selectedItemBuilder: (context) => _workGroups
                          .map((wg) => Text(
                                _selectedWorkGroups.isEmpty
                                    ? 'Select work groups'
                                    : _selectedWorkGroups
                                        .map((wg) => wg.name)
                                        .join(', '),
                              ))
                          .toList(),
                      validator: (value) => null,
                    ),
                    if (_selectedWorkGroups.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _selectedWorkGroups
                            .map((wg) => Chip(
                                  label: Text(wg.name),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedWorkGroups.remove(wg);
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(226, 16, 37, 89),
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Create User'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

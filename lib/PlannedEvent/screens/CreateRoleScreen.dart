import 'package:flutter/material.dart';
import '../model/UserRole.dart';
import '../model/Permission.dart';
import '../service/RoleService.dart';
import '../service/PermissionService.dart';

class CreateRoleScreen extends StatefulWidget {
  const CreateRoleScreen({super.key});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final RoleService _roleService = RoleService();
  final PermissionService _permissionService = PermissionService();

  List<Permission> _allPermissions = [];
  final Set<int> _selectedPermissionIds = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _fetchPermissions() async {
    try {
      final permissions = await _permissionService.getAllPermissions();
      setState(() {
        _allPermissions = permissions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching permissions: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final role = UserRole(
        name: _nameController.text.trim(),
        level: int.parse(_levelController.text.trim()),
        permissionIds: _selectedPermissionIds.toList(),
      );

      await _roleService.createRole(role);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role created successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create role')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Create New Role',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF102559),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: const Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.security, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Create New Role',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Role Name
                    const Text('Role Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102559))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter role name',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter a name'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Role Level
                    const Text('Role Level',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102559))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _levelController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter role level (0-3)',
                        prefixIcon: const Icon(Icons.leaderboard_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a level';
                        }
                        final level = int.tryParse(value);
                        if (level == null || level < 0 || level > 3) {
                          return 'Level must be 0-3';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Colors.grey.shade600),
                        Text(
                          'Level 0: Normal employees | Level 1-3: Management levels',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Permissions Section
                    const Text('Permissions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF102559))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: _allPermissions.isEmpty
                          ? const Center(child: Text('No permissions found'))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _allPermissions.length,
                              itemBuilder: (context, index) {
                                final permission = _allPermissions[index];
                                final isSelected = _selectedPermissionIds
                                    .contains(permission.id);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedPermissionIds
                                            .remove(permission.id);
                                      } else {
                                        _selectedPermissionIds
                                            .add(permission.id!);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF1976D2)
                                              : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                _selectedPermissionIds
                                                    .add(permission.id!);
                                              } else {
                                                _selectedPermissionIds
                                                    .remove(permission.id);
                                              }
                                            });
                                          },
                                          activeColor: const Color(0xFF1976D2),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                permission.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                permission.description ?? '',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Colors.grey.shade600),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.add_circle_outline,
                                  color: Colors.white),
                          label: const Text('Create Role',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF102559)),
                          label: const Text('Back to List',
                              style: TextStyle(
                                  color: Color(0xFF102559),
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side:
                                    const BorderSide(color: Color(0xFF102559))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

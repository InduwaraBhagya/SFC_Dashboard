import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'DashboardScreen.dart';
import '../model/UserRole.dart';
import '../service/RoleService.dart';
import 'CreateRoleScreen.dart';
import 'EditRoleScreen.dart';
import 'RoleDetailsScreen.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final RoleService _roleService = RoleService();
  List<UserRole> _roles = [];
  List<UserRole> _filteredRoles = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchRoles();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadUserId() async {
    final storedId = await _storage.read(key: 'userId');
    if (storedId != null) {
      setState(() {
        _userId = int.tryParse(storedId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final roles = await _roleService.getAllRoles();
      setState(() {
        _roles = roles;
        _filteredRoles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load roles. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRoles = _roles.where((role) {
        return role.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteRole(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _roleService.deleteRole(id);
        _fetchRoles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete role')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Manage Roles',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF102559),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_userId != null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(userId: _userId!),
                ),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Roles',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF102559),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage system roles and permissions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateRoleScreen()),
                      );
                      if (result == true) {
                        _fetchRoles();
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 18),
                    label: const Text('Create New Role',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar Area
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search roles...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // List Section
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Center(
                            child: Text(_errorMessage!,
                                style: const TextStyle(color: Colors.red))),
                      )
                    : _filteredRoles.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Center(child: Text('No roles found')),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: _filteredRoles.length,
                            itemBuilder: (context, index) {
                              final role = _filteredRoles[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(Icons.security,
                                                    size: 18,
                                                    color: Color(0xFF102559)),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    role.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Color(0xFF102559),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD32F2F)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: const Color(0xFFD32F2F)
                                                      .withOpacity(0.5)),
                                            ),
                                            child: Text(
                                              'Level ${role.level}',
                                              style: const TextStyle(
                                                  color: Color(0xFFD32F2F),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          _actionButton(
                                            icon: Icons.edit_outlined,
                                            label: 'Edit',
                                            color: const Color(0xFF1976D2),
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        EditRoleScreen(
                                                            role: role)),
                                              );
                                              if (result == true) {
                                                _fetchRoles();
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          _actionButton(
                                            icon: Icons.info_outline,
                                            label: 'Info',
                                            color: const Color(0xFF00BCD4),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        RoleDetailsScreen(
                                                            role: role)),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          _actionButton(
                                            icon: Icons.delete_outline,
                                            label: 'Delete',
                                            color: const Color(0xFFD32F2F),
                                            onPressed: () =>
                                                _deleteRole(role.id!),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return Tooltip(
      message: label,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: IconButton(
          icon: Icon(icon, size: 18, color: color),
          onPressed: onPressed,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../model/UserRole.dart';
import '../model/Permission.dart';
import '../service/RoleService.dart';
import '../service/PermissionService.dart';
import 'EditRoleScreen.dart';

class RoleDetailsScreen extends StatefulWidget {
  final UserRole role;

  const RoleDetailsScreen({super.key, required this.role});

  @override
  State<RoleDetailsScreen> createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsScreen> {
  final RoleService _roleService = RoleService();
  final PermissionService _permissionService = PermissionService();

  List<Permission> _assignedPermissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final assignedIds =
          await _roleService.getRolePermissionIds(widget.role.id!);
      final allPermissions = await _permissionService.getAllPermissions();

      setState(() {
        _assignedPermissions =
            allPermissions.where((p) => assignedIds.contains(p.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching role details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Role Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF102559),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Role Details',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Role Info
                              const Text('Role Information',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF102559))),
                              const SizedBox(height: 16),
                              _detailItem('Name', widget.role.name),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 80,
                                    child: Text('Level',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1976D2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Level ${widget.role.level}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              // Permissions
                              const Row(
                                children: [
                                  Icon(Icons.security,
                                      size: 16, color: Color(0xFF102559)),
                                  SizedBox(width: 6),
                                  Text('Permissions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF102559))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _assignedPermissions.isEmpty
                                    ? [
                                        const Text('No permissions assigned',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 13))
                                      ]
                                    : _assignedPermissions
                                        .map((p) => _permissionPill(p.name))
                                        .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    EditRoleScreen(role: widget.role)),
                          );
                          if (result == true) {
                            _fetchDetails();
                          }
                        },
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                        label: const Text('Edit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF102559), size: 18),
                        label: const Text('Back to List',
                            style: TextStyle(
                                color: Color(0xFF102559),
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFF102559))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 15, color: Colors.black)),
        ),
      ],
    );
  }

  Widget _permissionPill(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

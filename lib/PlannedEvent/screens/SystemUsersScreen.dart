// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import '../model/SystemUser.dart';
// import '../model/UserRole.dart';
// import '../model/WorkGroupModel.dart';
// import '../service/SystemUserService.dart';
// import '../service/WorkGroupService.dart';
// import 'DashboardHome.dart';

// class SystemUsersScreen extends StatefulWidget {
//   final int userId;
//   const SystemUsersScreen({super.key, required this.userId});

//   @override
//   State<SystemUsersScreen> createState() => _SystemUsersScreenState();
// }

// class _SystemUsersScreenState extends State<SystemUsersScreen> {
//   final SystemUserService _userService = SystemUserService();
//   final WorkGroupService _workGroupService = WorkGroupService();

//   List<SystemUser> _users = [];
//   List<SystemUser> _filteredUsers = [];
//   List<UserRole> _roles = [];
//   List<WorkGroupDetails> _workGroups = [];

//   bool _isLoading = true;
//   String? _errorMessage;
//   bool _isCreating = false;
//   bool _isEditing = false;
//   bool _isViewing = false;
//   SystemUser? _selectedUser;
//   String _searchQuery = '';
//   String _wgSearchQuery = '';

//   // Form Controllers
//   final _nameController = TextEditingController();
//   final _serviceIdController = TextEditingController();
//   int? _selectedRoleId;
//   List<int> _selectedWorkGroupIds = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _serviceIdController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final futures = await Future.wait([
//         _userService.fetchSystemUsers(),
//         _userService.fetchUserRoles(),
//         _workGroupService.fetchWorkGroups(),
//       ]);

//       setState(() {
//         _users = futures[0] as List<SystemUser>;
//         _filteredUsers = _users;
//         _roles = futures[1] as List<UserRole>;
//         _workGroups = futures[2] as List<WorkGroupDetails>;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load data: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _filterUsers(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         _filteredUsers = _users;
//       } else {
//         _filteredUsers = _users.where((u) {
//           return u.name.toLowerCase().contains(query.toLowerCase()) ||
//               u.serviceId.toLowerCase().contains(query.toLowerCase());
//         }).toList();
//       }
//     });
//   }

//   Future<void> _createUser() async {
//     if (_nameController.text.isEmpty || _serviceIdController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all required fields')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);
//     final newUser = SystemUser(
//       name: _nameController.text,
//       serviceId: _serviceIdController.text,
//       userRoleId: _selectedRoleId,
//       workGroupIds: _selectedWorkGroupIds,
//     );

//     final success = await _userService.createSystemUser(newUser);
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User created successfully')),
//       );
//       _nameController.clear();
//       _serviceIdController.clear();
//       _selectedRoleId = null;
//       _selectedWorkGroupIds.clear();
//       setState(() => _isCreating = false);
//       await _fetchData();
//     } else {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to create user')),
//       );
//     }
//   }

//   Future<void> _updateUser() async {
//     if (_nameController.text.isEmpty ||
//         _serviceIdController.text.isEmpty ||
//         _selectedUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please fill all required fields')));
//       return;
//     }

//     setState(() => _isLoading = true);
//     final updatedUser = SystemUser(
//       id: _selectedUser!.id,
//       name: _nameController.text,
//       serviceId: _serviceIdController.text,
//       userRoleId: _selectedRoleId,
//       workGroupIds: _selectedWorkGroupIds,
//     );

//     final success = await _userService.updateSystemUser(updatedUser);
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User updated successfully')));
//       setState(() {
//         _isEditing = false;
//         _selectedUser = null;
//       });
//       await _fetchData();
//     } else {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Failed to update user')));
//     }
//   }

//   Future<void> _deleteUser(int id) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete User'),
//         content: const Text('Are you sure you want to delete this user?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel')),
//           TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       setState(() => _isLoading = true);
//       final success = await _userService.deleteSystemUser(id);
//       if (success) {
//         await _fetchData();
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to delete user')));
//       }
//     }
//   }

//   String _getRoleName(int? roleId) {
//     if (roleId == null) return 'N/A';
//     try {
//       return _roles.firstWhere((r) => r.id == roleId).name;
//     } catch (_) {
//       return 'Unknown';
//     }
//   }

//   String _getWorkGroupNames(List<int>? wgIds) {
//     if (wgIds == null || wgIds.isEmpty) return 'None';
//     final names = wgIds.map((id) {
//       try {
//         return _workGroups.firstWhere((wg) => wg.id == id).name ?? 'Unknown';
//       } catch (_) {
//         return 'Unknown';
//       }
//     }).toList();
//     return names.join(', ');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text('Planned Event',
//             style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//         backgroundColor: const Color.fromARGB(255, 4, 24, 96),
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             if (_isCreating || _isEditing || _isViewing) {
//               setState(() {
//                 _isCreating = false;
//                 _isEditing = false;
//                 _isViewing = false;
//                 _selectedUser = null;
//               });
//             } else {
//               Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           DashboardHome(userId: widget.userId)));
//             }
//           },
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(
//                   child: Text(_errorMessage!,
//                       style: const TextStyle(color: Colors.red)))
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: _isCreating
//                         ? _buildCreateUserView()
//                         : _isEditing
//                             ? _buildEditUserView()
//                             : _isViewing
//                                 ? _buildUserDetailsView()
//                                 : _buildUsersList(),
//                   ),
//                 ),
//     );
//   }

//   Widget _buildUsersList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Wrap(
//           alignment: WrapAlignment.spaceBetween,
//           crossAxisAlignment: WrapCrossAlignment.center,
//           spacing: 16,
//           runSpacing: 16,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('System Users',
//                     style: GoogleFonts.poppins(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF1E293B))),
//                 Text('Manage system users and their permissions',
//                     style: GoogleFonts.poppins(
//                         fontSize: 14, color: Colors.grey.shade600)),
//               ],
//             ),
//             ElevatedButton.icon(
//               onPressed: () {
//                 _nameController.clear();
//                 _serviceIdController.clear();
//                 _selectedRoleId = null;
//                 _selectedWorkGroupIds.clear();
//                 setState(() => _isCreating = true);
//               },
//               icon: const Icon(Icons.add_circle_outline, size: 18),
//               label: Text('Create New User',
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1D4ED8),
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//         TextField(
//           onChanged: _filterUsers,
//           decoration: InputDecoration(
//             hintText: 'Search users...',
//             prefixIcon: const Icon(Icons.search),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.shade300)),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.shade300)),
//             contentPadding:
//                 const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//             fillColor: Colors.white,
//             filled: true,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               headingRowColor: WidgetStateProperty.resolveWith(
//                   (states) => Colors.grey.shade50),
//               columns: [
//                 DataColumn(
//                     label: Text('Name',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold))),
//                 DataColumn(
//                     label: Text('ServiceId',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold))),
//                 DataColumn(
//                     label: Text('UserRole',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold))),
//                 DataColumn(
//                     label: Text('Work Groups',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold))),
//                 DataColumn(
//                     label: Text('Actions',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold))),
//               ],
//               rows: _filteredUsers.map((user) {
//                 return DataRow(
//                   cells: [
//                     DataCell(Text(user.name,
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.w600))),
//                     DataCell(Text(user.serviceId,
//                         style:
//                             GoogleFonts.poppins(color: Colors.grey.shade600))),
//                     DataCell(
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                             color: const Color(0xFF06B6D4),
//                             borderRadius: BorderRadius.circular(12)),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.shield,
//                                 size: 12, color: Colors.black87),
//                             const SizedBox(width: 4),
//                             Text(_getRoleName(user.userRoleId),
//                                 style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                             color: Colors.grey.shade600,
//                             borderRadius: BorderRadius.circular(12)),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.group,
//                                 size: 12, color: Colors.white),
//                             const SizedBox(width: 4),
//                             Text(_getWorkGroupNames(user.workGroupIds),
//                                 style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500)),
//                           ],
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit,
//                                 color: Colors.blue, size: 20),
//                             onPressed: () {
//                               setState(() {
//                                 _selectedUser = user;
//                                 _nameController.text = user.name;
//                                 _serviceIdController.text = user.serviceId;
//                                 _selectedRoleId = user.userRoleId;
//                                 _selectedWorkGroupIds =
//                                     List.from(user.workGroupIds ?? []);
//                                 _isEditing = true;
//                               });
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.info_outline,
//                                 color: Colors.teal, size: 20),
//                             onPressed: () {
//                               setState(() {
//                                 _selectedUser = user;
//                                 _isViewing = true;
//                               });
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete_outline,
//                                 color: Colors.red, size: 20),
//                             onPressed: () =>
//                                 user.id != null ? _deleteUser(user.id!) : null,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEditUserView() {
//     return _buildUserFormView(
//         title: 'Edit User', icon: Icons.edit, isEdit: true);
//   }

//   Widget _buildCreateUserView() {
//     return _buildUserFormView(
//         title: 'Create New User', icon: Icons.person_add, isEdit: false);
//   }

//   Widget _buildUserFormView(
//       {required String title, required IconData icon, required bool isEdit}) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade100, width: 2),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             decoration: const BoxDecoration(
//               color: Color(0xFF1D4ED8),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//             ),
//             child: Row(
//               children: [
//                 Icon(icon, color: Colors.white),
//                 const SizedBox(width: 8),
//                 Text(title,
//                     style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           LayoutBuilder(builder: (context, constraints) {
//             bool isMobile = constraints.maxWidth < 600;
//             return Column(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: isMobile ? 1 : 1,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(isEdit ? 'Name' : 'Full Name',
//                               style: GoogleFonts.poppins(
//                                   fontWeight: FontWeight.w600, fontSize: 14)),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: _nameController,
//                             decoration: InputDecoration(
//                               prefixIcon: const Icon(Icons.person_outline),
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Colors.grey.shade300)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (!isMobile) const SizedBox(width: 24),
//                     if (!isMobile)
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(isEdit ? 'ServiceId' : 'Service ID',
//                                 style: GoogleFonts.poppins(
//                                     fontWeight: FontWeight.w600, fontSize: 14)),
//                             const SizedBox(height: 8),
//                             TextField(
//                               controller: _serviceIdController,
//                               decoration: InputDecoration(
//                                 prefixIcon: const Icon(Icons.key),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: BorderSide(
//                                         color: Colors.grey.shade300)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//                 if (isMobile) const SizedBox(height: 16),
//                 if (isMobile)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(isEdit ? 'ServiceId' : 'Service ID',
//                           style: GoogleFonts.poppins(
//                               fontWeight: FontWeight.w600, fontSize: 14)),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: _serviceIdController,
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(Icons.key),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide:
//                                   BorderSide(color: Colors.grey.shade300)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 24),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(isEdit ? 'UserRoleId' : 'User Role',
//                               style: GoogleFonts.poppins(
//                                   fontWeight: FontWeight.w600, fontSize: 14)),
//                           const SizedBox(height: 8),
//                           DropdownButtonFormField<int>(
//                             value: _selectedRoleId,
//                             decoration: InputDecoration(
//                               prefixIcon: const Icon(Icons.shield_outlined),
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       BorderSide(color: Colors.grey.shade300)),
//                             ),
//                             hint: const Text('Select a role...'),
//                             items: _roles.map((role) {
//                               return DropdownMenuItem<int>(
//                                 value: role.id,
//                                 child: Text(role.name),
//                               );
//                             }).toList(),
//                             onChanged: (val) =>
//                                 setState(() => _selectedRoleId = val),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (!isMobile) const SizedBox(width: 24),
//                     if (!isMobile)
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Work Groups (Select multiple)',
//                                 style: GoogleFonts.poppins(
//                                     fontWeight: FontWeight.w600, fontSize: 14)),
//                             const SizedBox(height: 8),
//                             _buildSearchableWorkGroupSelector(),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//                 if (isMobile) const SizedBox(height: 16),
//                 if (isMobile)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Work Groups (Select multiple)',
//                           style: GoogleFonts.poppins(
//                               fontWeight: FontWeight.w600, fontSize: 14)),
//                       const SizedBox(height: 8),
//                       _buildSearchableWorkGroupSelector(),
//                     ],
//                   ),
//               ],
//             );
//           }),
//           const SizedBox(height: 32),
//           Row(
//             children: [
//               ElevatedButton.icon(
//                 onPressed: isEdit ? _updateUser : _createUser,
//                 icon: const Icon(Icons.check_circle_outline),
//                 label: Text(isEdit ? 'Save Changes' : 'Create',
//                     style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w600, fontSize: 16)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1D4ED8),
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               TextButton.icon(
//                 onPressed: () => setState(() {
//                   _isCreating = false;
//                   _isEditing = false;
//                   _selectedUser = null;
//                 }),
//                 icon: const Icon(Icons.arrow_back),
//                 label: Text('Back to List',
//                     style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.grey.shade800,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchableWorkGroupSelector() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           if (_selectedWorkGroupIds.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Wrap(
//                 spacing: 8,
//                 runSpacing: 4,
//                 children: _selectedWorkGroupIds.map((id) {
//                   final name = _workGroups
//                           .firstWhere((wg) => wg.id == id,
//                               orElse: () => WorkGroupDetails(name: 'Unknown'))
//                           .name ??
//                       'Unknown';
//                   return Chip(
//                     label: Text(name,
//                         style:
//                             const TextStyle(fontSize: 12, color: Colors.white)),
//                     backgroundColor: const Color(0xFF6366F1),
//                     deleteIcon:
//                         const Icon(Icons.close, size: 14, color: Colors.white),
//                     onDeleted: () =>
//                         setState(() => _selectedWorkGroupIds.remove(id)),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   );
//                 }).toList(),
//               ),
//             ),
//           InkWell(
//             onTap: _showWorkGroupMultiSelectDialog,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Add work groups...',
//                     style: GoogleFonts.poppins(
//                         color: Colors.grey.shade600, fontSize: 14),
//                   ),
//                   const Icon(Icons.add, color: Colors.grey, size: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserDetailsView() {
//     if (_selectedUser == null) return const SizedBox();
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.info_outline,
//                   color: Color(0xFF1D4ED8), size: 28),
//               const SizedBox(width: 12),
//               Text('User Details',
//                   style: GoogleFonts.poppins(
//                       fontSize: 22, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const Divider(height: 32),
//           _buildDetailRow('Full Name', _selectedUser!.name),
//           _buildDetailRow('Service ID', _selectedUser!.serviceId),
//           _buildDetailRow('Role', _getRoleName(_selectedUser!.userRoleId)),
//           _buildDetailRow(
//               'Work Groups', _getWorkGroupNames(_selectedUser!.workGroupIds)),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: () => setState(() {
//               _isViewing = false;
//               _selectedUser = null;
//             }),
//             icon: const Icon(Icons.arrow_back),
//             label: const Text('Back to List'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey.shade800,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//               width: 120,
//               child: Text(label,
//                   style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey.shade600))),
//           Expanded(
//               child: Text(value,
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
//         ],
//       ),
//     );
//   }

//   void _showWorkGroupMultiSelectDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String filter = '';
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             final filteredWgs = _workGroups
//                 .where((wg) => (wg.name ?? '')
//                     .toLowerCase()
//                     .contains(filter.toLowerCase()))
//                 .toList();
//             return AlertDialog(
//               title: const Text('Select Work Groups'),
//               content: SizedBox(
//                 width: 400,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       decoration: const InputDecoration(
//                         hintText: 'Search work groups...',
//                         prefixIcon: Icon(Icons.search),
//                       ),
//                       onChanged: (val) => setStateDialog(() => filter = val),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       height: 400,
//                       child: ListView.builder(
//                         itemCount: filteredWgs.length,
//                         itemBuilder: (context, index) {
//                           final wg = filteredWgs[index];
//                           final isSelected = wg.id != null &&
//                               _selectedWorkGroupIds.contains(wg.id!);
//                           return CheckboxListTile(
//                             title: Text(wg.name ?? 'N/A'),
//                             value: isSelected,
//                             onChanged: (bool? val) {
//                               setStateDialog(() {
//                                 if (val == true && wg.id != null) {
//                                   _selectedWorkGroupIds.add(wg.id!);
//                                 } else if (wg.id != null) {
//                                   _selectedWorkGroupIds.remove(wg.id!);
//                                 }
//                               });
//                               setState(() {});
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Done'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/SystemUser.dart';
import '../model/UserRole.dart';
import '../model/WorkGroupModel.dart';
import '../service/SystemUserService.dart';
import '../service/WorkGroupService.dart';
import 'DashboardScreen.dart';

class SystemUsersScreen extends StatefulWidget {
  final int userId;
  const SystemUsersScreen({super.key, required this.userId});

  @override
  State<SystemUsersScreen> createState() => _SystemUsersScreenState();
}

class _SystemUsersScreenState extends State<SystemUsersScreen> {
  final SystemUserService _userService = SystemUserService();
  final WorkGroupService _workGroupService = WorkGroupService();

  List<SystemUser> _users = [];
  List<SystemUser> _filteredUsers = [];
  List<UserRole> _roles = [];
  List<WorkGroupDetails> _workGroups = [];

  bool _isLoading = true;
  String? _errorMessage;
  bool _isCreating = false;
  bool _isEditing = false;
  bool _isViewing = false;
  SystemUser? _selectedUser;
  String _searchQuery = '';
  final String _wgSearchQuery = '';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int? _userId;

  // Form Controllers
  final _nameController = TextEditingController();
  final _serviceIdController = TextEditingController();
  int? _selectedRoleId;
  List<int> _selectedWorkGroupIds = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchData();
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
    _nameController.dispose();
    _serviceIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final futures = await Future.wait([
        _userService.fetchSystemUsers(),
        _userService.fetchUserRoles(),
        _workGroupService.fetchWorkGroups(),
      ]);

      setState(() {
        _users = futures[0] as List<SystemUser>;
        _filteredUsers = _users;
        _roles = futures[1] as List<UserRole>;
        _workGroups = futures[2] as List<WorkGroupDetails>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((u) {
          return u.name.toLowerCase().contains(query.toLowerCase()) ||
              u.serviceId.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _createUser() async {
    if (_nameController.text.isEmpty || _serviceIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final newUser = SystemUser(
      name: _nameController.text,
      serviceId: _serviceIdController.text,
      userRoleId: _selectedRoleId,
      workGroupIds: _selectedWorkGroupIds,
    );

    final success = await _userService.createSystemUser(newUser);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
      _nameController.clear();
      _serviceIdController.clear();
      _selectedRoleId = null;
      _selectedWorkGroupIds.clear();
      setState(() => _isCreating = false);
      await _fetchData();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user')),
      );
    }
  }

  Future<void> _updateUser() async {
    if (_nameController.text.isEmpty ||
        _serviceIdController.text.isEmpty ||
        _selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isLoading = true);
    final updatedUser = SystemUser(
      id: _selectedUser!.id,
      name: _nameController.text,
      serviceId: _serviceIdController.text,
      userRoleId: _selectedRoleId,
      workGroupIds: _selectedWorkGroupIds,
    );

    final success = await _userService.updateSystemUser(updatedUser);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')));
      setState(() {
        _isEditing = false;
        _selectedUser = null;
      });
      await _fetchData();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to update user')));
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _userService.deleteSystemUser(id);
      if (success) {
        await _fetchData();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete user')));
      }
    }
  }

  String _getRoleName(int? roleId) {
    if (roleId == null) return 'N/A';
    try {
      return _roles.firstWhere((r) => r.id == roleId).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  String _getWorkGroupNames(List<int>? wgIds) {
    if (wgIds == null || wgIds.isEmpty) return 'None';
    final names = wgIds.map((id) {
      try {
        return _workGroups.firstWhere((wg) => wg.id == id).name ?? 'Unknown';
      } catch (_) {
        return 'Unknown';
      }
    }).toList();
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('System Users',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF102559),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isCreating || _isEditing || _isViewing) {
              setState(() {
                _isCreating = false;
                _isEditing = false;
                _isViewing = false;
                _selectedUser = null;
              });
            } else {
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
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isCreating
                        ? _buildCreateUserView()
                        : _isEditing
                            ? _buildEditUserView()
                            : _isViewing
                                ? _buildUserDetailsView()
                                : _buildUsersList(),
                  ),
                ),
    );
  }

  Widget _buildUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Users',
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B))),
                Text('Manage system users and their permissions',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                _nameController.clear();
                _serviceIdController.clear();
                _selectedRoleId = null;
                _selectedWorkGroupIds.clear();
                setState(() => _isCreating = true);
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text('Create New User',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          onChanged: _filterUsers,
          decoration: InputDecoration(
            hintText: 'Search users...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.grey.shade50),
              columns: [
                DataColumn(
                    label: Text('Name',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('ServiceId',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('UserRole',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Work Groups',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Actions',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold))),
              ],
              rows: _filteredUsers.map((user) {
                return DataRow(
                  cells: [
                    DataCell(Text(user.name,
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                    DataCell(Text(user.serviceId,
                        style:
                            GoogleFonts.poppins(color: Colors.grey.shade600))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield,
                                size: 12, color: Colors.black87),
                            const SizedBox(width: 4),
                            Text(_getRoleName(user.userRoleId),
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(_getWorkGroupNames(user.workGroupIds),
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedUser = user;
                                _nameController.text = user.name;
                                _serviceIdController.text = user.serviceId;
                                _selectedRoleId = user.userRoleId;
                                _selectedWorkGroupIds =
                                    List.from(user.workGroupIds ?? []);
                                _isEditing = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.teal, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedUser = user;
                                _isViewing = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () =>
                                user.id != null ? _deleteUser(user.id!) : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditUserView() {
    return _buildUserFormView(
        title: 'Edit User', icon: Icons.edit, isEdit: true);
  }

  Widget _buildCreateUserView() {
    return _buildUserFormView(
        title: 'Create New User', icon: Icons.person_add, isEdit: false);
  }

  Widget _buildUserFormView(
      {required String title, required IconData icon, required bool isEdit}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1D4ED8),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isMobile ? 1 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEdit ? 'Name' : 'Full Name',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) const SizedBox(width: 24),
                    if (!isMobile)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isEdit ? 'ServiceId' : 'Service ID',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _serviceIdController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.key),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (isMobile) const SizedBox(height: 16),
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEdit ? 'ServiceId' : 'Service ID',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _serviceIdController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.key),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEdit ? 'UserRoleId' : 'User Role',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedRoleId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.shield_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                            ),
                            hint: const Text('Select a role...'),
                            items: _roles.map((role) {
                              return DropdownMenuItem<int>(
                                value: role.id,
                                child: Text(role.name),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedRoleId = val),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) const SizedBox(width: 24),
                    if (!isMobile)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Work Groups (Select multiple)',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            _buildSearchableWorkGroupSelector(),
                          ],
                        ),
                      ),
                  ],
                ),
                if (isMobile) const SizedBox(height: 16),
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Work Groups (Select multiple)',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildSearchableWorkGroupSelector(),
                    ],
                  ),
              ],
            );
          }),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: isEdit ? _updateUser : _createUser,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(isEdit ? 'Save Changes' : 'Create',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() {
                  _isCreating = false;
                  _isEditing = false;
                  _isViewing = false;
                  _selectedUser = null;
                }),
                icon: const Icon(Icons.arrow_back),
                label: Text('Back to List',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableWorkGroupSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (_selectedWorkGroupIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedWorkGroupIds.map((id) {
                  final name = _workGroups
                          .firstWhere((wg) => wg.id == id,
                              orElse: () => WorkGroupDetails(name: 'Unknown'))
                          .name ??
                      'Unknown';
                  return Chip(
                    label: Text(name,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                    backgroundColor: const Color(0xFF6366F1),
                    deleteIcon:
                        const Icon(Icons.close, size: 14, color: Colors.white),
                    onDeleted: () =>
                        setState(() => _selectedWorkGroupIds.remove(id)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  );
                }).toList(),
              ),
            ),
          InkWell(
            onTap: _showWorkGroupMultiSelectDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add work groups...',
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const Icon(Icons.add, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsView() {
    if (_selectedUser == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFF1D4ED8), size: 28),
              const SizedBox(width: 12),
              Text('User Details',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow('Full Name', _selectedUser!.name),
          _buildDetailRow('Service ID', _selectedUser!.serviceId),
          _buildDetailRow('Role', _getRoleName(_selectedUser!.userRoleId)),
          _buildDetailRow(
              'Work Groups', _getWorkGroupNames(_selectedUser!.workGroupIds)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => setState(() {
              _isViewing = false;
              _selectedUser = null;
            }),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600))),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showWorkGroupMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filteredWgs = _workGroups
                .where((wg) => (wg.name ?? '')
                    .toLowerCase()
                    .contains(filter.toLowerCase()))
                .toList();
            return AlertDialog(
              title: const Text('Select Work Groups'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search work groups...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) => setStateDialog(() => filter = val),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: filteredWgs.length,
                        itemBuilder: (context, index) {
                          final wg = filteredWgs[index];
                          final isSelected = wg.id != null &&
                              _selectedWorkGroupIds.contains(wg.id!);
                          return CheckboxListTile(
                            title: Text(wg.name ?? 'N/A'),
                            value: isSelected,
                            onChanged: (bool? val) {
                              setStateDialog(() {
                                if (val == true && wg.id != null) {
                                  _selectedWorkGroupIds.add(wg.id!);
                                } else if (wg.id != null) {
                                  _selectedWorkGroupIds.remove(wg.id!);
                                }
                              });
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

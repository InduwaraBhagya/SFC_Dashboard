import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../service/AuthService.dart';
import '../model/WorkGroup.dart';
import '../model/SystemUser.dart';

import 'DashboardScreen.dart';
import 'RoleSelectionScreen.dart';

class WorkgroupSelectionScreen extends StatefulWidget {
  const WorkgroupSelectionScreen({super.key});

  @override
  State<WorkgroupSelectionScreen> createState() =>
      _WorkgroupSelectionScreenState();
}

class _WorkgroupSelectionScreenState extends State<WorkgroupSelectionScreen> {
  final AuthService _authService = AuthService();
  final storage = const FlutterSecureStorage();

  bool _isLoading = true;
  String? _errorMessage;
  int? _userId;
  List<WorkGroup> _userWorkgroups = [];
  WorkGroup? _selectedWorkGroup;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserAndWorkgroups();
  }

  Future<void> _initializeUserAndWorkgroups() async {
    try {
      final userInfo = await _authService.getCurrentUser();
      if (userInfo == null) {
        throw Exception('User info not found. Please log in again.');
      }

      final serviceId = userInfo['ServiceId'] ?? '';
      if (serviceId.isEmpty) {
        throw Exception('Service ID not found for the current user.');
      }

      // Check if user exists in backend
      SystemUser? existingUser;
      try {
        existingUser = await _authService.checkUserByServiceId(serviceId);
      } catch (e) {
        debugPrint('Error checking user: $e');
      }
      
      if (existingUser != null && existingUser.id != null) {
        _userId = existingUser.id;
        await storage.write(key: 'userId', value: _userId.toString());
      } else {
        // If user still doesn't exist here, they might have skipped Role Selection 
        // or something went wrong. We'll show an error.
        throw Exception('User registration not found. Please go through the role selection.');
      }

      // Fetch ALL workgroups so the user can select any to filter the dashboard
      List<WorkGroup> availableWorkgroups = [];
      try {
        availableWorkgroups = await _authService.getWorkGroups();
      } catch (e) {
        debugPrint('Error fetching workgroups: $e');
        if (e.toString().contains('403')) {
          rethrow;
        }
        // Fallback: try fetching only user-assigned workgroups
        try {
          if (existingUser.workGroupIds != null &&
              existingUser.workGroupIds!.isNotEmpty) {
            availableWorkgroups = await _authService
                .getWorkGroupsByIds(existingUser.workGroupIds!);
          }
        } catch (_) {}
      }

      setState(() {
        _userWorkgroups = availableWorkgroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _continueToDashboard() async {
    if (_selectedWorkGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workgroup first')),
      );
      return;
    }

    if (_userId == null) {
      setState(() {
        _errorMessage =
            'User ID not found. Please try again or contact admin.';
      });
      return;
    }

    // Navigate directly — selection is only a dashboard filter,
    // we do NOT modify the user's backend workgroup assignment here.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            userId: _userId!,
            selectedWorkGroupId: _selectedWorkGroup!.id,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Workgroup'),
        backgroundColor: const Color.fromARGB(226, 16, 37, 89),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RoleSelectionScreen(),
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
              builder: (context) => RoleSelectionScreen(),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.group_work,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Title
                          const Text(
                            'Select Your Workgroup',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Subtitle
                          const Text(
                            'Choose a workgroup to filter and access relevant records',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Error Message
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else ...[
                            // Dropdown Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField2<WorkGroup>(
                                decoration: InputDecoration(
                                  labelText: 'Work Group',
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(226, 16, 37, 89),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(226, 16, 37, 89),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(226, 16, 37, 89),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                isExpanded: true,
                                hint: Text(
                                  _userWorkgroups.isEmpty
                                      ? 'No workgroups available'
                                      : 'Select a workgroup',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                items: _userWorkgroups
                                    .map((wg) => DropdownMenuItem<WorkGroup>(
                                          value: wg,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.group_work,
                                                  size: 18,
                                                  color: Color.fromARGB(
                                                      226, 16, 37, 89)),
                                              const SizedBox(width: 10),
                                              Text(
                                                wg.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      226, 16, 37, 89),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                value: _selectedWorkGroup,
                                onChanged: _userWorkgroups.isEmpty
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedWorkGroup = value;
                                        });
                                      },
                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.only(right: 8),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                dropdownSearchData: DropdownSearchData(
                                  searchController: _searchController,
                                  searchInnerWidgetHeight: 50,
                                  searchInnerWidget: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 4,
                                      right: 8,
                                      left: 8,
                                    ),
                                    child: TextFormField(
                                      expands: true,
                                      maxLines: null,
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        hintText: 'Search for a workgroup...',
                                        hintStyle: const TextStyle(fontSize: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchMatchFn: (item, searchValue) {
                                    final String name = (item.value as WorkGroup).name.toLowerCase();
                                    return name.contains(searchValue.toLowerCase());
                                  },
                                ),
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    _searchController.clear();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Info Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your dashboard will be filtered to show records for the selected workgroup.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _continueToDashboard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      const Color.fromARGB(226, 16, 37, 89),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Continue to Dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ]
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

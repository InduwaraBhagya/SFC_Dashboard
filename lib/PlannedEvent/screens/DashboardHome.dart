// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:intl/intl.dart';
// import '../service/OLAViolateRecordService.dart';
// import '../service/RegularRecordService.dart';
// import '../service/UrgentRecordService.dart';
// import '../service/HoldRecordService.dart';
// import '../service/TaskQueueService.dart';
// import '../service/NoticeService.dart';
// import '../model/Notice.dart';
// import 'RecordDetailsScreen.dart';
// import 'SearchResultsScreen.dart';
// import 'UrgentRecordScreen.dart';
// import 'RegularRecordScreen.dart';
// import 'OLAViolateRecordScreen.dart';
// import 'HoldRecordScreen.dart';
// import 'TaskQueueScreen.dart';
// import '../service/AuthService.dart';

// class DashboardHome extends StatefulWidget {
//   final int userId;
//   final List<int> selectedWorkGroupIds;
//   const DashboardHome({
//     super.key,
//     required this.userId,
//     this.selectedWorkGroupIds = const [], // <- default empty list
//   });

//   @override
//   State<DashboardHome> createState() => _DashboardHomeState();
// }

// class _DashboardHomeState extends State<DashboardHome> {
//   String selectedSearchBy = 'PE Number';
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = false;
//   bool _isSearching = false;

//   int? _olaViolateCount;
//   bool _isLoadingOlaCount = false;
//   String? _olaCountError;

//   int? _regularRecordCount;
//   bool _isLoadingRegularCount = false;
//   String? _regularCountError;

//   int? _urgentRecordCount;
//   bool _isLoadingUrgentCount = false;
//   String? _urgentCountError;

//   int? _holdRecordCount;
//   bool _isLoadingHoldCount = false;
//   String? _holdCountError;

//   List<Notice>? _notices;
//   bool _isLoadingNotices = false;
//   String? _noticesError;

//   final OLAViolateRecordService _olaService = OLAViolateRecordService();
//   final RegularRecordService _regularService = RegularRecordService();
//   final UrgentRecordService _urgentService = UrgentRecordService();
//   final HoldRecordService _holdService = HoldRecordService();
//   final TaskQueueService taskQueueService = TaskQueueService(
//     accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
//   );
//   final NoticeService _noticeService = NoticeService(
//     accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
//   );
//   final AuthService _authService = AuthService();

//   String? _currentUserName;
//   String? _currentUserRole;
//   int _totalTasks = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserInfo();
//     _fetchOlaViolateCount();
//     _fetchRegularRecordCount();
//     _fetchUrgentRecordCount();
//     _fetchHoldRecordCount();
//     _fetchNotices();
//   }

//   Future<void> _fetchUserInfo() async {
//     try {
//       final user = await _authService.getUserById(widget.userId);
//       final roles = await _authService.getUserRoles();
//       if (user != null && mounted) {
//         final role = roles.firstWhere((r) => r.id == user.userRoleId,
//             orElse: () =>
//                 roles.isNotEmpty ? roles.first : roles.first); // fallback
//         setState(() {
//           _currentUserName = user.name;
//           _currentUserRole = role.name;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching user info: $e');
//     }
//   }

//   void _calculateTotalTasks() {
//     setState(() {
//       _totalTasks = (_urgentRecordCount ?? 0) +
//           (_regularRecordCount ?? 0) +
//           (_olaViolateCount ?? 0) +
//           (_holdRecordCount ?? 0);
//     });
//   }

//   Future<void> _fetchOlaViolateCount() async {
//     setState(() {
//       _isLoadingOlaCount = true;
//       _olaCountError = null;
//     });
//     try {
//       final result =
//           await _olaService.fetchOLAViolateRecords(page: 1, pageSize: 1);
//       setState(() {
//         _olaViolateCount = result['totalCount'] ?? 0;
//         _isLoadingOlaCount = false;
//         _calculateTotalTasks();
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _olaCountError = 'Failed to load OLA count: $e';
//           _isLoadingOlaCount = false;
//         });
//         debugPrint(_olaCountError);
//       }
//     }
//   }

//   Future<void> _fetchRegularRecordCount() async {
//     setState(() {
//       _isLoadingRegularCount = true;
//       _regularCountError = null;
//     });
//     try {
//       final result =
//           await _regularService.fetchRegularRecords(page: 1, pageSize: 1);
//       setState(() {
//         _regularRecordCount = result['totalCount'] ?? 0;
//         _isLoadingRegularCount = false;
//         _calculateTotalTasks();
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _regularCountError = 'Failed to load regular count: $e';
//           _isLoadingRegularCount = false;
//         });
//         debugPrint(_regularCountError);
//       }
//     }
//   }

//   Future<void> _fetchUrgentRecordCount() async {
//     setState(() {
//       _isLoadingUrgentCount = true;
//       _urgentCountError = null;
//     });
//     try {
//       final result =
//           await _urgentService.fetchUrgentRecords(page: 1, pageSize: 1);
//       setState(() {
//         _urgentRecordCount = result['totalCount'] ?? 0;
//         _isLoadingUrgentCount = false;
//         _calculateTotalTasks();
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _urgentCountError = 'Failed to load urgent count: $e';
//           _isLoadingUrgentCount = false;
//         });
//         debugPrint(_urgentCountError);
//       }
//     }
//   }

//   Future<void> _fetchHoldRecordCount() async {
//     setState(() {
//       _isLoadingHoldCount = true;
//       _holdCountError = null;
//     });
//     try {
//       final result = await _holdService.getHoldRecords(pageSize: 1);
//       final List records = result['records'] ?? [];
//       setState(() {
//         _holdRecordCount = records.length;
//         _isLoadingHoldCount = false;
//         _calculateTotalTasks();
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _holdCountError = 'Failed to load hold count: $e';
//           _isLoadingHoldCount = false;
//         });
//         debugPrint(_holdCountError);
//       }
//     }
//   }

//   Future<void> _fetchNotices() async {
//     setState(() {
//       _isLoadingNotices = true;
//       _noticesError = null;
//     });
//     try {
//       final notices = await _noticeService.getActiveNotices();
//       if (mounted) {
//         setState(() {
//           _notices = notices;
//           _isLoadingNotices = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _noticesError = 'Failed to load notices: $e';
//           _isLoadingNotices = false;
//         });
//         debugPrint(_noticesError);
//       }
//     }
//   }

//   Future<void> _performSearch() async {
//     if (_searchController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a search value')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String? apiUrl = dotenv.env['API_BASE_URL'];
//       if (apiUrl == null) {
//         throw Exception('API_BASE_URL is not configured in .env');
//       }

//       final String query =
//           '$apiUrl/api/PERecordsApi/filter?page=1&pageSize=1000&searchCategory=${Uri.encodeComponent(selectedSearchBy)}&searchValue=${Uri.encodeComponent(_searchController.text.trim())}';
//       debugPrint('API Request URL: $query');

//       final response = await http.get(
//         Uri.parse(query),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${dotenv.env['ACCESS_TOKEN'] ?? ''}',
//         },
//       );

//       debugPrint('Raw API Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);

//         if (responseData['success'] != true) {
//           throw Exception(
//               'API returned unsuccessful response: ${responseData['message']}');
//         }

//         // Try 'values' first, fallback to '$values' for compatibility
//         final List<dynamic> records = responseData['data']?['values'] ??
//             responseData['data']?['\$values'] ??
//             [];

//         if (records.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     'No records found for "$selectedSearchBy: ${_searchController.text.trim()}"')),
//           );
//         } else if (records.length == 1) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => RecordDetailsScreen(
//                 record: records[0],
//                 searchCategory: selectedSearchBy,
//               ),
//             ),
//           );
//         } else {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SearchResultsScreen(
//                 userId: widget.userId,
//                 searchResults: {
//                   'records': records,
//                   'totalCount': responseData['pagination']?['totalRecords'] ??
//                       records.length,
//                   'totalPages': responseData['pagination']?['totalPages'] ?? 1,
//                   'currentPage':
//                       responseData['pagination']?['currentPage'] ?? 1,
//                 },
//                 searchCategory: selectedSearchBy,
//                 searchValue: _searchController.text.trim(),
//                 user: const {},
//               ),
//             ),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   'Error: ${response.statusCode} - ${response.reasonPhrase}')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Network or Parsing Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Fixed Search Section
//             _buildSearchSection(),
//             // Scrollable Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0, vertical: 20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildGridSection(),
//                     const SizedBox(height: 20),
//                     // Responsive row for Inbox, Team, and Notices
//                     LayoutBuilder(builder: (context, constraints) {
//                       bool isWide = constraints.maxWidth > 800;
//                       if (isWide) {
//                         return Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Column(
//                                 children: [
//                                   _buildTeamSection(),
//                                   const SizedBox(height: 16),
//                                   _buildRecentActivitiesSection(),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               flex: 1,
//                               child: _buildNoticesSection(),
//                             ),
//                           ],
//                         );
//                       } else {
//                         return Column(
//                           children: [
//                             _buildTeamSection(),
//                             const SizedBox(height: 20),
//                             _buildRecentActivitiesSection(),
//                             const SizedBox(height: 20),
//                             _buildNoticesSection(),
//                           ],
//                         );
//                       }
//                     }),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchSection() {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: _isSearching
//           ? Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 8),
//                       filled: true,
//                       fillColor: Colors.grey.shade50,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintText: 'Enter $selectedSearchBy',
//                       hintStyle:
//                           TextStyle(color: Colors.grey.shade500, fontSize: 14),
//                     ),
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     onSubmitted: (_) => _performSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 SizedBox(
//                   width: 70,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue.shade600,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       elevation: 1,
//                     ),
//                     onPressed: _isLoading ? null : _performSearch,
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 12,
//                             height: 12,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Search',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w600, fontSize: 12),
//                           ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.red),
//                   onPressed: () {
//                     setState(() {
//                       _isSearching = false;
//                       _searchController.clear();
//                     });
//                   },
//                 ),
//               ],
//             )
//           : Row(
//               children: [
//                 Flexible(
//                   flex: 3,
//                   child: DropdownButtonFormField<String>(
//                     value: selectedSearchBy,
//                     decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 8),
//                       filled: true,
//                       fillColor: Colors.grey.shade50,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     dropdownColor: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     items: <String>[
//                       'PE Number',
//                       'Province',
//                       'Customer',
//                       'SO Number'
//                     ]
//                         .map((value) => DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             ))
//                         .toList(),
//                     onChanged: (newValue) {
//                       if (newValue != null) {
//                         setState(() => selectedSearchBy = newValue);
//                       }
//                       _searchController.clear();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 IconButton(
//                   icon: const Icon(Icons.search, color: Colors.blue),
//                   onPressed: () {
//                     setState(() => _isSearching = true);
//                   },
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildGridSection() {
//     return GridView.count(
//       crossAxisCount: 2,
//       crossAxisSpacing: 10,
//       mainAxisSpacing: 10,
//       childAspectRatio: 1.0,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: [
//         _buildGridItem(
//           context,
//           title: 'Urgent Records',
//           gradientColors: [
//             const Color.fromARGB(255, 247, 155, 154),
//             const Color.fromARGB(255, 193, 102, 102)
//           ],
//           imagePath: 'assets/images/Urgent.png',
//           taskColor: Colors.red.shade400,
//           taskCount: _urgentRecordCount ?? 0,
//           isLoading: _isLoadingUrgentCount,
//           error: _urgentCountError,
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const UrgentRecordScreen(user: {})),
//           ),
//         ),
//         _buildGridItem(
//           context,
//           title: 'Regular Records',
//           gradientColors: [
//             const Color.fromARGB(255, 187, 247, 190),
//             const Color.fromARGB(255, 133, 207, 136)
//           ],
//           imagePath: 'assets/images/Regular.png',
//           taskColor: const Color(0xFF4CAF50),
//           taskCount: _regularRecordCount ?? 0,
//           isLoading: _isLoadingRegularCount,
//           error: _regularCountError,
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const RegularRecordScreen(user: {})),
//           ),
//         ),
//         _buildGridItem(
//           context,
//           title: 'OLA Violate Records',
//           gradientColors: [
//             const Color.fromARGB(255, 192, 201, 253),
//             const Color.fromARGB(255, 128, 134, 206)
//           ],
//           imagePath: 'assets/images/OLA violate.png',
//           taskColor: const Color(0xFF3F51B5),
//           taskCount: _olaViolateCount ?? 0,
//           isLoading: _isLoadingOlaCount,
//           error: _olaCountError,
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const OLAViolateRecordScreen()),
//           ),
//         ),
//         _buildGridItem(
//           context,
//           title: 'Hold Records',
//           gradientColors: [
//             const Color.fromARGB(255, 249, 231, 176),
//             const Color.fromARGB(255, 248, 200, 158)
//           ],
//           imagePath: 'assets/images/Hold.png',
//           taskColor: const Color(0xFFFFA000),
//           taskCount: _holdRecordCount ?? 0,
//           isLoading: _isLoadingHoldCount,
//           error: _holdCountError,
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const HoldRecordScreen()),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTeamSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Color(0xFF90C18E),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.group_outlined,
//                         color: Colors.white, size: 20),
//                     const SizedBox(width: 10),
//                     const Text('Active Team Members',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15)),
//                   ],
//                 ),
//                 const Text('1 active',
//                     style: TextStyle(color: Colors.white70, fontSize: 10)),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     const CircleAvatar(
//                       radius: 18,
//                       backgroundColor: Colors.orange,
//                       child: Icon(Icons.person, color: Colors.white, size: 20),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(_currentUserRole ?? 'User',
//                                 style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey.shade600)),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(_currentUserName ?? 'Member...',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w500, fontSize: 13)),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text('Just now',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30), // Match spacing in screenshot
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentActivitiesSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Color(0xFFC7B1D9),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.list_alt, color: Colors.white, size: 20),
//                 const SizedBox(width: 10),
//                 const Text('Recent Activities',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15)),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Column(
//                   children: [
//                     const Icon(Icons.warning_amber_rounded,
//                         color: Colors.amber, size: 28),
//                     const SizedBox(height: 8),
//                     const Text('OLA (1 day left)',
//                         style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black87)),
//                     const SizedBox(height: 4),
//                     const Text('0',
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black)),
//                     Text('Records',
//                         style: TextStyle(
//                             fontSize: 11, color: Colors.blue.shade700)),
//                   ],
//                 ),
//                 Container(
//                   height: 60,
//                   width: 1,
//                   color: Colors.grey.shade200,
//                 ),
//                 Column(
//                   children: [
//                     const Icon(Icons.article_outlined,
//                         color: Colors.blue, size: 28),
//                     const SizedBox(height: 8),
//                     const Text('Total Tasks',
//                         style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black87)),
//                     const SizedBox(height: 4),
//                     Text('$_totalTasks',
//                         style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black)),
//                     Text('Tasks',
//                         style: TextStyle(
//                             fontSize: 11, color: Colors.blue.shade700)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoticesSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Color(0xFFF9C16D), // Yellowish/Orange from screenshot
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.assignment_outlined,
//                         color: Colors.white, size: 20),
//                     const SizedBox(width: 10),
//                     const Text('Notice Board',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15)),
//                   ],
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.more_vert,
//                       color: Colors.white, size: 20),
//                   onPressed: _showNoticeSummaryDialog,
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 if (_isLoadingNotices)
//                   const Center(child: CircularProgressIndicator())
//                 else if (_notices == null || _notices!.isEmpty)
//                   Column(
//                     children: [
//                       const SizedBox(height: 20),
//                       Icon(Icons.assignment_outlined,
//                           size: 40, color: Colors.grey.shade300),
//                       const SizedBox(height: 12),
//                       const Text('No Active Notices',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey,
//                               fontSize: 14)),
//                       const Text('Check back later for updates',
//                           style: TextStyle(color: Colors.grey, fontSize: 11)),
//                       const SizedBox(height: 20),
//                     ],
//                   )
//                 else
//                   ..._notices!.map((notice) {
//                     final bool isPinned = notice.isPinned ?? false;
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border(
//                           left: BorderSide(
//                               color: Colors.orange.shade400, width: 4),
//                         ),
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 4),
//                         onTap: () => _showNoticeDialog(notice),
//                         title: Row(
//                           children: [
//                             if (isPinned)
//                               Icon(Icons.push_pin,
//                                   color: Colors.orange.shade400, size: 18),
//                             if (isPinned) const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 notice.description?.split('\n').first ??
//                                     'No Title',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 14),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 4),
//                             Text(
//                               notice.description?.contains('\n\n') == true
//                                   ? notice.description!.split('\n\n').last
//                                   : (notice.description ?? ''),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                   color: Colors.grey.shade700, fontSize: 12),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'By: ${notice.createdUserName ?? 'Development Admin'}',
//                               style: TextStyle(
//                                   color: Colors.grey.shade500, fontSize: 10),
//                             ),
//                           ],
//                         ),
//                         trailing: PopupMenuButton<String>(
//                           icon: const Icon(Icons.more_vert, size: 20),
//                           onSelected: (value) {
//                             if (value == 'pin') {
//                               _togglePinStatus(notice);
//                             } else if (value == 'delete') {
//                               _deleteNotice(notice);
//                             }
//                           },
//                           itemBuilder: (context) => [
//                             PopupMenuItem(
//                               value: 'pin',
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                       isPinned
//                                           ? Icons.push_pin_outlined
//                                           : Icons.push_pin,
//                                       size: 18,
//                                       color: Colors.black87),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                       isPinned ? 'Unpin Notice' : 'Pin Notice'),
//                                 ],
//                               ),
//                             ),
//                             PopupMenuItem(
//                               value: 'delete',
//                               child: Row(
//                                 children: [
//                                   const Icon(Icons.delete_outline,
//                                       size: 18, color: Colors.red),
//                                   const SizedBox(width: 8),
//                                   const Text('Delete Notice',
//                                       style: TextStyle(color: Colors.red)),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridItem(
//     BuildContext context, {
//     required String title,
//     required List<Color> gradientColors,
//     required String imagePath,
//     required Color taskColor,
//     required int taskCount,
//     bool isLoading = false,
//     String? error,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradientColors,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             Expanded(
//               child: Center(
//                 child: Image.asset(
//                   imagePath,
//                   height: 70,
//                   width: 70,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) => const Icon(
//                     Icons.error,
//                     color: Colors.red,
//                     size: 30,
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 4,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: isLoading
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.blue),
//                         ),
//                       )
//                     : Text(
//                         error != null
//                             ? 'Error'
//                             : '$taskCount Task${taskCount == 1 ? '' : 's'}',
//                         style: TextStyle(
//                           color: error != null ? Colors.red : taskColor,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showNoticeSummaryDialog() {
//     int total = _notices?.length ?? 0;
//     int pinned = _notices?.where((n) => n.isPinned ?? false).length ?? 0;
//     int active = _notices?.where((n) => n.isActive ?? true).length ?? 0;
//     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Notice Board Summary',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _summaryItem('Total Notices', total.toString(), Icons.assignment),
//             _summaryItem(
//                 'Active Notices', active.toString(), Icons.check_circle,
//                 color: Colors.green),
//             _summaryItem('Pinned Notices', pinned.toString(), Icons.push_pin,
//                 color: Colors.blue),
//             _summaryItem('Today\'s Date', today, Icons.calendar_today),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.add),
//                 label: const Text('Create New Notice'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade700,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _showCreateNoticeDialog();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _summaryItem(String label, String value, IconData icon,
//       {Color? color}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: color ?? Colors.grey.shade600),
//           const SizedBox(width: 12),
//           Text(label, style: const TextStyle(fontSize: 14)),
//           const Spacer(),
//           Text(value,
//               style:
//                   const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   void _showCreateNoticeDialog() {
//     final titleController = TextEditingController();
//     final messageController = TextEditingController();
//     DateTime startDate = DateTime.now();
//     DateTime? endDate;
//     bool isPinned = false;
//     bool isActive = true;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
//         return AlertDialog(
//           insetPadding: const EdgeInsets.all(10),
//           contentPadding: EdgeInsets.zero,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: const BoxDecoration(
//               color: Colors.blue,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//             ),
//             child: const Text('Create New Notice',
//                 style: TextStyle(color: Colors.white, fontSize: 18)),
//           ),
//           titlePadding: EdgeInsets.zero,
//           content: Container(
//             width: MediaQuery.of(context).size.width * 0.9,
//             padding: const EdgeInsets.all(16),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Notice Title *',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: titleController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter notice title',
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 12),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text('Notice Message *',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: messageController,
//                     maxLines: 4,
//                     decoration: InputDecoration(
//                       hintText: 'Enter notice message',
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('Start Date *',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 8),
//                             InkWell(
//                               onTap: () async {
//                                 final date = await showDatePicker(
//                                   context: context,
//                                   initialDate: startDate,
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2100),
//                                 );
//                                 if (date != null) {
//                                   setDialogState(() => startDate = date);
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 12),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(DateFormat('MM/dd/yyyy')
//                                         .format(startDate)),
//                                     const Icon(Icons.calendar_today, size: 16),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('End Date (Optional)',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 8),
//                             InkWell(
//                               onTap: () async {
//                                 final date = await showDatePicker(
//                                   context: context,
//                                   initialDate: endDate ?? DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2100),
//                                 );
//                                 if (date != null) {
//                                   setDialogState(() => endDate = date);
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 12),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(endDate != null
//                                         ? DateFormat('MM/dd/yyyy')
//                                             .format(endDate!)
//                                         : 'mm/dd/yyyy'),
//                                     const Icon(Icons.calendar_today, size: 16),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   const Text('Leave empty for notices without expiry',
//                       style: TextStyle(fontSize: 10, color: Colors.grey)),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: isPinned,
//                         onChanged: (v) => setDialogState(() => isPinned = v!),
//                       ),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Pin this notice',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             Text('Pinned notices appear at the top',
//                                 style: TextStyle(
//                                     fontSize: 10, color: Colors.grey)),
//                           ],
//                         ),
//                       ),
//                       Checkbox(
//                         value: isActive,
//                         onChanged: (v) => setDialogState(() => isActive = v!),
//                       ),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Active',
//                                 style: TextStyle(fontWeight: FontWeight.bold)),
//                             Text('Active notices are visible to users',
//                                 style: TextStyle(
//                                     fontSize: 10, color: Colors.grey)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       OutlinedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                         ),
//                         child: const Text('Back to List'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (titleController.text.trim().isEmpty ||
//                               messageController.text.trim().isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content:
//                                       Text('Title and Message are required')),
//                             );
//                             return;
//                           }

//                           // Combine Title and Message into Description
//                           String description =
//                               '${titleController.text.trim()}\n\n${messageController.text.trim()}';

//                           final success = await _noticeService.createNotice({
//                             'description': description,
//                             'isPinned': isPinned,
//                             'isActive': isActive,
//                             'createdDate': startDate.toIso8601String(),
//                             'expireDate': endDate?.toIso8601String(),
//                             'createdBy': widget.userId,
//                             'createdUserName': _currentUserName ?? 'Unknown',
//                           });

//                           if (success) {
//                             debugPrint(
//                                 'Notice created successfully, refreshing...');
//                             if (mounted) Navigator.pop(context);
//                             _fetchNotices(); // Refresh list
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content:
//                                         Text('Notice created successfully')),
//                               );
//                             }
//                           } else {
//                             debugPrint(
//                                 'Notice creation failed according to service.');
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text('Failed to create notice')),
//                               );
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 12),
//                         ),
//                         child: const Text('Create Notice'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   void _showNoticeDialog(Notice notice) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             if (notice.isPinned ?? false)
//               const Icon(Icons.push_pin, color: Colors.blue, size: 20),
//             if (notice.isPinned ?? false) const SizedBox(width: 8),
//             const Text('Notice Details',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 notice.description ?? 'No description',
//                 style: const TextStyle(fontSize: 16, color: Colors.black87),
//               ),
//               const SizedBox(height: 16),
//               Divider(color: Colors.grey.shade300),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.person_outline,
//                       size: 16, color: Colors.grey.shade600),
//                   const SizedBox(width: 4),
//                   Text(
//                     'By: ${notice.createdUserName ?? 'System'}',
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today_outlined,
//                       size: 16, color: Colors.grey.shade600),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Date: ${notice.createdDate?.toString().substring(0, 10) ?? 'Unknown'}',
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close',
//                 style: TextStyle(fontWeight: FontWeight.w600)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _togglePinStatus(Notice notice) async {
//     if (notice.id == null) return;

//     final updatedPinned = !(notice.isPinned ?? false);
//     final success = await _noticeService.updateNotice(notice.id!, {
//       'id': notice.id,
//       'description': notice.description,
//       'isPinned': updatedPinned,
//       'isActive': notice.isActive,
//       'createdDate': notice.createdDate?.toIso8601String(),
//       'expireDate': notice.expireDate?.toIso8601String(),
//       'createdBy': notice.createdBy,
//       'createdUserName': notice.createdUserName,
//     });

//     if (success) {
//       _fetchNotices(); // Refresh list
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to update pin status')),
//         );
//       }
//     }
//   }

//   Future<void> _deleteNotice(Notice notice) async {
//     if (notice.id == null) return;

//     // Show confirmation dialog
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Notice'),
//         content: const Text('Are you sure you want to delete this notice?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       final success = await _noticeService.deleteNotice(notice.id!);
//       if (success) {
//         _fetchNotices(); // Refresh list
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to delete notice')),
//           );
//         }
//       }
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../service/OLAViolateRecordService.dart';
import '../service/RegularRecordService.dart';
import '../service/UrgentRecordService.dart';
import '../service/HoldRecordService.dart';
import '../service/TaskQueueService.dart';
import '../service/NoticeService.dart';
import '../model/Notice.dart';
import 'RecordDetailsScreen.dart';
import 'SearchResultsScreen.dart';
import 'UrgentRecordScreen.dart';
import 'RegularRecordScreen.dart';
import 'OLAViolateRecordScreen.dart';
import 'HoldRecordScreen.dart';
import '../service/AuthService.dart';

class DashboardHome extends StatefulWidget {
  final int userId;
  final List<int> selectedWorkGroupIds;
  final String? userName;
  final String? userRole;
  const DashboardHome({
    super.key,
    required this.userId,
    this.selectedWorkGroupIds = const [],
    this.userName,
    this.userRole,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  String selectedSearchBy = 'PE Number';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;

  int? _olaViolateCount;
  bool _isLoadingOlaCount = false;
  String? _olaCountError;

  int? _regularRecordCount;
  bool _isLoadingRegularCount = false;
  String? _regularCountError;

  int? _urgentRecordCount;
  bool _isLoadingUrgentCount = false;
  String? _urgentCountError;

  int? _holdRecordCount;
  bool _isLoadingHoldCount = false;
  String? _holdCountError;

  List<Notice>? _notices;
  bool _isLoadingNotices = false;
  String? _noticesError;

  final OLAViolateRecordService _olaService = OLAViolateRecordService();
  final RegularRecordService _regularService = RegularRecordService();
  final UrgentRecordService _urgentService = UrgentRecordService();
  final HoldRecordService _holdService = HoldRecordService();
  final TaskQueueService taskQueueService = TaskQueueService();
  final NoticeService _noticeService = NoticeService();
  final AuthService _authService = AuthService();

  String? _currentUserName;
  String? _currentUserRole;
  int _totalTasks = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _checkWorkgroupAndRefresh();
    _fetchNotices();
  }

  bool _useRealData = false;
  String? _selectedWorkgroupName;

  void _checkWorkgroupAndRefresh() async {
    if (widget.selectedWorkGroupIds.isNotEmpty) {
      try {
        final wgs = await _authService.getWorkGroupsByIds(widget.selectedWorkGroupIds);
        if (wgs.isNotEmpty) {
          _selectedWorkgroupName = wgs.first.name;
          setState(() {
            _useRealData = (_selectedWorkgroupName != 'NET-PROJ_CABLE-ACC' && 
                            _selectedWorkgroupName != 'NET-PROJ-ACC-CABLE');
          });
        }
      } catch (e) {
        debugPrint('Error fetching workgroups for dashboard: $e');
      }
    } else {
      setState(() {
        _useRealData = false;
      });
    }
    _refreshAllCounts();
  }

  @override
  void didUpdateWidget(covariant DashboardHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if selected workgroups changed
    bool workgroupsChanged = false;
    if (oldWidget.selectedWorkGroupIds.length !=
        widget.selectedWorkGroupIds.length) {
      workgroupsChanged = true;
    } else {
      for (int i = 0; i < widget.selectedWorkGroupIds.length; i++) {
        if (oldWidget.selectedWorkGroupIds[i] !=
            widget.selectedWorkGroupIds[i]) {
          workgroupsChanged = true;
          break;
        }
      }
    }

    if (workgroupsChanged) {
      _checkWorkgroupAndRefresh();
    }

    // Check if user info updated (e.g. from null to value after DashboardScreen finishes loading)
    if (oldWidget.userName != widget.userName ||
        oldWidget.userRole != widget.userRole) {
      setState(() {
        _currentUserName = widget.userName;
        _currentUserRole = widget.userRole;
      });
    }
  }

  void _refreshAllCounts() {
    _fetchOlaViolateCount();
    _fetchRegularRecordCount();
    _fetchUrgentRecordCount();
    _fetchHoldRecordCount();
  }

  Future<void> _fetchUserInfo() async {
    // If name and role are passed via parameters, use them
    if (widget.userName != null || widget.userRole != null) {
      setState(() {
        _currentUserName = widget.userName;
        _currentUserRole = widget.userRole;
      });
      return;
    }

    try {
      final user = await _authService.getUserById(widget.userId);
      final roles = await _authService.getUserRoles();
      if (user != null && mounted) {
        final role = roles.firstWhere((r) => r.id == user.userRoleId,
            orElse: () =>
                roles.isNotEmpty ? roles.first : roles.first); // fallback
        setState(() {
          _currentUserName = user.name;
          _currentUserRole = role.name;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
  }

  void _calculateTotalTasks() {
    setState(() {
      _totalTasks = (_urgentRecordCount ?? 0) +
          (_regularRecordCount ?? 0) +
          (_olaViolateCount ?? 0) +
          (_holdRecordCount ?? 0);
    });
  }

  int? get _selectedWorkGroupId {
    // If only one workgroup is selected, return its ID
    if (widget.selectedWorkGroupIds.length == 1) {
      return widget.selectedWorkGroupIds.first;
    }
    // If multiple or zero workgroups are selected (e.g. "All"), return null
    // to let the backend fetch for all user's workgroups.
    return null;
  }

  Future<void> _fetchOlaViolateCount() async {
    setState(() {
      _isLoadingOlaCount = true;
      _olaCountError = null;
    });
    try {
      final result = await _olaService.fetchOLAViolateRecords(
        page: 1,
        pageSize: 2000,
        workgroupId: _selectedWorkGroupId,
        fetchMultiWorkgroup: _useRealData,
      );
      setState(() {
        _olaViolateCount = result['totalCount'] ?? 0;
        _isLoadingOlaCount = false;
        _calculateTotalTasks();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _olaCountError = 'Failed to load OLA count: $e';
          _isLoadingOlaCount = false;
        });
        debugPrint(_olaCountError);
      }
    }
  }

  Future<void> _fetchRegularRecordCount() async {
    setState(() {
      _isLoadingRegularCount = true;
      _regularCountError = null;
    });
    try {
      final result = await _regularService.fetchRegularRecords(
        page: 1,
        pageSize: 2000,
        workgroupName: _selectedWorkGroupId?.toString(),
        fetchMultiWorkgroup: _useRealData,
      );
      setState(() {
        _regularRecordCount = result['totalCount'] ?? 0;
        _isLoadingRegularCount = false;
        _calculateTotalTasks();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _regularCountError = 'Failed to load regular count: $e';
          _isLoadingRegularCount = false;
        });
        debugPrint(_regularCountError);
      }
    }
  }

  Future<void> _fetchUrgentRecordCount() async {
    setState(() {
      _isLoadingUrgentCount = true;
      _urgentCountError = null;
    });
    try {
      final result = await _urgentService.fetchUrgentRecords(
        page: 1,
        pageSize: 2000,
        workgroupId: _selectedWorkGroupId,
        fetchMultiWorkgroup: _useRealData,
      );
      setState(() {
        _urgentRecordCount = result['totalCount'] ?? 0;
        _isLoadingUrgentCount = false;
        _calculateTotalTasks();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _urgentCountError = 'Failed to load urgent count: $e';
          _isLoadingUrgentCount = false;
        });
        debugPrint(_urgentCountError);
      }
    }
  }

  Future<void> _fetchHoldRecordCount() async {
    setState(() {
      _isLoadingHoldCount = true;
      _holdCountError = null;
    });
    try {
      final result = await _holdService.fetchHoldRecords(
        page: 1,
        pageSize: 2000,
        workgroupId: _selectedWorkGroupId,
        fetchMultiWorkgroup: _useRealData,
      );
      final List records = result['records'] ?? [];
      setState(() {
        _holdRecordCount = records.length;
        _isLoadingHoldCount = false;
        _calculateTotalTasks();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _holdCountError = 'Failed to load hold count: $e';
          _isLoadingHoldCount = false;
        });
        debugPrint(_holdCountError);
      }
    }
  }

  Future<void> _fetchNotices() async {
    setState(() {
      _isLoadingNotices = true;
      _noticesError = null;
    });
    try {
      final notices = await _noticeService.getActiveNotices();
      if (mounted) {
        setState(() {
          _notices = notices;
          _isLoadingNotices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _noticesError = 'Failed to load notices: $e';
          _isLoadingNotices = false;
        });
        debugPrint(_noticesError);
      }
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search value')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String query =
          '$apiUrl/api/PERecordsApi/filter?page=1&pageSize=1000&searchCategory=${Uri.encodeComponent(selectedSearchBy)}&searchValue=${Uri.encodeComponent(_searchController.text.trim())}';
      debugPrint('API Request URL: $query');

      final response = await http.get(
        Uri.parse(query),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['ACCESS_TOKEN'] ?? ''}',
        },
      );

      debugPrint('Raw API Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] != true) {
          throw Exception(
              'API returned unsuccessful response: ${responseData['message']}');
        }

        // Try 'values' first, fallback to '$values' for compatibility
        final List<dynamic> records = responseData['data']?['values'] ??
            responseData['data']?['\$values'] ??
            [];

        if (records.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'No records found for "$selectedSearchBy: ${_searchController.text.trim()}"')),
          );
        } else if (records.length == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordDetailsScreen(
                record: records[0],
                searchCategory: selectedSearchBy,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                userId: widget.userId,
                searchResults: {
                  'records': records,
                  'totalCount': responseData['pagination']?['totalRecords'] ??
                      records.length,
                  'totalPages': responseData['pagination']?['totalPages'] ?? 1,
                  'currentPage':
                      responseData['pagination']?['currentPage'] ?? 1,
                },
                searchCategory: selectedSearchBy,
                searchValue: _searchController.text.trim(),
                user: const {},
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${response.statusCode} - ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      debugPrint('Network or Parsing Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Search Section
            _buildSearchSection(),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGridSection(),
                    const SizedBox(height: 20),
                    // Responsive row for Inbox, Team, and Notices
                    LayoutBuilder(builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 800;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTeamSection()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRecentActivitiesSection()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildNoticesSection()),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _buildTeamSection()),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildRecentActivitiesSection()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildNoticesSection(),
                          ],
                        );
                      }
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isSearching
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter $selectedSearchBy',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 1,
                    ),
                    onPressed: _isLoading ? null : _performSearch,
                    child: _isLoading
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Search',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                ),
              ],
            )
          : Row(
              children: [
                Flexible(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSearchBy,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    items: <String>[
                      'PE Number',
                      'Province',
                      'Customer',
                      'SO Number'
                    ]
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => selectedSearchBy = newValue);
                      }
                      _searchController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    setState(() => _isSearching = true);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildGridSection() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildGridItem(
          context,
          title: 'Urgent Requests',
          gradientColors: [
            const Color.fromARGB(255, 247, 155, 154),
            const Color.fromARGB(255, 193, 102, 102)
          ],
          imagePath: 'assets/images/Urgent.png',
          taskColor: Colors.red.shade400,
          taskCount: _urgentRecordCount ?? 0,
          isLoading: _isLoadingUrgentCount,
          error: _urgentCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UrgentRecordScreen(
                user: const {},
                workgroupId: _selectedWorkGroupId,
                useRealData: _useRealData,
              ),
            ),
          ),
        ),
        _buildGridItem(
          context,
          title: 'In Progress',
          gradientColors: [
            const Color.fromARGB(255, 187, 247, 190),
            const Color.fromARGB(255, 133, 207, 136)
          ],
          imagePath: 'assets/images/Regular.png',
          taskColor: const Color(0xFF4CAF50),
          taskCount: _regularRecordCount ?? 0,
          isLoading: _isLoadingRegularCount,
          error: _regularCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegularRecordScreen(
                user: const {},
                workgroupName: _selectedWorkGroupId?.toString(),
                useRealData: _useRealData,
              ),
            ),
          ),
        ),
        _buildGridItem(
          context,
          title: 'OLA Violated',
          gradientColors: [
            const Color.fromARGB(255, 192, 201, 253),
            const Color.fromARGB(255, 128, 134, 206)
          ],
          imagePath: 'assets/images/OLA violate.png',
          taskColor: const Color(0xFF3F51B5),
          taskCount: _olaViolateCount ?? 0,
          isLoading: _isLoadingOlaCount,
          error: _olaCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OLAViolateRecordScreen(
                user: const {},
                workgroupId: _selectedWorkGroupId,
                useRealData: _useRealData,
              ),
            ),
          ),
        ),
        _buildGridItem(
          context,
          title: 'Hold Records',
          gradientColors: [
            const Color.fromARGB(255, 249, 231, 176),
            const Color.fromARGB(255, 248, 200, 158)
          ],
          imagePath: 'assets/images/Hold.png',
          taskColor: const Color(0xFFFFA000),
          taskCount: _holdRecordCount ?? 0,
          isLoading: _isLoadingHoldCount,
          error: _holdCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HoldRecordScreen(
                workgroupId: _selectedWorkGroupId,
                useRealData: _useRealData,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF90C18E),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.group_outlined, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text('Active Team',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Text('1 active',
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.person, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(_currentUserRole ?? 'User',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600)),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Just now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(_currentUserName ?? 'Member...',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFC7B1D9),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.list_alt, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Activities',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.amber, size: 24),
                      const SizedBox(height: 6),
                      const Text('OLA Violate',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      const Text('0',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Text('Records',
                          style: TextStyle(
                              fontSize: 10, color: Colors.blue.shade700)),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.article_outlined,
                          color: Colors.blue, size: 24),
                      const SizedBox(height: 6),
                      const Text('Total Tasks',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text('$_totalTasks',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Text('Tasks',
                          style: TextStyle(
                              fontSize: 10, color: Colors.blue.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9C16D), // Yellowish/Orange from screenshot
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment_outlined,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Notice Board',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white, size: 20),
                  onPressed: _showNoticeSummaryDialog,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (_isLoadingNotices)
                  const Center(child: CircularProgressIndicator())
                else if (_notices == null || _notices!.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(Icons.assignment_outlined,
                          size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('No Active Notices',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14)),
                      const Text('Check back later for updates',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 20),
                    ],
                  )
                else
                  ..._notices!.map((notice) {
                    final bool isPinned = notice.isPinned ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                              color: Colors.orange.shade400, width: 4),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        onTap: () => _showNoticeDialog(notice),
                        title: Row(
                          children: [
                            if (isPinned)
                              Icon(Icons.push_pin,
                                  color: Colors.orange.shade400, size: 18),
                            if (isPinned) const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                notice.description?.split('\n').first ??
                                    'No Title',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notice.description?.contains('\n\n') == true
                                  ? notice.description!.split('\n\n').last
                                  : (notice.description ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By: ${notice.createdUserName ?? 'Development Admin'}',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 10),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            if (value == 'pin') {
                              _togglePinStatus(notice);
                            } else if (value == 'delete') {
                              _deleteNotice(notice);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'pin',
                              child: Row(
                                children: [
                                  Icon(
                                      isPinned
                                          ? Icons.push_pin_outlined
                                          : Icons.push_pin,
                                      size: 18,
                                      color: Colors.black87),
                                  const SizedBox(width: 8),
                                  Text(
                                      isPinned ? 'Unpin Notice' : 'Pin Notice'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete Notice',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required List<Color> gradientColors,
    required String imagePath,
    required Color taskColor,
    required int taskCount,
    bool isLoading = false,
    String? error,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  imagePath,
                  height: 70,
                  width: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : Text(
                        error != null
                            ? 'Error'
                            : '$taskCount Task${taskCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: error != null ? Colors.red : taskColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoticeSummaryDialog() {
    int total = _notices?.length ?? 0;
    int pinned = _notices?.where((n) => n.isPinned ?? false).length ?? 0;
    int active = _notices?.where((n) => n.isActive ?? true).length ?? 0;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Notice Board Summary',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryItem('Total Notices', total.toString(), Icons.assignment),
            _summaryItem(
                'Active Notices', active.toString(), Icons.check_circle,
                color: Colors.green),
            _summaryItem('Pinned Notices', pinned.toString(), Icons.push_pin,
                color: Colors.blue),
            _summaryItem('Today\'s Date', today, Icons.calendar_today),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create New Notice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateNoticeDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _showCreateNoticeDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    bool isPinned = false;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Text('Create New Notice',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          titlePadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notice Title *',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter notice title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Notice Message *',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter notice message',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date *',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setDialogState(() => startDate = date);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(DateFormat('MM/dd/yyyy')
                                        .format(startDate)),
                                    const Icon(Icons.calendar_today, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date (Optional)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: endDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setDialogState(() => endDate = date);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(endDate != null
                                        ? DateFormat('MM/dd/yyyy')
                                            .format(endDate!)
                                        : 'mm/dd/yyyy'),
                                    const Icon(Icons.calendar_today, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Leave empty for notices without expiry',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isPinned,
                        onChanged: (v) => setDialogState(() => isPinned = v!),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pin this notice',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Pinned notices appear at the top',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isActive,
                        onChanged: (v) => setDialogState(() => isActive = v!),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Active',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Active notices are visible to users',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Back to List'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty ||
                              messageController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Title and Message are required')),
                            );
                            return;
                          }

                          // Combine Title and Message into Description
                          String description =
                              '${titleController.text.trim()}\n\n${messageController.text.trim()}';

                          final success = await _noticeService.createNotice({
                            'description': description,
                            'isPinned': isPinned,
                            'isActive': isActive,
                            'createdDate': startDate.toIso8601String(),
                            'expireDate': endDate?.toIso8601String(),
                            'createdBy': widget.userId,
                            'createdUserName': _currentUserName ?? 'Unknown',
                          });

                          if (success) {
                            debugPrint(
                                'Notice created successfully, refreshing...');
                            if (mounted) Navigator.pop(context);
                            _fetchNotices(); // Refresh list
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Notice created successfully')),
                              );
                            }
                          } else {
                            debugPrint(
                                'Notice creation failed according to service.');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to create notice')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Create Notice'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showNoticeDialog(Notice notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            if (notice.isPinned ?? false)
              const Icon(Icons.push_pin, color: Colors.blue, size: 20),
            if (notice.isPinned ?? false) const SizedBox(width: 8),
            const Text('Notice Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.description ?? 'No description',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'By: ${notice.createdUserName ?? 'System'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Date: ${notice.createdDate?.toString().substring(0, 10) ?? 'Unknown'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePinStatus(Notice notice) async {
    if (notice.id == null) return;

    final updatedPinned = !(notice.isPinned ?? false);
    final userName = widget.userName ?? _currentUserName ?? 'Unknown';
    final success = await _noticeService.togglePinNotice(
      notice.id!,
      updatedPinned,
      widget.userId,
      userName,
    );

    if (success) {
      _fetchNotices(); // Refresh list
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update pin status')),
        );
      }
    }
  }

  Future<void> _deleteNotice(Notice notice) async {
    if (notice.id == null) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: const Text('Are you sure you want to delete this notice?'),
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

    if (confirm == true) {
      final userName = widget.userName ?? _currentUserName ?? 'Unknown';
      final success = await _noticeService.deleteNotice(
        notice.id!,
        widget.userId,
        userName,
      );
      if (success) {
        _fetchNotices(); // Refresh list
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete notice')),
          );
        }
      }
    }
  }
}

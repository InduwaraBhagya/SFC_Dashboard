// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../service/AuthService.dart';
// import '../model/UserRole.dart';
// import 'ProfileScreen.dart';
// import 'DashboardHome.dart';
// import 'ProjectScreen.dart';
// import 'WorkGroupScreen.dart';
// import 'AreaNetworkEngineerScreen.dart';
// import 'PEIssueScreen.dart';
// import 'CreatePEScreen.dart';
// import 'PEDetailsSearchScreen.dart';
// import 'TaskQueueScreen.dart';
// import 'PEReportScreen.dart';
// import 'EscalationScreen.dart';
// import 'SystemUsersScreen.dart';
// import '../../OnboardingScreen.dart';
// import 'dart:async';
// import '../service/PEIssueService.dart';
// import '../service/UrgentRecordService.dart';
// import '../service/NoticeService.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../SigninScreen.dart';

// class DashboardScreen extends StatefulWidget {
//   final int userId;

//   const DashboardScreen({super.key, required this.userId});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final AuthService _authService = AuthService();
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   int myIndex = 0;

//   // User data
//   String? name;
//   String? photoBase64;
//   String? userRoleName;
//   int? userId;
//   int? userRoleId;
//   List<int>? workGroupIds;
//   List<String>? workGroupNames;

//   // Notification counts
//   int _totalAlertsCount = 0;
//   Timer? _notificationTimer;
//   final PEService _peIssueService = PEService();
//   final UrgentRecordService _urgentRecordService = UrgentRecordService();
//   final NoticeService _noticeService = NoticeService(
//     accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
//   );

//   // Loading/Error states
//   bool isLoading = true;
//   String? errorMessage;

//   late final List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize pages
//     _pages = [
//       DashboardHome(userId: widget.userId),
//       PEIssuesScreen(
//           userId: widget.userId,
//           workGroupIds: workGroupIds ?? [],
//           onRefreshCounts: _fetchNotificationCounts),
//       WorkGroupScreen(userId: widget.userId),
//       ProjectScreen(userId: widget.userId),
//       AreaNetworkEngineerScreen(userId: widget.userId),
//     ];

//     fetchUserProfile();
//     _startNotificationTimer();
//   }

//   @override
//   void dispose() {
//     _notificationTimer?.cancel();
//     super.dispose();
//   }

//   void _startNotificationTimer() {
//     _fetchNotificationCounts(); // Initial fetch
//     _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       _fetchNotificationCounts();
//     });
//   }

//   Future<void> _fetchNotificationCounts() async {
//     try {
//       final storedUserId = await _storage.read(key: 'userId');
//       if (storedUserId == null) return;
//       final bUserId = int.tryParse(storedUserId);
//       if (bUserId == null) return;

//       int counts = 0;

//       final prefs = await SharedPreferences.getInstance();
//       final seenNotices = prefs.getStringList('seen_notices') ?? [];
//       final seenUrgent = prefs.getStringList('seen_urgent') ?? [];

//       // 1. Fetch unread issues
//       try {
//         final issues = await _peIssueService.getInboxIssues(bUserId, 50);
//         counts += issues.where((i) => !(i.isRead ?? true)).length;
//       } catch (e) {
//         debugPrint('Error fetching unread issues for badge: $e');
//       }

//       // 2. Fetch urgent records count
//       try {
//         final urgentResult = await _urgentRecordService.fetchUrgentRecords(
//           page: 1,
//           pageSize: 20,
//         );
//         final List records = urgentResult['records'] ?? [];
//         counts += records.where((r) => !seenUrgent.contains(r.peNumber)).length;
//       } catch (e) {
//         debugPrint('Error fetching urgent records for badge: $e');
//       }

//       // 3. Fetch active notices count
//       try {
//         final notices = await _noticeService.getActiveNotices();
//         counts +=
//             notices.where((n) => !seenNotices.contains(n.id.toString())).length;
//       } catch (e) {
//         debugPrint('Error fetching notices for badge: $e');
//       }

//       if (mounted) {
//         setState(() {
//           _totalAlertsCount = counts;
//         });
//       }
//     } catch (e) {
//       debugPrint('General error in _fetchNotificationCounts: $e');
//     }
//   }

//   Future<void> fetchUserProfile() async {
//     try {
//       final azureUser = await _authService.getCurrentUser();
//       if (azureUser == null) throw Exception('User not logged in');

//       setState(() {
//         name = azureUser['Name'];
//         photoBase64 = azureUser['PhotoBase64'];
//       });

//       final storedUserId = await _storage.read(key: 'userId');
//       if (storedUserId == null) throw Exception('Backend UserId not found');

//       final backendUserId = int.tryParse(storedUserId);
//       if (backendUserId == null) throw Exception('Invalid UserId in storage');

//       final backendUser = await _authService.getUserById(backendUserId);
//       if (backendUser == null) throw Exception('Backend user not found');

//       final userRoles = await _authService.getUserRoles();
//       final userRoleName = backendUser.userRoleId != null
//           ? userRoles
//               .firstWhere(
//                 (role) => role.id == backendUser.userRoleId,
//                 orElse: () => UserRole(id: 0, name: 'Unknown Role'),
//               )
//               .name
//           : 'User';

//       final workgroupData =
//           await _authService.getCurrentUserWorkgroupsWithPermissions();
//       final workGroupNames =
//           workgroupData != null && workgroupData['userWorkgroupNames'] != null
//               ? (workgroupData['userWorkgroupNames'] as List<dynamic>)
//                   .cast<String>()
//               : <String>[];

//       setState(() {
//         userId = backendUser.id;
//         userRoleId = backendUser.userRoleId;
//         workGroupIds = backendUser.workGroupIds;
//         this.userRoleName = userRoleName;
//         this.workGroupNames = workGroupNames;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString().replaceFirst('Exception: ', '');
//         isLoading = false;
//       });
//     }
//   }

//   void _openEndDrawer() {
//     _scaffoldKey.currentState?.openEndDrawer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OnboardingScreen(userId: widget.userId),
//           ),
//         );
//         return false;
//       },
//       child: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           toolbarHeight: 90,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 5,
//           systemOverlayStyle: const SystemUiOverlayStyle(
//             statusBarColor: Colors.transparent,
//             statusBarIconBrightness: Brightness.light,
//           ),
//           automaticallyImplyLeading: false,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => OnboardingScreen(userId: widget.userId),
//                 ),
//               );
//             },
//           ),
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Planned Event',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 // (workGroupNames != null && workGroupNames!.isNotEmpty)
//                 //     ? workGroupNames!.join(', ')
//                 //     : 'No Workgroup',
//                 "NET-PLAN-ACC",
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.menu, color: Colors.white),
//               onPressed: _openEndDrawer,
//             ),
//           ],
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color.fromARGB(226, 16, 37, 89),
//                   Color.fromARGB(255, 8, 11, 66),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//         ),
//         body: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : errorMessage != null
//                 ? Center(
//                     child: Text(
//                       errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   )
//                 : _pages[myIndex],
//         endDrawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               DrawerHeader(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color.fromARGB(226, 16, 37, 89),
//                       Color.fromARGB(255, 8, 11, 66),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.grey[300],
//                       backgroundImage:
//                           (photoBase64 != null && photoBase64!.isNotEmpty)
//                               ? MemoryImage(base64Decode(photoBase64!))
//                               : null,
//                       child: (photoBase64 == null || photoBase64!.isEmpty)
//                           ? Text(
//                               name?.substring(0, 1).toUpperCase() ?? 'U',
//                               style: const TextStyle(
//                                   fontSize: 24, fontWeight: FontWeight.bold),
//                             )
//                           : null,
//                     ),
//                     const SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           name ?? 'Guest',
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 20),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.person),
//                 title: const Text('Profile'),
//                 onTap: () {
//                   setState(() => myIndex = 0);
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                   );
//                 },
//               ),
//               // PE Management Section
//               ExpansionTile(
//                 leading: const Icon(
//                   Icons.event_note,
//                   color: Color.fromARGB(226, 16, 37, 89),
//                 ),
//                 title: const Text(
//                   'PE Management',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Color.fromARGB(226, 16, 37, 89),
//                   ),
//                 ),
//                 children: [
//                   ListTile(
//                     contentPadding:
//                         const EdgeInsets.only(left: 56.0, right: 16.0),
//                     leading: const Icon(
//                       Icons.add_circle_outline,
//                       color: Colors.green,
//                       size: 20,
//                     ),
//                     title: const Text('Create PE'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const CreatePEScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     contentPadding:
//                         const EdgeInsets.only(left: 56.0, right: 16.0),
//                     leading: const Icon(
//                       Icons.task,
//                       color: Colors.deepPurpleAccent,
//                       size: 20,
//                     ),
//                     title: const Text('Task Queue'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => TaskQueueScreen(
//                             accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     contentPadding:
//                         const EdgeInsets.only(left: 56.0, right: 16.0),
//                     leading: const Icon(
//                       Icons.info_outline,
//                       color: Colors.orangeAccent,
//                       size: 20,
//                     ),
//                     title: const Text('View PE Details'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const PEDetailsSearchScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               // Reports Item
//               ListTile(
//                 leading: const Icon(
//                   Icons.assessment_outlined,
//                   color: Colors.teal,
//                 ),
//                 title: const Text(
//                   'Reports',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.teal,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const PEReportScreen(),
//                     ),
//                   );
//                 },
//               ),
//               // Escalations Item
//               ListTile(
//                 leading: const Icon(
//                   Icons.warning_amber_outlined,
//                   color: Colors.redAccent,
//                 ),
//                 title: const Text(
//                   'Escalations',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.redAccent,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => EscalationScreen(
//                         accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               // System Users Item
//               ListTile(
//                 leading: const Icon(
//                   Icons.manage_accounts_outlined,
//                   color: Colors.blueAccent,
//                 ),
//                 title: const Text(
//                   'System Users',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => SystemUsersScreen(
//                         userId: widget.userId,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const Divider(),
//               ListTile(
//                 leading: const Icon(
//                   Icons.logout,
//                   color: Colors.red,
//                 ),
//                 title: const Text(
//                   'Sign Out',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.red,
//                   ),
//                 ),
//                 onTap: () async {
//                   await _authService.logout();
//                   if (mounted) {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SigninScreen()),
//                       (route) => false,
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: myIndex,
//           type: BottomNavigationBarType.fixed,
//           onTap: (index) {
//             setState(() {
//               myIndex = index;
//             });
//           },
//           items: [
//             const BottomNavigationBarItem(
//                 icon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(
//               icon: Badge(
//                 label:
//                     _totalAlertsCount > 0 ? Text('$_totalAlertsCount') : null,
//                 isLabelVisible: _totalAlertsCount > 0,
//                 backgroundColor: Colors.red,
//                 child: const Icon(Icons.inbox),
//               ),
//               label: 'Inbox',
//             ),
//             const BottomNavigationBarItem(
//                 icon: Icon(Icons.group), label: 'Work Groups'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.folder), label: 'Projects'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.engineering), label: 'Engineers'),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../service/AuthService.dart';
import '../model/UserRole.dart';
import '../model/WorkGroup.dart';
import 'ProfileScreen.dart';
import 'DashboardHome.dart';
import 'ProjectScreen.dart';
import 'WorkGroupScreen.dart';
import 'AreaNetworkEngineerScreen.dart';
import 'PEIssueScreen.dart';

import 'PEDetailsSearchScreen.dart';
import 'TaskQueueScreen.dart';
import 'PEReportScreen.dart';
import 'EscalationScreen.dart';
import 'SystemUsersScreen.dart';
import 'PermissionsScreen.dart';
import 'RolesScreen.dart';
import 'FloatingChatbot.dart';
import '../../OnboardingScreen.dart';
import 'dart:async';
import '../service/PEIssueService.dart';
import '../service/UrgentRecordService.dart';
import '../service/NoticeService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WorkgroupSelectionScreen.dart';
import '../../SigninScreen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final int? selectedWorkGroupId;

  const DashboardScreen(
      {super.key, required this.userId, this.selectedWorkGroupId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int myIndex = 0;

  // User data
  String? name;
  String? photoBase64;
  String? userRoleName;
  int? userId;
  int? userRoleId;
  List<int>? workGroupIds;
  List<String>? workGroupNames;

  // Workgroup filter data
  List<WorkGroup> _allWorkGroups = [];
  int? _currentSelectedWorkGroupId;
  String? _currentSelectedWorkGroupName;

  // Notification counts
  int _totalAlertsCount = 0;
  Timer? _notificationTimer;
  final PEService _peIssueService = PEService();
  final UrgentRecordService _urgentRecordService = UrgentRecordService();
  final NoticeService _noticeService = NoticeService();

  // Loading/Error states
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  List<Widget> _pages = [];

  List<Widget> _buildPages(List<int>? workGroupIds) {
    return [
      DashboardHome(
        userId: widget.userId,
        selectedWorkGroupIds: workGroupIds ?? [],
        userName: name,
        userRole: userRoleName,
      ),
      PEIssuesScreen(
          userId: widget.userId,
          workGroupIds: workGroupIds ?? [],
          onRefreshCounts: _fetchNotificationCounts),
      WorkGroupScreen(userId: widget.userId),
      ProjectScreen(userId: widget.userId),
      AreaNetworkEngineerScreen(userId: widget.userId),
    ];
  }

  @override
  void initState() {
    super.initState();

    // Initialize pages with no workgroup data until profile is loaded
    _pages = _buildPages([]);

    fetchUserProfile();
    _startNotificationTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationTimer() {
    _fetchNotificationCounts(); // Initial fetch
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchNotificationCounts();
    });
  }

  Future<void> _fetchNotificationCounts() async {
    try {
      final storedUserId = await _storage.read(key: 'userId');
      if (storedUserId == null) return;
      final bUserId = int.tryParse(storedUserId);
      if (bUserId == null) return;

      int counts = 0;

      final prefs = await SharedPreferences.getInstance();
      final seenNotices = prefs.getStringList('seen_notices') ?? [];
      final seenUrgent = prefs.getStringList('seen_urgent') ?? [];

      // 1. Fetch urgent records count
      try {
        bool useRealData = false;
        if (_currentSelectedWorkGroupId != null && _currentSelectedWorkGroupName != null) {
            useRealData = (_currentSelectedWorkGroupName != 'NET-PROJ_CABLE-ACC' && _currentSelectedWorkGroupName != 'NET-PROJ-ACC-CABLE');
        }

        final urgentResult = await _urgentRecordService.fetchUrgentRecords(
          page: 1,
          pageSize: 2000,
          workgroupId: _currentSelectedWorkGroupId,
          fetchMultiWorkgroup: useRealData,
        );
        final List records = urgentResult['records'] ?? [];
        counts += records.where((r) => !seenUrgent.contains(r.peNumber)).length;
      } catch (e) {
        debugPrint('Error fetching urgent records for badge: $e');
      }

      // 2. Fetch active notices count
      try {
        final notices = await _noticeService.getActiveNotices();
        counts +=
            notices.where((n) => !seenNotices.contains(n.id.toString())).length;
      } catch (e) {
        debugPrint('Error fetching notices for badge: $e');
      }

      if (mounted) {
        setState(() {
          _totalAlertsCount = counts;
        });
      }
    } catch (e) {
      debugPrint('General error in _fetchNotificationCounts: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final azureUser = await _authService.getCurrentUser();
      if (azureUser == null) throw Exception('User not logged in');

      setState(() {
        name = azureUser['Name'];
        photoBase64 = azureUser['PhotoBase64'];
      });

      final storedUserId = await _storage.read(key: 'userId');
      if (storedUserId == null) throw Exception('Backend UserId not found');

      final backendUserId = int.tryParse(storedUserId);
      if (backendUserId == null) throw Exception('Invalid UserId in storage');

      final backendUser = await _authService.getUserById(backendUserId);
      if (backendUser == null) throw Exception('Backend user not found');

      final userRoles = await _authService.getUserRoles();
      final userRoleName = backendUser.userRoleId != null
          ? userRoles
              .firstWhere(
                (role) => role.id == backendUser.userRoleId,
                orElse: () => UserRole(id: 0, name: 'Unknown Role', level: 0),
              )
              .name
          : 'User';

      final workgroupData =
          await _authService.getCurrentUserWorkgroupsWithPermissions();
      var workGroupNames =
          workgroupData != null && workgroupData['userWorkgroupNames'] != null
              ? (workgroupData['userWorkgroupNames'] as List<dynamic>)
                  .cast<String>()
              : <String>[];

      // Fetch all workgroups for dropdown
      List<WorkGroup> allWorkGroups = [];
      try {
        allWorkGroups = await _authService.getWorkGroups();
      } catch (e) {
        debugPrint('Error fetching all workgroups: $e');
      }

      // Fallback: If workGroupNames is empty but IDs exist, fetch names manually
      if (workGroupNames.isEmpty &&
          backendUser.workGroupIds != null &&
          backendUser.workGroupIds!.isNotEmpty) {
        try {
          workGroupNames = allWorkGroups
              .where((wg) => backendUser.workGroupIds!.contains(wg.id))
              .map((wg) => wg.name)
              .toList();
        } catch (e) {
          debugPrint('Error in workgroup name fallback: $e');
        }
      }

      // Set initial selected workgroup
      int? initialSelectedWorkGroupId = widget.selectedWorkGroupId;
      String? initialSelectedWorkGroupName;
      if (initialSelectedWorkGroupId != null) {
        try {
          initialSelectedWorkGroupName = allWorkGroups
              .firstWhere((wg) => wg.id == initialSelectedWorkGroupId)
              .name;
        } catch (e) {
          debugPrint('Error finding initial workgroup: $e');
        }
      }

      setState(() {
        userId = backendUser.id;
        userRoleId = backendUser.userRoleId;
        workGroupIds = backendUser.workGroupIds;
        this.userRoleName = userRoleName;
        this.workGroupNames = workGroupNames;
        _allWorkGroups = allWorkGroups;
        _currentSelectedWorkGroupId = initialSelectedWorkGroupId;
        _currentSelectedWorkGroupName = initialSelectedWorkGroupName;
        isLoading = false;

        final filteredWorkgroup = widget.selectedWorkGroupId != null
            ? [widget.selectedWorkGroupId!]
            : workGroupIds;

        _pages = _buildPages(filteredWorkgroup);
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _onWorkGroupSelected(int? workGroupId) {
    setState(() {
      _currentSelectedWorkGroupId = workGroupId;

      // Find the workgroup name
      if (workGroupId != null) {
        try {
          final workgroup =
              _allWorkGroups.firstWhere((wg) => wg.id == workGroupId);
          _currentSelectedWorkGroupName = workgroup.name;
        } catch (e) {
          _currentSelectedWorkGroupName = 'Selected Workgroup';
        }
      } else {
        _currentSelectedWorkGroupName = null;
      }

      // Update pages with the filtered workgroup
      final filteredWorkgroup =
          workGroupId != null ? [workGroupId] : workGroupIds;

      _pages = _buildPages(filteredWorkgroup);
    });
    
    // Refresh the badge counts based on the new workgroup
    _fetchNotificationCounts();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkgroupSelectionScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 90,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 5,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkgroupSelectionScreen(),
                ),
              );
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Planned Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _currentSelectedWorkGroupName ??
                    ((workGroupNames != null && workGroupNames!.isNotEmpty)
                        ? workGroupNames!.join(', ')
                        : 'All Workgroups'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          actions: [
            // Workgroup Filter Dropdown
            if (workGroupIds != null && workGroupIds!.isNotEmpty)
              DropdownButtonHideUnderline(
                child: DropdownButton2<int>(
                  value: _currentSelectedWorkGroupId,
                  items: [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Row(
                        children: [
                          const Icon(Icons.close, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text('All Workgroups'),
                        ],
                      ),
                    ),
                    ..._allWorkGroups
                        .where((wg) =>
                            (workGroupIds?.contains(wg.id) ?? false) ||
                            wg.id == _currentSelectedWorkGroupId)
                        .map((workgroup) => DropdownMenuItem<int>(
                              value: workgroup.id,
                              child: Row(
                                children: [
                                  const Icon(Icons.group_work, size: 16),
                                  const SizedBox(width: 8),
                                  Text(workgroup.name),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                  onChanged: _onWorkGroupSelected,
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    height: 40,
                    width: 40,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                      if (item.value == null) {
                        return 'all workgroups'.contains(searchValue.toLowerCase());
                      }
                      final workgroup = _allWorkGroups.firstWhere((wg) => wg.id == item.value);
                      return workgroup.name.toLowerCase().contains(searchValue.toLowerCase());
                    },
                  ),
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      _searchController.clear();
                    }
                  },
                  customButton: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Tooltip(
                      message: _currentSelectedWorkGroupId != null
                          ? 'Filtering: $_currentSelectedWorkGroupName'
                          : 'Select Workgroup Filter',
                      child: Icon(
                        Icons.filter_list,
                        color: _currentSelectedWorkGroupId != null
                            ? Colors.yellow
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: _openEndDrawer,
            ),
          ],
          flexibleSpace: Container(
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
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Stack(
                    children: [
                      _pages[myIndex],
                      const FloatingChatbot(),
                    ],
                  ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          (photoBase64 != null && photoBase64!.isNotEmpty)
                              ? MemoryImage(base64Decode(photoBase64!))
                              : null,
                      child: (photoBase64 == null || photoBase64!.isEmpty)
                          ? Text(
                              name?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name ?? 'Guest',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  setState(() => myIndex = 0);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              // PE Management Section
              ExpansionTile(
                leading: const Icon(
                  Icons.event_note,
                  color: Color.fromARGB(226, 16, 37, 89),
                ),
                title: const Text(
                  'PE Management',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(226, 16, 37, 89),
                  ),
                ),
                children: [

                  ListTile(
                    contentPadding:
                        const EdgeInsets.only(left: 56.0, right: 16.0),
                    leading: const Icon(
                      Icons.task,
                      color: Colors.deepPurpleAccent,
                      size: 20,
                    ),
                    title: const Text('Task Queue'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskQueueScreen(
                            accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.only(left: 56.0, right: 16.0),
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.orangeAccent,
                      size: 20,
                    ),
                    title: const Text('View PE Details'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PEDetailsSearchScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Reports Item
              ListTile(
                leading: const Icon(
                  Icons.assessment_outlined,
                  color: Colors.teal,
                ),
                title: const Text(
                  'Reports',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PEReportScreen(),
                    ),
                  );
                },
              ),
              // Escalations Item
              ListTile(
                leading: const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Escalations',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EscalationScreen(
                        accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
                      ),
                    ),
                  );
                },
              ),
              // System Users Item
              ListTile(
                leading: const Icon(
                  Icons.manage_accounts_outlined,
                  color: Colors.blueAccent,
                ),
                title: const Text(
                  'System Users',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SystemUsersScreen(
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
              ),
              // Manage Permission Item
              ListTile(
                leading: const Icon(
                  Icons.security_outlined,
                  color: Colors.indigo,
                ),
                title: const Text(
                  'Manage Permission',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PermissionsScreen(),
                    ),
                  );
                },
              ),
              // Manage Role Item
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.deepPurple,
                ),
                title: const Text(
                  'Manage Role',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RolesScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  await _authService.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SigninScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: myIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Badge(
                label:
                    _totalAlertsCount > 0 ? Text('$_totalAlertsCount') : null,
                isLabelVisible: _totalAlertsCount > 0,
                backgroundColor: Colors.red,
                child: const Icon(Icons.inbox),
              ),
              label: 'Inbox',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.group), label: 'Work Groups'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.folder), label: 'Projects'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.engineering), label: 'Engineers'),
          ],
        ),
      ),
    );
  }
}

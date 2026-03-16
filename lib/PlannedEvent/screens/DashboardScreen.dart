// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../service/AuthService.dart';
// import '../model/UserRole.dart';
// import 'ProfileScreen.dart';
// import 'DashboardHome.dart';
// import 'PEIssueScreen.dart';
// import 'ProjectScreen.dart';
// import 'WorkGroupScreen.dart';
// import 'AreaNetworkEngineerScreen.dart';
// import '../../CreateUserScreen.dart';

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
//   String? email;
//   String? photoBase64;
//   String? jobTitle;
//   int? userId;
//   int? userRoleId;
//   List<int>? workGroupIds;
//   String? userRoleName;
//   List<String>? workGroupNames;

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
//       PEIssuesScreen(userId: widget.userId),
//       WorkGroupScreen(userId: widget.userId),
//       ProjectScreen(userId: widget.userId),
//       AreaNetworkEngineerScreen(userId: widget.userId),
//     ];
//     // Fetch user profile data
//     fetchUserProfile();
//   }

//   Future<void> fetchUserProfile() async {
//     try {
//       // Get Azure AD info
//       final azureUser = await _authService.getCurrentUser();
//       if (azureUser == null) throw Exception('User not logged in');

//       setState(() {
//         name = azureUser['Name'];
//         // email = azureUser['Email'];
//         photoBase64 = azureUser['PhotoBase64'];
//       });

//       // Get backend userId from secure storage
//       final storedUserId = await _storage.read(key: 'userId');
//       if (storedUserId == null) throw Exception('Backend UserId not found');

//       final backendUserId = int.tryParse(storedUserId);
//       if (backendUserId == null) throw Exception('Invalid UserId in storage');

//       // Fetch backend user by Id
//       final backendUser = await _authService.getUserById(backendUserId);
//       if (backendUser == null) throw Exception('Backend user not found');

//       // Fetch roles and workgroups
//       final userRoles = await _authService.getUserRoles();
//       final userRoleName = backendUser.userRoleId != null
//           ? userRoles
//               .firstWhere(
//                 (role) => role.id == backendUser.userRoleId,
//                 orElse: () => UserRole(id: 0, name: 'Unknown Role'),
//               )
//               .name
//           : 'User';

//       // Fetch workgroup names
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
//         jobTitle = userRoleName;
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

//   // return Scaffold(
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const CreateUserScreen(),
//             ),
//           );
//           return false;
//         },
//         child: Scaffold(
//           key: _scaffoldKey,
//           appBar: AppBar(
//             toolbarHeight: 70,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 5,
//             systemOverlayStyle: const SystemUiOverlayStyle(
//               statusBarColor: Colors.transparent,
//               statusBarIconBrightness: Brightness.light,
//             ),
//             automaticallyImplyLeading: false,
//             iconTheme: const IconThemeData(color: Colors.white),
//             // title: const Text(
//             //   'Planned Event',
//             //   style: TextStyle(
//             //     color: Colors.white,
//             //     fontSize: 20,
//             //     fontWeight: FontWeight.bold,
//             //   ),
//             // ),
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Planned Event',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   userRoleName ?? '',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.menu, color: Colors.white),
//                 onPressed: _openEndDrawer,
//               ),
//             ],
//             flexibleSpace: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color.fromARGB(226, 16, 37, 89),
//                     Color.fromARGB(255, 8, 11, 66),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//           ),
//           body: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : errorMessage != null
//                   ? Center(
//                       child: Text(
//                         errorMessage!,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     )
//                   : _pages[myIndex],
//           // endDrawer: Drawer(
//           //   child: ListView(
//           //     padding: EdgeInsets.zero,
//           //     children: [
//           //       DrawerHeader(
//           //         decoration: const BoxDecoration(
//           //           gradient: LinearGradient(
//           //             colors: [
//           //               Color.fromARGB(226, 16, 37, 89),
//           //               Color.fromARGB(255, 8, 11, 66),
//           //             ],
//           //             begin: Alignment.topLeft,
//           //             end: Alignment.bottomCenter,
//           //           ),
//           //         ),
//           //         child: Row(
//           //           children: [
//           //             CircleAvatar(
//           //               radius: 30,
//           //               backgroundColor: Colors.grey[300],
//           //               backgroundImage:
//           //                   (photoBase64 != null && photoBase64!.isNotEmpty)
//           //                       ? MemoryImage(base64Decode(photoBase64!))
//           //                       : null,
//           //               child: (photoBase64 == null || photoBase64!.isEmpty)
//           //                   ? Text(
//           //                       name?.substring(0, 1).toUpperCase() ?? 'U',
//           //                       style: const TextStyle(
//           //                           fontSize: 24, fontWeight: FontWeight.bold),
//           //                     )
//           //                   : null,
//           //             ),
//           //             const SizedBox(width: 10),
//           //             Column(
//           //               crossAxisAlignment: CrossAxisAlignment.start,
//           //               mainAxisAlignment: MainAxisAlignment.center,
//           //               children: [
//           //                 Text(
//           //                   name ?? 'Guest',
//           //                   style: const TextStyle(
//           //                       color: Colors.white, fontSize: 20),
//           //                 ),
//           //                 // Text(
//           //                 //   email ?? 'guest@example.com',
//           //                 //   style: const TextStyle(color: Colors.white70, fontSize: 14),
//           //                 // ),
//           //               ],
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //       ListTile(
//           //         leading: const Icon(Icons.person),
//           //         title: const Text('Profile'),
//           //         onTap: () {
//           //           setState(() => myIndex = 0);
//           //           Navigator.pop(context);
//           //           Navigator.push(
//           //             context,
//           //             MaterialPageRoute(builder: (_) => const ProfileScreen()),
//           //           );
//           //         },
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           endDrawer: Drawer(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 DrawerHeader(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color.fromARGB(226, 16, 37, 89),
//                         Color.fromARGB(255, 8, 11, 66),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomCenter,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.grey[300],
//                         backgroundImage:
//                             (photoBase64 != null && photoBase64!.isNotEmpty)
//                                 ? MemoryImage(base64Decode(photoBase64!))
//                                 : null,
//                         child: (photoBase64 == null || photoBase64!.isEmpty)
//                             ? Text(
//                                 name?.substring(0, 1).toUpperCase() ?? 'U',
//                                 style: const TextStyle(
//                                     fontSize: 24, fontWeight: FontWeight.bold),
//                               )
//                             : null,
//                       ),
//                       const SizedBox(width: 10),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             name ?? 'Guest',
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 20),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Profile item
//                 ListTile(
//                   leading: const Icon(Icons.person),
//                   title: const Text('Profile'),
//                   onTap: () {
//                     setState(() => myIndex = 0);
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                     );
//                   },
//                 ),
//                 // Logout item (immediately under Profile)
//                 // Logout item (immediately under Profile)
//                 // Logout item (immediately under Profile)
//                 // ListTile(
//                 //   leading: const Icon(Icons.logout),
//                 //   title: const Text('Logout'),
//                 //   onTap: () async {
//                 //     try {
//                 //       // Call AuthService logout to clear tokens and user info
//                 //       await _authService.logout();

//                 //       // Close drawer
//                 //       Navigator.pop(context);

//                 //       // Optional: Show a message
//                 //       ScaffoldMessenger.of(context).showSnackBar(
//                 //         const SnackBar(
//                 //             content: Text('Logged out successfully.')),
//                 //       );

//                 //       // Next time user tries to access Dashboard, the Microsoft login flow will trigger
//                 //     } catch (e) {
//                 //       ScaffoldMessenger.of(context).showSnackBar(
//                 //         SnackBar(
//                 //             content: Text('Logout failed: ${e.toString()}')),
//                 //       );
//                 //     }
//                 //   },
//                 // ),
//               ],
//             ),
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             currentIndex: myIndex,
//             type: BottomNavigationBarType.fixed,
//             onTap: (index) {
//               setState(() {
//                 myIndex = index;
//               });
//             },
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//               BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.group), label: 'Work Groups'),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.folder), label: 'Projects'),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.engineering), label: 'Engineers'),
//             ],
//           ),
//         ));
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../service/AuthService.dart';
// import '../model/UserRole.dart';
// import '../model/WorkGroup.dart';
// import 'ProfileScreen.dart';
// import 'DashboardHome.dart';
// import 'PEIssueScreen.dart';
// import 'ProjectScreen.dart';
// import 'WorkGroupScreen.dart';
// import 'AreaNetworkEngineerScreen.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import '../../OnboardingScreen.dart'; // updated import

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

//   // WorkGroup filter
//   List<WorkGroup> _allWorkGroups = [];
//   final List<WorkGroup> _selectedWorkGroups = [];

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
//       PEIssuesScreen(userId: widget.userId),
//       WorkGroupScreen(userId: widget.userId),
//       ProjectScreen(userId: widget.userId),
//       AreaNetworkEngineerScreen(userId: widget.userId),
//     ];

//     fetchUserProfile();
//     fetchWorkGroups(); // Fetch all workgroups for filter
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

//   Future<void> fetchWorkGroups() async {
//     try {
//       final workGroups = await _authService.getWorkGroups();
//       setState(() {
//         _allWorkGroups = workGroups;
//       });
//     } catch (e) {
//       // ignore errors for dropdown
//     }
//   }

//   void _openEndDrawer() {
//     _scaffoldKey.currentState?.openEndDrawer();
//   }

//   Widget workGroupFilter() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       margin: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.deepPurpleAccent,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2<WorkGroup>(
//           isExpanded: true,
//           hint: const Text(
//             "Select WorkGroup",
//             style: TextStyle(color: Color.fromARGB(255, 5, 5, 5)),
//           ),
//           items: _allWorkGroups
//               .map(
//                 (wg) => DropdownMenuItem(
//                   value: wg,
//                   child: Text(
//                     wg.name,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               )
//               .toList(),
//           onChanged: (value) {
//             if (value != null && !_selectedWorkGroups.contains(value)) {
//               setState(() {
//                 _selectedWorkGroups.add(value);
//               });
//             }
//           },
//           dropdownStyleData: const DropdownStyleData(
//             maxHeight: 250,
//           ),
//           buttonStyleData: ButtonStyleData(
//             height: 50,
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(25),
//             ),
//           ),
//           menuItemStyleData: const MenuItemStyleData(
//             height: 40,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 OnboardingScreen(userId: widget.userId), // changed here
//           ),
//         );
//         return false;
//       },
//       child: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           toolbarHeight: 70,
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
//                 userRoleName ?? '',
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                 ),
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
//                 : Column(
//                     children: [
//                       // WORKGROUP FILTER DROPDOWN
//                       workGroupFilter(),

//                       // Expanded Dashboard Page
//                       Expanded(child: _pages[myIndex]),
//                     ],
//                   ),
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
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
//             BottomNavigationBarItem(
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
import '../service/AuthService.dart';
import '../model/UserRole.dart';
import 'ProfileScreen.dart';
import 'DashboardHome.dart';
import 'ProjectScreen.dart';
import 'WorkGroupScreen.dart';
import 'AreaNetworkEngineerScreen.dart';
import '../../OnboardingScreen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({super.key, required this.userId});

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

  // Loading/Error states
  bool isLoading = true;
  String? errorMessage;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize pages
    _pages = [
      DashboardHome(userId: widget.userId),
      //PEIssuesScreen(userId: widget.userId),
      WorkGroupScreen(userId: widget.userId),
      ProjectScreen(userId: widget.userId),
      AreaNetworkEngineerScreen(userId: widget.userId),
    ];

    fetchUserProfile();
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
                orElse: () => UserRole(id: 0, name: 'Unknown Role'),
              )
              .name
          : 'User';

      final workgroupData =
          await _authService.getCurrentUserWorkgroupsWithPermissions();
      final workGroupNames =
          workgroupData != null && workgroupData['userWorkgroupNames'] != null
              ? (workgroupData['userWorkgroupNames'] as List<dynamic>)
                  .cast<String>()
              : <String>[];

      setState(() {
        userId = backendUser.id;
        userRoleId = backendUser.userRoleId;
        workGroupIds = backendUser.workGroupIds;
        this.userRoleName = userRoleName;
        this.workGroupNames = workGroupNames;
        isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(userId: widget.userId),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 70,
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
                  builder: (context) => OnboardingScreen(userId: widget.userId),
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
                userRoleName ?? '',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
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
                : _pages[myIndex],
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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group), label: 'Work Groups'),
            BottomNavigationBarItem(
                icon: Icon(Icons.folder), label: 'Projects'),
            BottomNavigationBarItem(
                icon: Icon(Icons.engineering), label: 'Engineers'),
          ],
        ),
      ),
    );
  }
}

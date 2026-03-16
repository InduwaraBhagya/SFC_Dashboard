// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'DashboardHome.dart';
// import 'NotificationScreen.dart';
// import 'WorkGroupScreen.dart';
// import 'PETaskListScreen.dart';

// class DashboardScreen extends StatefulWidget {
//   final Map<String, dynamic>? user; // Accept user data from LoginScreen

//   const DashboardScreen({super.key, this.user});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   int myIndex = 0;

//   final List<Widget> _pages = [
//     const DashboardHome(),
//     const NotificationScreen(),
//     const WorkGroupScreen(),
//     const PETaskListScreen(),
//   ];

//   void _openEndDrawer() {
//     _scaffoldKey.currentState?.openEndDrawer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Default user data if not provided (for testing)
//     final user = widget.user ??
//         {
//           'Name': 'Guest',
//           'ServiceId': 'SVC000',
//           'Email': 'guest@example.com',
//           'PhotoUrl': 'https://via.placeholder.com/150', // Placeholder image
//         };

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         toolbarHeight: 70,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(20),
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 5,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//         ),
//         automaticallyImplyLeading: false,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Service Order',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu, color: Colors.white),
//             onPressed: _openEndDrawer,
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(226, 16, 37, 89),
//                 Color.fromARGB(255, 8, 11, 66),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//         ),
//       ),
//       body: myIndex < _pages.length ? _pages[myIndex] : _pages[0],
//       endDrawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
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
//               child: Row(
//                 children: [
//                   // User Photo
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundImage: NetworkImage(
//                         user['PhotoUrl'] ?? 'https://via.placeholder.com/150'),
//                   ),
//                   const SizedBox(width: 10),
//                   // User Details
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         user['Name'] ?? 'Guest',
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 20),
//                       ),
//                       Text(
//                         user['Email'] ?? 'guest@example.com',
//                         style: const TextStyle(
//                             color: Colors.white70, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 setState(() => myIndex = 0);
//                 Navigator.pop(context);
//                 // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: myIndex,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           if (index >= 0 && index < _pages.length) {
//             setState(() {
//               myIndex = index;
//             });
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.group), label: 'Work Groups'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.event), label: 'PE Task List'),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'DashboardHome.dart';
import 'NotificationScreen.dart';
import 'WorkGroupScreen.dart';
import 'PETaskListScreen.dart';
import '../../CreateUserScreen.dart'; // adjust path if needed

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int myIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const NotificationScreen(),
    const WorkGroupScreen(),
    const PETaskListScreen(),
  ];

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user ??
        {
          'Name': 'Guest',
          'ServiceId': 'SVC000',
          'Email': 'guest@example.com',
          'UserRole': 'Admin',
          'PhotoUrl': 'https://via.placeholder.com/150',
        };

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateUserScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 70,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 5,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.white),

          // Updated title with role
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Service Order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user['UserRole'] ?? '',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
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
        body: myIndex < _pages.length ? _pages[myIndex] : _pages[0],
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
                      backgroundImage: NetworkImage(
                        user['PhotoUrl'] ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user['Name'] ?? 'Guest',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          user['Email'] ?? 'guest@example.com',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
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
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: myIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index >= 0 && index < _pages.length) {
              setState(() {
                myIndex = index;
              });
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group), label: 'Work Groups'),
            BottomNavigationBarItem(
                icon: Icon(Icons.event), label: 'PE Task List'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sfc_dashboard/ServiceOrder/ServiceOrderMain.dart';

import 'package:sfc_dashboard/SigninScreen.dart';

enum OnboardingDestination {
  plannedEvent,
  serviceOrder,
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          'SFC Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 25, 130),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  elevation: 5,
                ),
                child: const Text(
                  'Planned Event',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SigninScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 25, 130),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  elevation: 5,
                ),
                child: const Text(
                  'Service Order',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceOrderMain(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sfc_dashboard/ServiceOrder/ServiceOrderMain.dart';
// import 'package:sfc_dashboard/PlannedEvent/PlannedEventMain.dart';
// import 'CreateUserScreen.dart'; // adjust path if needed

// class OnboardingScreen extends StatelessWidget {
//   final int userId;

//   const OnboardingScreen({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CreateUserScreen(),
//           ),
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 70,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(
//               bottom: Radius.circular(20),
//             ),
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 5,
//           systemOverlayStyle: const SystemUiOverlayStyle(
//             statusBarColor: Colors.transparent,
//             statusBarIconBrightness: Brightness.light,
//           ),
//           automaticallyImplyLeading: false,
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: const Text(
//             'SFC Dashboard',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
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
//         body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/background1.png"),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 9, 25, 130),
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(200, 60),
//                     elevation: 5,
//                   ),
//                   child: const Text(
//                     'Planned Event',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => PlannedEventMain(userId: userId),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 9, 25, 130),
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(200, 60),
//                     elevation: 5,
//                   ),
//                   child: const Text(
//                     'Service Order',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ServiceOrderMain(),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

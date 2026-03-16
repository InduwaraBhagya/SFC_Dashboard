import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sfc_dashboard/PlannedEvent/screens/DashboardScreen.dart';

class PlannedEventMain extends StatefulWidget {
  final int userId;
  const PlannedEventMain({super.key, required this.userId});

  @override
  State<PlannedEventMain> createState() => _PlannedEventMainState();
}

class _PlannedEventMainState extends State<PlannedEventMain> {
  bool _envLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadEnv();
  }

  Future<void> _loadEnv() async {
    await dotenv.load(fileName: ".env");
    setState(() {
      _envLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_envLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SFC Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardScreen(userId: widget.userId), // Pass userId
    );
  }
}

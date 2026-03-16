import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/DashboardScreen.dart';

class ServiceOrderMain extends StatefulWidget {
  const ServiceOrderMain({super.key});

  @override
  State<ServiceOrderMain> createState() => _ServiceOrderMainState();
}

class _ServiceOrderMainState extends State<ServiceOrderMain> {
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
      home: const DashboardScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import '../service/NotificationService.dart';
import 'package:flutter/foundation.dart';

class NotificationScreen extends StatefulWidget {
  final int userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _fetchTasks(); // Fetch tasks on initialization
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await _notificationService.getUrgentRequests();
      if (kDebugMode) {
        print('Fetched ${tasks.length} tasks: $tasks');
      }
      setState(() {
        _tasks = tasks;
        _isLoading = false;
        if (_tasks.isNotEmpty) {
          _animationController.forward();
        } else {
          _animationController.reset();
        }
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch tasks failed: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch tasks: $e';
      });
    }
  }

  Future<void> _markAsUrgent(int id) async {
    try {
      final success = await _notificationService.markAsUrgent(id);
      if (success) {
        setState(() {
          _successMessage = 'Task $id marked as urgent successfully.';
          _tasks.removeWhere((t) => t['Id'] == id.toString());
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => _successMessage = null);
        });
      } else {
        throw Exception('Mark as urgent failed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Failed to mark urgent: $e');
        print('StackTrace: $stackTrace');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark task $id as urgent: $e')),
      );
    }
  }

  Future<void> _rejectUrgent(int id) async {
    try {
      final success = await _notificationService.rejectUrgent(id);
      if (success) {
        setState(() {
          _successMessage = 'Task $id rejected as urgent successfully.';
          _tasks.removeWhere((t) => t['Id'] == id.toString());
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => _successMessage = null);
        });
      } else {
        throw Exception('Reject urgent failed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Failed to reject urgent: $e');
        print('StackTrace: $stackTrace');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject task $id as urgent: $e')),
      );
    }
  }

  void _showConfirmDialog(int id, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Confirm $action'),
          ],
        ),
        content: Text('Are you sure you want to $action task with ID $id?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'accept' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (action == 'accept') {
                _markAsUrgent(id);
              } else {
                _rejectUrgent(id);
              }
            },
            child: Text(action == 'accept' ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTasks,
        child: Column(
          children: [
            if (_successMessage != null)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(226, 16, 37, 89),
                      Color.fromARGB(255, 8, 11, 66),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null)
              Container(
                color: Colors.red[100],
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 200,
                            child: Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _errorMessage ?? 'No Messages found',
                                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return Card(
                                key: ValueKey(task['Id']),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: ListTile(
                                  title: Text(
                                    'ID: ${task['Id'] ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('PE Number: ${task['PENumber'] ?? 'N/A'}'),
                                      Text('Task Seq: ${task['TaskSeq'] ?? 'N/A'}'),
                                      Text('Task: ${task['Task'] ?? 'N/A'}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _showConfirmDialog(int.parse(task['Id']), 'accept'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _showConfirmDialog(int.parse(task['Id']), 'reject'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
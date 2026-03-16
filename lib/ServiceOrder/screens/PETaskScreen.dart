import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/PETask.dart';
import '../service/PETaskService.dart';

class PETaskScreen extends StatefulWidget {
  final String peNumber;

  const PETaskScreen({super.key, required this.peNumber});

  @override
  State<PETaskScreen> createState() => _PETaskScreenState();
}

class _PETaskScreenState extends State<PETaskScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<PETask>> _tasks;
  List<PETask> _allTasks = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tasks = PETaskService().getTasksByPENumber(widget.peNumber);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: value == 'N/A' ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change back button color to white
        ),
        title: Text(
          widget.peNumber,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        flexibleSpace: Container(
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
        ),
        elevation: 4,
      ),
      body: FutureBuilder<List<PETask>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allTasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          _allTasks = snapshot.data ?? [];
          if (_allTasks.isEmpty) {
            return const Center(child: Text("No tasks found"));
          }

          _animationController.forward();

          return CustomScrollView(
            slivers: [
              // Header with total tasks count
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(225, 82, 126, 238),
                          Color.fromARGB(255, 7, 0, 99),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.list, size: 24, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Total Tasks: ${_allTasks.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Task list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = _allTasks[index];
                    return Card(
                      key: ValueKey(task.task),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ExpansionTile(
                        title: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          title: Text(
                            task.task,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Status: ${task.taskStatus}',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        children: [
                          _buildFieldRow('OLA', task.ola),
                          _buildFieldRow(
                              'Created Date', task.taskCreatedDate.toString()),
                          _buildFieldRow('Complete Date',
                              task.taskCompleteDate.toString()),
                          _buildFieldRow(
                              'Urgent', task.isUrgent ? 'Yes' : 'No'),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                  childCount: _allTasks.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/TaskQueue.dart';
import '../service/TaskQueueService.dart';

class TaskQueueScreen extends StatefulWidget {
  final String accessToken;

  const TaskQueueScreen({
    super.key,
    required this.accessToken,
  });

  @override
  _TaskQueueScreenState createState() => _TaskQueueScreenState();
}

class _TaskQueueScreenState extends State<TaskQueueScreen> {
  late final TaskQueueService _taskQueueService = TaskQueueService(
    accessToken: widget.accessToken,
  );
  List<TaskQueueItem> _tasks = [];
  List<int> _availableYears = [];
  int? _selectedWorkgroupId;
  int? _selectedYear;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableYears();
    _loadTasks();
  }

  Future<void> _loadAvailableYears() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final years = await _taskQueueService.getAvailableYears();
      setState(() {
        _availableYears = years;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tasks = await _taskQueueService.getPrioritizedTasks(
        workgroupId: _selectedWorkgroupId,
        year: _selectedYear,
      );
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Queue',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        centerTitle: true,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int?>(
                        value: _selectedYear,
                        hint: const Text('Select Year'),
                        isExpanded: true,
                        items: _availableYears
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ))
                            .toList()
                          ..add(const DropdownMenuItem(
                            value: null,
                            child: Text('All Years'),
                          )),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value;
                          });
                          _loadTasks();
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              leading: Icon(
                                Icons.task,
                                color: task.isOverdue
                                    ? Colors.red
                                    : const Color.fromARGB(255, 6, 38, 84),
                              ),
                              title: Text(
                                task.task.plannedEvent?.peNumber ??
                                    'Task ${task.task.id}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: task.task.isUrgent
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: task.isOverdue
                                      ? Colors.red
                                      : const Color.fromARGB(255, 6, 38, 84),
                                ),
                              ),
                              children: [
                                _buildFieldRow(
                                    'Priority', task.priorityLevel.toString()),
                                _buildFieldRow('Due', task.dueStatus),
                                _buildFieldRow('OLA', task.olaStatus),
                                _buildFieldRow(
                                    'Urgency', task.urgencyLevel.toString()),
                                _buildFieldRow('Score',
                                    task.priorityScore.toStringAsFixed(1)),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: value == 'N/A' ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

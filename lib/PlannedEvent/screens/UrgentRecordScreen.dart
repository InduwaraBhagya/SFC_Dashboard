import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/OLAViolateRecord.dart';
import '../service/UrgentRecordService.dart';
import 'OLAViolateRecordDetailsScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class UrgentRecordScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UrgentRecordScreen({super.key, required this.user});

  @override
  _UrgentRecordScreenState createState() => _UrgentRecordScreenState();
}

class _UrgentRecordScreenState extends State<UrgentRecordScreen> with SingleTickerProviderStateMixin {
  final _service = UrgentRecordService();
  final _storage = const FlutterSecureStorage();
  List<OLAViolateRecord> _allRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  final int _pageSize = 10;
  String? _searchTerm;
  int? _workgroupId;
  int? _userId;

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
    _initUserAndFetch();
  }

  Future<void> _initUserAndFetch() async {
    try {
      final storedUserId = await _storage.read(key: 'userId');
      if (storedUserId == null) throw Exception('UserId not found in storage');
      _userId = int.tryParse(storedUserId);
      if (_userId == null) throw Exception('Invalid UserId in storage');
      await _fetchRecords(page: 1);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching userId: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        _errorMessage = 'Unable to fetch userId: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRecords({int page = 1}) async {
    if (_userId == null) {
      setState(() {
        _allRecords = [];
        _totalCount = 0;
        _totalPages = 1;
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.fetchUrgentRecords(
        page: page,
        pageSize: _pageSize,
        searchTerm: _searchTerm,
        workgroupId: _workgroupId,
      );

      final List<OLAViolateRecord> newRecords = (result['records'] as List<dynamic>?)?.cast<OLAViolateRecord>() ?? [];
      final int totalCount = result['totalCount'] as int? ?? 0;
      final int totalPages = result['totalPages'] as int? ?? 1;

      if (kDebugMode) {
        print('Fetched ${newRecords.length} urgent records, page: $page, total: $totalCount, totalPages: $totalPages');
        print('Records: ${newRecords.map((r) => r.peNumber).toList()}');
      }

      setState(() {
        _allRecords = newRecords;
        _currentPage = result['currentPage'] as int? ?? page;
        _totalCount = totalCount;
        _totalPages = totalPages;
        _isLoading = false;
        if (_allRecords.isNotEmpty) _animationController.forward();
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch urgent records failed: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Urgent Records',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
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
            child: _allRecords.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                                  'Total Records: $_totalCount',
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
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final record = _allRecords[index];
                            return Card(
                              key: ValueKey(record.peNumber),
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ExpansionTile(
                                title: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  title: Text(
                                    'PE Number: ${record.peNumber ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Task: ${record.taskName ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                                      ),
                                      Text(
                                        'Customer: ${record.customer ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                children: [
                                  _buildFieldRow('Workgroup', record.taskWg ?? 'N/A'),
                                  _buildFieldRow('Province', record.province ?? 'N/A'),
                                  _buildFieldRow('Contractor', record.contractorName ?? 'N/A'),
                                  _buildFieldRow('PE Title', record.peTitle ?? 'N/A'),
                                  _buildFieldRow('PE Objective', record.peObjective ?? 'N/A'),
                                  _buildFieldRow('Service Type', record.serviceType ?? 'N/A'),
                                  _buildFieldRow('Status', record.peStatus ?? 'N/A'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[600],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          if (kDebugMode) {
                                            print('Navigating to OLAViolateRecordDetailsScreen for PE: ${record.peNumber}');
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OLAViolateRecordDetailsScreen(record: record),
                                            ),
                                          );
                                        },
                                        child: const Text('View Full Details'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: _allRecords.length,
                        ),
                      ),
                      if (_totalPages > 1)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  color: _currentPage == 1 || _isLoading ? Colors.grey : Colors.green[600],
                                  onPressed: _currentPage == 1 || _isLoading
                                      ? null
                                      : () => setState(() {
                                            _currentPage--;
                                            _fetchRecords(page: _currentPage);
                                          }),
                                ),
                                Text('Page $_currentPage of $_totalPages'),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  color: _currentPage == _totalPages || _isLoading ? Colors.grey : Colors.green[600],
                                  onPressed: _currentPage == _totalPages || _isLoading
                                      ? null
                                      : () => setState(() {
                                            _currentPage++;
                                            _fetchRecords(page: _currentPage);
                                          }),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
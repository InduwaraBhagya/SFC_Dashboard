import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/OLAViolateRecord.dart';
import '../service/OLAViolateRecordService.dart';
import 'OLAViolateRecordDetailsScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class OLAViolateRecordScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final int? workgroupId;
  final bool useRealData;

  const OLAViolateRecordScreen({
    super.key,
    this.user,
    this.workgroupId,
    this.useRealData = false,
  });

  @override
  _OLAViolateRecordScreenState createState() => _OLAViolateRecordScreenState();
}

class _OLAViolateRecordScreenState extends State<OLAViolateRecordScreen> with SingleTickerProviderStateMixin {
  final _service = OLAViolateRecordService();
  final _storage = const FlutterSecureStorage();
  List<OLAViolateRecord> _allRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  final int _pageSize = 10;
  String? _searchTerm;
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
      final result = await _service.fetchOLAViolateRecords(
        page: page,
        pageSize: _pageSize,
        searchTerm: _searchTerm,
        workgroupId: widget.workgroupId,
        fetchMultiWorkgroup: widget.useRealData,
      );

      final List<OLAViolateRecord> newRecords = (result['records'] as List<dynamic>?)?.cast<OLAViolateRecord>() ?? [];
      final int totalCount = result['totalCount'] as int? ?? 0;
      final int totalPages = result['totalPages'] as int? ?? 1;

      if (kDebugMode) {
        print('Fetched ${newRecords.length} OLA violation records, page: $page, total: $totalCount, totalPages: $totalPages');
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
        print('Fetch OLA violation records failed: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Future<void> _requestMarkUrgent(OLAViolateRecord record) async {
  //   try {
  //     final success = await _service.requestMarkOLARecordUrgent(record.id.toString());
  //     if (success) {
  //       setState(() {
  //         _successMessage = 'PE ${record.peNumber} marked as urgent successfully.';
  //         _allRecords.removeWhere((r) => r.id == record.id);
  //         _totalCount--;
  //         _totalPages = (_totalCount / _pageSize).ceil();
  //       });
  //       Future.delayed(const Duration(seconds: 3), () {
  //         if (mounted) {
  //           setState(() => _successMessage = null);
  //         }
  //       });
  //     }
  //   } catch (e, stackTrace) {
  //     if (kDebugMode) {
  //       print('Failed to mark urgent: $e');
  //       print('StackTrace: $stackTrace');
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to mark PE ${record.peNumber} as urgent: $e')),
  //     );
  //   }
  // }

  // void _showRequestMarkUrgentDialog(OLAViolateRecord record) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Row(
  //         children: [
  //           Icon(Icons.warning, color: Colors.orange),
  //           SizedBox(width: 8),
  //           Text('Mark as Urgent'),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Are you sure you want to mark PE ${record.peNumber} as urgent due to OLA violation?'),
  //           const SizedBox(height: 8),
  //           const Text(
  //             'This will move the record to the urgent list for immediate attention.',
  //             style: TextStyle(color: Colors.grey),
  //           ),
  //         ],
  //       ),
  //       // actions: [
  //       //   TextButton(
  //       //     onPressed: () => Navigator.pop(context),
  //       //     child: const Text('Cancel'),
  //       //   ),
  //       //   ElevatedButton(
  //       //     style: ElevatedButton.styleFrom(
  //       //       backgroundColor: Colors.red,
  //       //       foregroundColor: Colors.white,
  //       //     ),
  //       //     onPressed: () async {
  //       //       Navigator.pop(context);
  //       //       await _requestMarkUrgent(record);
  //       //     },
  //       //     child: const Text('Mark Urgent'),
  //       //   ),
  //       // ],
  //     ),
  //   );
  // }

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
          'OLA Violation Records',
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
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
                                        const SizedBox(width: 8),
                                        // ElevatedButton(
                                        //   style: ElevatedButton.styleFrom(
                                        //     backgroundColor: Colors.red,
                                        //     foregroundColor: Colors.white,
                                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        //     elevation: 2,
                                        //   ),
                                        //   onPressed: () => _showRequestMarkUrgentDialog(record),
                                        //   child: const Text('Request Urgent'),
                                        // ),
                                      ],
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
                                Text(
                                  'Page $_currentPage of $_totalPages',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
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
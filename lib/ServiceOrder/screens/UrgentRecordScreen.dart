import 'package:flutter/material.dart';
import 'dart:async';
import '../model/OLAViolateRecord.dart';
import '../service/UrgentRecordService.dart';
import 'OLAViolateRecordDetailsScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UrgentRecordScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UrgentRecordScreen({super.key, required this.user});

  @override
  _UrgentRecordScreenState createState() => _UrgentRecordScreenState();
}

class _UrgentRecordScreenState extends State<UrgentRecordScreen>
    with SingleTickerProviderStateMixin {
  final _service = UrgentRecordService();
  late Future<Map<String, dynamic>> _futureRecords;
  int _page = 1;
  final int _pageSize = 10;
  String? _searchTerm;
  int? _workgroupId; // Optional workgroup filter
  List<OLAViolateRecord> _allRecords = [];
  int _totalPages = 1;
  int _totalCount = 0;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingUrgentCount = false;
  String? _errorMessage;
  String? _urgentCountError;
  int _urgentRecordCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _futureRecords = _fetchRecords();
    _fetchUrgentRecordCount(); // Initialize count fetch
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  Future<Map<String, dynamic>> _fetchRecords({int page = 1}) async {
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
      final List<OLAViolateRecord> newRecords =
          (result['records'] as List<dynamic>?)?.cast<OLAViolateRecord>() ?? [];
      final int totalCount = result['totalCount'] as int? ?? 0;
      final int totalPages = result['totalPages'] as int? ?? 1;
      final int currentPage = result['currentPage'] as int? ?? 1;

      if (kDebugMode) {
        print(
            'Parsed ${newRecords.length} records, page: $page, total: $totalCount, totalPages: $totalPages, currentPage: $currentPage');
        print('Records: ${newRecords.map((r) => r.peNumber).toList()}');
      }

      setState(() {
        _allRecords = newRecords;
        _page = page;
        _totalCount = totalCount;
        _totalPages = totalPages;
        _currentPage = currentPage;
        _isLoading = false;
        if (_allRecords.isNotEmpty) {
          _animationController.forward();
        }
      });

      return {
        'records': newRecords,
        'totalCount': totalCount,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch records failed: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      return {
        'records': [],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': 1,
      };
    }
  }

  Future<void> _fetchUrgentRecordCount() async {
    setState(() {
      _isLoadingUrgentCount = true;
      _urgentCountError = null;
    });
    try {
      final result = await _service.fetchUrgentRecords(
        page: 1,
        pageSize: 1,
        workgroupId: _workgroupId,
      );
      setState(() {
        _urgentRecordCount = result['totalCount'] as int? ?? 0;
        _isLoadingUrgentCount = false;
      });
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _urgentCountError = 'Failed to load urgent count: $e';
          _isLoadingUrgentCount = false;
        });
        debugPrint(_urgentCountError);
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<int> _getPageNumbers() {
    if (_totalPages <= 3) {
      return List.generate(_totalPages, (index) => index + 1);
    }
    List<int> pages = [1];
    int middlePage = _page.clamp(2, _totalPages - 1);
    if (_totalPages > 3) {
      pages.add(middlePage);
    }
    pages.add(_totalPages);
    return pages.toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Urgent Records',
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
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _futureRecords,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _allRecords.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || (_allRecords.isEmpty && !_isLoading)) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            snapshot.hasError
                                ? 'Error: ${snapshot.error}'
                                : _errorMessage ??
                                    (_searchTerm != null
                                        ? 'No urgent records found for search: $_searchTerm'
                                        : 'No urgent records found.'),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => setState(() {
                              _page = 1;
                              _allRecords = [];
                              _futureRecords = _fetchRecords(page: 1);
                            }),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
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
                              const Icon(Icons.list,
                                  size: 24, color: Colors.white),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: ExpansionTile(
                              title: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                title: Text(
                                  'PE Number: ${record.peNumber ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Customer: ${record.customer ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ),
                              children: [
                                _buildFieldRow('Service Type',
                                    record.serviceType ?? 'N/A'),
                                _buildFieldRow(
                                    'Status', record.peStatus ?? 'N/A'),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[600],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          print(
                                              'Navigating to OLAViolateRecordDetailsScreen');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OLAViolateRecordDetailsScreen(
                                                      record: record),
                                            ),
                                          );
                                        },
                                        child: const Text('View Full Details'),
                                      ),
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
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _totalPages > 1
          ? Container(
              height: 60,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: _page == 1 || _isLoading
                        ? Colors.grey
                        : const Color.fromARGB(255, 14, 5, 75),
                    tooltip: 'Previous Page',
                    onPressed: _page == 1 || _isLoading
                        ? null
                        : () {
                            setState(() {
                              _futureRecords = _fetchRecords(page: _page - 1);
                            });
                          },
                  ),
                  const SizedBox(width: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getPageNumbers().asMap().entries.map((entry) {
                        final pageNumber = entry.value;
                        final isLast =
                            entry.key == _getPageNumbers().length - 1;
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _futureRecords =
                                            _fetchRecords(page: pageNumber);
                                      });
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  gradient: _page == pageNumber
                                      ? const LinearGradient(
                                          colors: [
                                            Color.fromARGB(213, 89, 211, 99),
                                            Color.fromARGB(255, 4, 152, 16),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: _page == pageNumber
                                      ? null
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$pageNumber',
                                  style: TextStyle(
                                    color: _page == pageNumber
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (!isLast &&
                                _getPageNumbers()[entry.key + 1] !=
                                    pageNumber + 1) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('...',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black54)),
                              ),
                            ],
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 24),
                    color: _page == _totalPages || _isLoading
                        ? Colors.grey
                        : Colors.green[600],
                    tooltip: 'Next Page',
                    onPressed: _page == _totalPages || _isLoading
                        ? null
                        : () {
                            setState(() {
                              _futureRecords = _fetchRecords(page: _page + 1);
                            });
                          },
                  ),
                ],
              ),
            )
          : null,
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
            ),
          ),
        ],
      ),
    );
  }
}

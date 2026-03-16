import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../service/OLAViolateRecordService.dart';
import '../service/RegularRecordService.dart';
import '../service/UrgentRecordService.dart';
import '../service/HoldRecordService.dart';
import '../service/TaskQueueService.dart';
import '../service/NoticeService.dart';
import '../model/Notice.dart';
import 'RecordDetailsScreen.dart';
import 'SearchResultsScreen.dart';
import 'UrgentRecordScreen.dart';
import 'RegularRecordScreen.dart';
import 'OLAViolateRecordScreen.dart';
import 'HoldRecordScreen.dart';
import 'TaskQueueScreen.dart';

class DashboardHome extends StatefulWidget {
  final int userId;
  final List<int> selectedWorkGroupIds;
  const DashboardHome({
    super.key,
    required this.userId,
    this.selectedWorkGroupIds = const [], // <- default empty list
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  String selectedSearchBy = 'PE Number';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;

  int? _olaViolateCount;
  bool _isLoadingOlaCount = false;
  String? _olaCountError;

  int? _regularRecordCount;
  bool _isLoadingRegularCount = false;
  String? _regularCountError;

  int? _urgentRecordCount;
  bool _isLoadingUrgentCount = false;
  String? _urgentCountError;

  int? _holdRecordCount;
  bool _isLoadingHoldCount = false;
  String? _holdCountError;

  List<Notice>? _notices;
  bool _isLoadingNotices = false;
  String? _noticesError;

  final OLAViolateRecordService _olaService = OLAViolateRecordService();
  final RegularRecordService _regularService = RegularRecordService();
  final UrgentRecordService _urgentService = UrgentRecordService();
  final HoldRecordService _holdService = HoldRecordService();
  final TaskQueueService taskQueueService = TaskQueueService(
    accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
  );
  final NoticeService _noticeService = NoticeService(
    accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
  );

  @override
  void initState() {
    super.initState();
    _fetchOlaViolateCount();
    _fetchRegularRecordCount();
    _fetchUrgentRecordCount();
    _fetchHoldRecordCount();
    _fetchNotices();
  }

  Future<void> _fetchOlaViolateCount() async {
    setState(() {
      _isLoadingOlaCount = true;
      _olaCountError = null;
    });
    try {
      final result =
          await _olaService.fetchOLAViolateRecords(page: 1, pageSize: 1);
      setState(() {
        _olaViolateCount = result['totalCount'] ?? 0;
        _isLoadingOlaCount = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _olaCountError = 'Failed to load OLA count: $e';
          _isLoadingOlaCount = false;
        });
        debugPrint(_olaCountError);
      }
    }
  }

  Future<void> _fetchRegularRecordCount() async {
    setState(() {
      _isLoadingRegularCount = true;
      _regularCountError = null;
    });
    try {
      final result =
          await _regularService.fetchRegularRecords(page: 1, pageSize: 1);
      setState(() {
        _regularRecordCount = result['totalCount'] ?? 0;
        _isLoadingRegularCount = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _regularCountError = 'Failed to load regular count: $e';
          _isLoadingRegularCount = false;
        });
        debugPrint(_regularCountError);
      }
    }
  }

  Future<void> _fetchUrgentRecordCount() async {
    setState(() {
      _isLoadingUrgentCount = true;
      _urgentCountError = null;
    });
    try {
      final result =
          await _urgentService.fetchUrgentRecords(page: 1, pageSize: 1);
      setState(() {
        _urgentRecordCount = result['totalCount'] ?? 0;
        _isLoadingUrgentCount = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _urgentCountError = 'Failed to load urgent count: $e';
          _isLoadingUrgentCount = false;
        });
        debugPrint(_urgentCountError);
      }
    }
  }

  Future<void> _fetchHoldRecordCount() async {
    setState(() {
      _isLoadingHoldCount = true;
      _holdCountError = null;
    });
    try {
      final result = await _holdService.getHoldRecords(pageSize: 1);
      final List records = result['records'] ?? [];
      setState(() {
        _holdRecordCount = records.length;
        _isLoadingHoldCount = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _holdCountError = 'Failed to load hold count: $e';
          _isLoadingHoldCount = false;
        });
        debugPrint(_holdCountError);
      }
    }
  }

  Future<void> _fetchNotices() async {
    setState(() {
      _isLoadingNotices = true;
      _noticesError = null;
    });
    try {
      final notices = await _noticeService.getActiveNotices();
      if (mounted) {
        setState(() {
          _notices = notices;
          _isLoadingNotices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _noticesError = 'Failed to load notices: $e';
          _isLoadingNotices = false;
        });
        debugPrint(_noticesError);
      }
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search value')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String query =
          '$apiUrl/api/PERecordsApi/filter?page=1&pageSize=1000&searchCategory=${Uri.encodeComponent(selectedSearchBy)}&searchValue=${Uri.encodeComponent(_searchController.text.trim())}';
      debugPrint('API Request URL: $query');

      final response = await http.get(
        Uri.parse(query),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['ACCESS_TOKEN'] ?? ''}',
        },
      );

      debugPrint('Raw API Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] != true) {
          throw Exception(
              'API returned unsuccessful response: ${responseData['message']}');
        }

        // Try 'values' first, fallback to '$values' for compatibility
        final List<dynamic> records = responseData['data']?['values'] ??
            responseData['data']?['\$values'] ??
            [];

        if (records.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'No records found for "$selectedSearchBy: ${_searchController.text.trim()}"')),
          );
        } else if (records.length == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordDetailsScreen(
                record: records[0],
                searchCategory: selectedSearchBy,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                userId: widget.userId,
                searchResults: {
                  'records': records,
                  'totalCount': responseData['pagination']?['totalRecords'] ??
                      records.length,
                  'totalPages': responseData['pagination']?['totalPages'] ?? 1,
                  'currentPage':
                      responseData['pagination']?['currentPage'] ?? 1,
                },
                searchCategory: selectedSearchBy,
                searchValue: _searchController.text.trim(),
                user: const {},
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${response.statusCode} - ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      debugPrint('Network or Parsing Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Search Section
            _buildSearchSection(),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGridSection(),
                    const SizedBox(height: 20),
                    _buildTaskQueueSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isSearching
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter $selectedSearchBy',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 1,
                    ),
                    onPressed: _isLoading ? null : _performSearch,
                    child: _isLoading
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Search',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                ),
              ],
            )
          : Row(
              children: [
                Flexible(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSearchBy,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    items: <String>[
                      'PE Number',
                      'Province',
                      'Customer',
                      'SO Number'
                    ]
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => selectedSearchBy = newValue);
                      }
                      _searchController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    setState(() => _isSearching = true);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildGridSection() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildGridItem(
          context,
          title: 'Urgent Records',
          gradientColors: [
            const Color.fromARGB(255, 247, 155, 154),
            const Color.fromARGB(255, 193, 102, 102)
          ],
          imagePath: 'assets/images/Urgent.png',
          taskColor: Colors.red.shade400,
          taskCount: _urgentRecordCount ?? 0,
          isLoading: _isLoadingUrgentCount,
          error: _urgentCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UrgentRecordScreen(user: {})),
          ),
        ),
        _buildGridItem(
          context,
          title: 'Regular Records',
          gradientColors: [
            const Color.fromARGB(255, 187, 247, 190),
            const Color.fromARGB(255, 133, 207, 136)
          ],
          imagePath: 'assets/images/Regular.png',
          taskColor: const Color(0xFF4CAF50),
          taskCount: _regularRecordCount ?? 0,
          isLoading: _isLoadingRegularCount,
          error: _regularCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const RegularRecordScreen(user: {})),
          ),
        ),
        _buildGridItem(
          context,
          title: 'OLA Violate Records',
          gradientColors: [
            const Color.fromARGB(255, 192, 201, 253),
            const Color.fromARGB(255, 128, 134, 206)
          ],
          imagePath: 'assets/images/OLA violate.png',
          taskColor: const Color(0xFF3F51B5),
          taskCount: _olaViolateCount ?? 0,
          isLoading: _isLoadingOlaCount,
          error: _olaCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const OLAViolateRecordScreen()),
          ),
        ),
        _buildGridItem(
          context,
          title: 'Hold Records',
          gradientColors: [
            const Color.fromARGB(255, 249, 231, 176),
            const Color.fromARGB(255, 248, 200, 158)
          ],
          imagePath: 'assets/images/Hold.png',
          taskColor: const Color(0xFFFFA000),
          taskCount: _holdRecordCount ?? 0,
          isLoading: _isLoadingHoldCount,
          error: _holdCountError,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HoldRecordScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskQueueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Queue Container
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskQueueScreen(
                accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 153, 206, 249),
                  Color.fromARGB(255, 128, 176, 218)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Task Queue',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskQueueScreen(
                            accessToken: dotenv.env['ACCESS_TOKEN'] ?? '',
                          ),
                        ),
                      ),
                      child: const Text(
                        'View All Tasks',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Notices Container
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE0E0E0), Color(0xFFB0BEC5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notices',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _isLoadingNotices
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : _noticesError != null
                      ? Text(
                          'Error loading notices',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12,
                          ),
                        )
                      : _notices == null || _notices!.isEmpty
                          ? const Text(
                              'No active notices',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            )
                          : SizedBox(
                              height: 150, // Fixed height with scrolling
                              child: ListView.builder(
                                itemCount: _notices!.length,
                                itemBuilder: (context, index) {
                                  final notice = _notices![index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (notice.isPinned ?? false)
                                            const Icon(
                                              Icons.push_pin,
                                              color: Colors.blue,
                                              size: 16,
                                            ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notice.description ??
                                                      'No description',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'By:${notice.createdUserName} ${notice.createdDate?.toString().substring(0, 10) ?? 'Unknown'}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required List<Color> gradientColors,
    required String imagePath,
    required Color taskColor,
    required int taskCount,
    bool isLoading = false,
    String? error,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  imagePath,
                  height: 70,
                  width: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : Text(
                        error != null
                            ? 'Error'
                            : '$taskCount Task${taskCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: error != null ? Colors.red : taskColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

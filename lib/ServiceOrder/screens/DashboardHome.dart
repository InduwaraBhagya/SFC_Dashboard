import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../service/OLAViolateRecordService.dart';
import '../service/RegularRecordService.dart';
import '../service/UrgentRecordService.dart';
import '../service/HoldRecordService.dart';
import 'RecordDetailsScreen.dart';
import 'SearchResultsScreen.dart';
import 'UrgentRecordScreen.dart';
import 'RegularRecordScreen.dart';
import 'OLAViolateRecordScreen.dart';
import 'HoldRecordScreen.dart';
import '../service/NoticeService.dart';
import '../model/Notice.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool _isLoadingNotices = false;
  String? _noticesError;
  List<Notice>? _notices = [];
  String selectedSearchBy = 'PE Number';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
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

  final OLAViolateRecordService _olaService = OLAViolateRecordService();
  final RegularRecordService _regularService = RegularRecordService();
  final UrgentRecordService _urgentService = UrgentRecordService();
  final HoldRecordService _holdService = HoldRecordService();

  @override
  void initState() {
    super.initState();
    _fetchOlaViolateCount();
    _fetchRegularRecordCount();
    _fetchUrgentRecordCount();
    _fetchHoldRecordCount();
  }

  Future<void> _fetchOlaViolateCount() async {
    setState(() {
      _isLoadingOlaCount = true;
      _olaCountError = null;
    });
    try {
      final result = await _olaService.fetchOLAViolateRecords(
        page: 1,
        pageSize: 1,
      );
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
      final result = await _regularService.fetchRegularRecords(
        page: 1,
        pageSize: 1,
      );
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
      final result = await _urgentService.fetchUrgentRecords(
        page: 1,
        pageSize: 1,
      );
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
      await _holdService.getHoldRecords();
      setState(() {
        _holdRecordCount = _holdService.getTotalCount();
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
      final String fullApiUrl = '$apiUrl/api/PERecordsApi/search';
      final String query =
          '$fullApiUrl?searchCategory=${Uri.encodeComponent(selectedSearchBy)}&searchValue=${Uri.encodeComponent(_searchController.text.trim())}&pageSize=1000';
      debugPrint('API Request URL: $query');

      final response = await http.get(
        Uri.parse(query),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> records = responseData['data']?['\$values'] is List
            ? responseData['data']['\$values'] as List<dynamic>
            : [];

        if (records.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No records found for "$selectedSearchBy: ${_searchController.text.trim()}"',
              ),
            ),
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
                searchResults: {'records': records},
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
                'Error: ${response.statusCode} - ${response.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Network or Parsing Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search By:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ) ??
                        const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedSearchBy,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
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
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedSearchBy = newValue;
                          _searchController.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$selectedSearchBy:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ) ??
                        const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            labelText: 'Enter $selectedSearchBy',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.blue),
                          ),
                          style: const TextStyle(color: Colors.black87),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _performSearch,
                        child: _isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Search',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGridItem(
                  context,
                  title: 'Urgent Records',
                  gradientColors: [
                    const Color.fromARGB(242, 214, 96, 96),
                    const Color.fromARGB(255, 164, 2, 2),
                  ],
                  imagePath: 'assets/images/Urgent.png',
                  taskColor: Colors.red,
                  taskCount: _urgentRecordCount ?? 0,
                  isLoading: _isLoadingUrgentCount,
                  error: _urgentCountError,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const UrgentRecordScreen(user: {})),
                  ).catchError((e) => debugPrint(
                      'Navigation error to UrgentRecordScreen: $e')),
                ),
                _buildGridItem(
                  context,
                  title: 'Regular Records',
                  gradientColors: [
                    const Color.fromARGB(213, 89, 211, 99),
                    const Color.fromARGB(255, 4, 152, 16),
                  ],
                  imagePath: 'assets/images/Regular.png',
                  taskColor: const Color.fromARGB(255, 72, 252, 114),
                  taskCount: _regularRecordCount ?? 0,
                  isLoading: _isLoadingRegularCount,
                  error: _regularCountError,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegularRecordScreen(
                        user: {}, // Replace with actual user data
                      ),
                    ),
                  ).catchError((e) => debugPrint(
                      'Navigation error to RegularRecordScreen: $e')),
                ),
                _buildGridItem(
                  context,
                  title: 'OLA Violate Records',
                  gradientColors: [
                    const Color.fromARGB(225, 82, 126, 238),
                    const Color.fromARGB(255, 7, 0, 99),
                  ],
                  imagePath: 'assets/images/OLA violate.png',
                  taskColor: const Color.fromARGB(255, 45, 45, 228),
                  taskCount: _olaViolateCount ?? 0,
                  isLoading: _isLoadingOlaCount,
                  error: _olaCountError,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OLAViolateRecordScreen(
                        user: {}, // Replace with actual user data
                      ),
                    ),
                  ).catchError((e) => debugPrint(
                      'Navigation error to OLAViolateRecordScreen: $e')),
                ),
                _buildGridItem(
                  context,
                  title: 'Hold Records',
                  gradientColors: [
                    const Color.fromARGB(255, 240, 181, 4),
                    const Color.fromARGB(255, 251, 236, 101),
                  ],
                  imagePath: 'assets/images/Hold.png',
                  taskColor: const Color.fromARGB(255, 226, 186, 64),
                  taskCount: _holdRecordCount ?? 0,
                  isLoading: _isLoadingHoldCount,
                  error: _holdCountError,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HoldRecordScreen()),
                  ).catchError((e) =>
                      debugPrint('Navigation error to HoldRecordScreen: $e')),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 16),
            // Notices Container
            Container(
              padding: const EdgeInsets.all(15.0),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
        ),
      ),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  imagePath,
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Image load error for $imagePath: $error');
                    return const Icon(Icons.error, color: Colors.red);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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

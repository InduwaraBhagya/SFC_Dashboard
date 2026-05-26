import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'DashboardScreen.dart';
import '../model/PERecord.dart';
import '../service/PERecordService.dart';
import 'PEDetailsScreen.dart';

/// Standalone "View PE Details" screen:
/// User searches by PE Number / Customer / SO Number,
/// picks a result, and sees full details.
class PEDetailsSearchScreen extends StatefulWidget {
  const PEDetailsSearchScreen({super.key});

  @override
  State<PEDetailsSearchScreen> createState() => _PEDetailsSearchScreenState();
}

class _PEDetailsSearchScreenState extends State<PEDetailsSearchScreen> {
  final PERecordService _service = PERecordService();
  final TextEditingController _searchController = TextEditingController();
  String _searchBy = 'PE_NUMBER';
  List<PERecord> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final storedId = await _storage.read(key: 'userId');
    if (storedId != null) {
      setState(() {
        _userId = int.tryParse(storedId);
      });
    }
  }

  final List<Map<String, String>> _searchCategories = [
    {'label': 'PE Number', 'value': 'PE_NUMBER'},
    {'label': 'Customer', 'value': 'CUSTOMER'},
    {'label': 'SO Number', 'value': 'SO_NUMBER'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search term.')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
      _errorMessage = null;
      _results = [];
    });

    try {
      String category = 'PE Number';
      if (_searchBy == 'CUSTOMER') category = 'Customer';
      if (_searchBy == 'SO_NUMBER') category = 'SO Number';

      final result = await _service.fetchPERecords(
        page: 1,
        pageSize: 50,
        searchCategory: category,
        searchTerm: query,
      );

      setState(() {
        _results = result['records'] as List<PERecord>;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed. Please try again.';
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  String get _hintText {
    switch (_searchBy) {
      case 'CUSTOMER':
        return 'e.g. SLT, Dialog...';
      case 'SO_NUMBER':
        return 'e.g. SO-2024-001';
      default:
        return 'e.g. PE-2024-001';
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'IN PROGRESS':
      case 'INPROGRESS':
        return Colors.blue;
      case 'HOLD':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_userId != null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(userId: _userId!),
                ),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'View PE Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      body: Column(
        children: [
          // ── Search panel ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search for a PE record',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 16, 37, 89),
                  ),
                ),
                const SizedBox(height: 10),
                // Search type selector
                Row(
                  children: _searchCategories.map((cat) {
                    final selected = _searchBy == cat['value'];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _searchBy = cat['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color.fromARGB(255, 16, 37, 89)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? const Color.fromARGB(255, 16, 37, 89)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              cat['label']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // Search field + button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _hintText,
                          prefixIcon: const Icon(Icons.search,
                              color: Color.fromARGB(255, 16, 37, 89)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 16, 37, 89),
                              width: 2,
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _results = [];
                                      _hasSearched = false;
                                    });
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : _search,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 16, 37, 89),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Search',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Results ───────────────────────────────────────────────
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? _buildIdle()
                    : _errorMessage != null
                        ? _buildError()
                        : _results.isEmpty
                            ? _buildEmpty()
                            : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildIdle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Search by PE Number, Customer,\nor SO Number to view details.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.find_in_page_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No PE records found for\n"${_searchController.text.trim()}"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or category.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final pe = _results[index];
        final sc = _statusColor(pe.peStatus);

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PEDetailsScreen(peRecord: pe),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status accent
                  Container(
                    width: 4,
                    height: 56,
                    decoration: BoxDecoration(
                      color: sc,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pe.peNumber ?? '—',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 16, 37, 89),
                                ),
                              ),
                            ),
                            if (pe.peStatus != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sc.withOpacity(0.1),
                                  border: Border.all(color: sc),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pe.peStatus!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: sc,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (pe.peTitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              pe.peTitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 12,
                            children: [
                              if (pe.customer != null)
                                _infoChip(Icons.person_outline, pe.customer!),
                              if (pe.soNumber != null)
                                _infoChip(Icons.receipt_outlined,
                                    'SO: ${pe.soNumber!}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Color.fromARGB(255, 16, 37, 89)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

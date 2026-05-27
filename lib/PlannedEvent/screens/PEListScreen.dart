import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/PERecord.dart';
import '../service/PERecordService.dart';
import 'PEDetailsScreen.dart';

class PEListScreen extends StatefulWidget {
  const PEListScreen({super.key});

  @override
  State<PEListScreen> createState() => _PEListScreenState();
}

class _PEListScreenState extends State<PEListScreen> {
  final PERecordService _service = PERecordService();
  final TextEditingController _searchController = TextEditingController();

  List<PERecord> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  final int _pageSize = 15;

  String _searchBy = 'PE_NUMBER';
  String _searchValue = '';

  final List<Map<String, String>> _searchCategories = [
    {'label': 'PE Number', 'value': 'PE_NUMBER'},
    {'label': 'Customer', 'value': 'CUSTOMER'},
    {'label': 'SO Number', 'value': 'SO_NUMBER'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String category = 'PE Number';
      if (_searchBy == 'CUSTOMER') category = 'Customer';
      if (_searchBy == 'SO_NUMBER') category = 'SO Number';

      final result = await _service.fetchPERecords(
        page: page,
        pageSize: _pageSize,
        searchCategory: category,
        searchTerm: _searchValue.isNotEmpty ? _searchValue : null,
      );

      setState(() {
        _records = result['records'] as List<PERecord>;
        _totalCount = result['totalCount'] as int;
        _totalPages = result['totalPages'] as int;
        _currentPage = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load PE records. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    setState(() {
      _searchValue = _searchController.text.trim();
    });
    _loadRecords(page: 1);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchValue = '';
    });
    _loadRecords(page: 1);
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
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'View PE List',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () => _loadRecords(page: _currentPage),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Category dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _searchBy,
                          isDense: true,
                          items: _searchCategories
                              .map((cat) => DropdownMenuItem<String>(
                                    value: cat['value'],
                                    child: Text(
                                      cat['label']!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _searchBy = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(226, 16, 37, 89),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (!_isLoading)
                  Text(
                    _searchValue.isNotEmpty
                        ? 'Results for "$_searchValue" — $_totalCount record(s)'
                        : 'Total: $_totalCount records',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildError()
                    : _records.isEmpty
                        ? _buildEmpty()
                        : _buildList(),
          ),

          // ── Pagination ──────────────────────────────────────────
          if (!_isLoading && _totalPages > 1) _buildPagination(),
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
            onPressed: () => _loadRecords(page: _currentPage),
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
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            _searchValue.isNotEmpty
                ? 'No records found for "$_searchValue"'
                : 'No PE records available',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          if (_searchValue.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final pe = _records[index];
        final statusColor = _statusColor(pe.peStatus);

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
                  // Left accent bar
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pe.peNumber ?? 'No PE Number',
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
                                  color: statusColor.withOpacity(0.1),
                                  border: Border.all(color: statusColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pe.peStatus!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (pe.isHold == true)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'HOLD',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (pe.peTitle != null)
                          Text(
                            pe.peTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (pe.customer != null) ...[
                              Icon(Icons.person_outline,
                                  size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  pe.customer!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                            if (pe.soNumber != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.receipt_outlined,
                                  size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 2),
                              Text(
                                pe.soNumber!,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                        if (pe.peCreatedDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Created: ${pe.peCreatedDate!.split('T').first}',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade500),
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

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 1 ? () => _loadRecords(page: 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () => _loadRecords(page: _currentPage - 1)
                : null,
          ),
          Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages
                ? () => _loadRecords(page: _currentPage + 1)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < _totalPages
                ? () => _loadRecords(page: _totalPages)
                : null,
          ),
        ],
      ),
    );
  }
}

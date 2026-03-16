import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../model/AreaNetworkEngineer.dart';
import '../service/AreaNetworkEngineerService.dart';
import 'DashboardHome.dart'; // Adjust this import based on your actual DashboardHome location

class AreaNetworkEngineerScreen extends StatefulWidget {
  final int userId;
  const AreaNetworkEngineerScreen({super.key, required this.userId});

  @override
  _AreaNetworkEngineerScreenState createState() =>
      _AreaNetworkEngineerScreenState();
}

class _AreaNetworkEngineerScreenState extends State<AreaNetworkEngineerScreen> {
  final AreaNetworkEngineerService _service = AreaNetworkEngineerService();
  late Future<List<AreaNetworkEngineer>> _engineersFuture;
  List<AreaNetworkEngineer> _engineers = [];
  List<AreaNetworkEngineer> _filteredEngineers = [];
  String? _errorMessage;
  final int _recordsPerPage = 10;
  late PageController _pageController;
  int _currentPage = 0;
  bool _isSearchBarExpanded = false; // Track search bar expansion state
  final TextEditingController _areaController = TextEditingController();
  String? _engineerName;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _engineersFuture = _service.getAllEngineers().catchError((e) {
      print('Error in initState: $e');
      setState(() {
        _errorMessage = 'Failed to load engineers: $e';
      });
      return <AreaNetworkEngineer>[];
    });
    _engineersFuture.then((data) {
      setState(() {
        _engineers = data;
        _filteredEngineers = data;
        _errorMessage = null;
      });
    }).catchError((e) {
      setState(() {
        _errorMessage = 'Failed to process engineers: $e';
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _filterEngineers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEngineers = _engineers;
      } else {
        _filteredEngineers = _engineers.where((engineer) {
          final name = engineer.engineerName?.toLowerCase() ?? '';
          final id = engineer.id.toString();
          final area = engineer.area?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              id.contains(query) ||
              area.contains(query.toLowerCase());
        }).toList();
      }
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (_filteredEngineers.length / _recordsPerPage).ceil();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: _isSearchBarExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              children: [
                // Search Icon and Expandable Search Bar
                _isSearchBarExpanded
                    ? Expanded(
                        child: TextField(
                          onChanged: _filterEngineers,
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Search by Name, ID, or Area',
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade600),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.blue.shade700),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.close,
                                  color: Colors.blue.shade700),
                              onPressed: () {
                                setState(() {
                                  _isSearchBarExpanded = false;
                                  _filterEngineers(''); // Clear search
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.search,
                            color: Colors.blue.shade700, size: 28),
                        tooltip: 'Search Engineers',
                        onPressed: () {
                          setState(() {
                            _isSearchBarExpanded = true;
                          });
                        },
                      ),
                // Total Records
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isSearchBarExpanded ? 8 : 12,
                    vertical: _isSearchBarExpanded ? 6 : 8,
                  ),
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
                    children: [
                      if (!_isSearchBarExpanded) ...[
                        Icon(
                          Icons.list,
                          size: _isSearchBarExpanded ? 16 : 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _isSearchBarExpanded
                            ? '${_filteredEngineers.length}'
                            : 'Total Records: ${_filteredEngineers.length}',
                        style: GoogleFonts.poppins(
                          fontSize: _isSearchBarExpanded ? 20 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_engineerName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Engineer: $_engineerName',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<AreaNetworkEngineer>>(
              future: _engineersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Container(
                          height: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                } else if (_errorMessage != null) {
                  return Center(
                    child: Card(
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
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 4, 24, 96),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardHome(userId: widget.userId)),
                                );
                              },
                              child: Text(
                                'Back to Dashboard',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Card(
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
                              'No engineers found',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 4, 24, 96),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardHome(userId: widget.userId)),
                                );
                              },
                              child: Text(
                                'Back to Dashboard',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: totalPages,
                        itemBuilder: (context, pageIndex) {
                          final startIndex = pageIndex * _recordsPerPage;
                          final endIndex = (startIndex + _recordsPerPage)
                              .clamp(0, _filteredEngineers.length);
                          final pageRecords =
                              _filteredEngineers.sublist(startIndex, endIndex);

                          return ListView.builder(
                            itemCount: pageRecords.length,
                            itemBuilder: (context, index) {
                              final engineer = pageRecords[index];
                              return Card(
                                key: ValueKey(engineer.id),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              engineer.engineerName ??
                                                  'Unknown',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildFieldRow(
                                          'ID', engineer.id.toString()),
                                      _buildFieldRow(
                                          'Area', engineer.area ?? 'N/A'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(totalPages, (index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _currentPage == index
                                        ? const Color.fromARGB(255, 4, 24, 96)
                                        : Colors.grey.shade300,
                                    foregroundColor: _currentPage == index
                                        ? Colors.white
                                        : Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(40, 40),
                                  ),
                                  onPressed: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
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
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
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

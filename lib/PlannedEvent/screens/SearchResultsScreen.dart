import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'RecordDetailsScreen.dart';
import 'DashboardHome.dart';
import '../model/PERecord.dart';

class SearchResultsScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> searchResults;
  final String searchCategory;
  final String searchValue;
  final Map<String, dynamic> user;

  const SearchResultsScreen({
    super.key,
    required this.userId,
    required this.searchResults,
    required this.searchCategory,
    required this.searchValue,
    required this.user,
  });

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final int _recordsPerPage = 10; // Changed from 10 to 1000
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> records =
        widget.searchResults['records'] as List<dynamic>? ?? [];
    debugPrint('SearchResultsScreen Records: $records');

    final int totalPages = (records.length / _recordsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // change the color of the leading icon
        ),
        title: Text(
          '${widget.searchCategory}: ${widget.searchValue}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      ),
      body: records.isEmpty
          ? Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No results found for "${widget.searchValue}" in ${widget.searchCategory}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 4, 24, 96),
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
                        child: const Text('Back to Dashboard'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Container(
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
                      const Icon(Icons.list, size: 24, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Total Records: ${records.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
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
                          .clamp(0, records.length);
                      final pageRecords = records.sublist(startIndex, endIndex);

                      return CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final record = pageRecords[index];
                                final peRecord = PERecord.fromJson(
                                    record as Map<String, dynamic>);
                                return Card(
                                  key: ValueKey(peRecord.peNumber ?? index),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: ExpansionTile(
                                    title: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                      title: Text(
                                        'PE Number: ${peRecord.peNumber ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        'Customer: ${peRecord.customer ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    children: [
                                      _buildFieldRow('Service Type',
                                          peRecord.serviceType ?? 'N/A'),
                                      _buildFieldRow('Customer',
                                          peRecord.customer ?? 'N/A'),
                                      _buildFieldRow('Province',
                                          peRecord.province ?? 'N/A'),
                                      _buildFieldRow('SO Number',
                                          peRecord.soNumber ?? 'N/A'),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 7, 69, 156),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                elevation: 2,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RecordDetailsScreen(
                                                      record: record,
                                                      searchCategory:
                                                          widget.searchCategory,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                  'View Full Details'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: pageRecords.length,
                            ),
                          ),
                        ],
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
                                    : Colors.grey[300],
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
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Text('${index + 1}'),
                            ),
                          );
                        }),
                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}

// screens/PEIssuesScreen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../model/PEIsseueModel.dart';
import '../service/PEIssueService.dart';

class PEIssuesScreen extends StatefulWidget {
  final int userId;

  const PEIssuesScreen(
      {super.key, required this.userId, required List<int> workGroupIds});

  @override
  _PEIssuesScreenState createState() => _PEIssuesScreenState();
}

class _PEIssuesScreenState extends State<PEIssuesScreen>
    with SingleTickerProviderStateMixin {
  final PEService _peService = PEService();
  late Future<List<PEIssue>> _issuesFuture;
  List<PEIssue> _issues = [];
  List<PEIssue> _filteredIssues = [];
  Map<int, PEIssueResolution?> _resolutions = {};
  String? _errorMessage;
  final int _recordsPerPage = 10;
  late PageController _pageController;
  int _currentPage = 0;
  late TabController _tabController;
  int _unreadCount = 0;
  int _readCount = 0;
  int _allCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _issuesFuture = _loadIssues();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Updated: Safe loading with isolated resolution fetch
  Future<List<PEIssue>> _loadIssues() async {
    try {
      final issues = await _peService.getInboxIssues(widget.userId, 10);

      // Extract valid issue IDs
      final validIssueIds = issues
          .map((issue) => issue.id)
          .where((id) => id != null && id > 0)
          .cast<int>()
          .toList();

      Map<int, PEIssueResolution?> resolutions = {};

      // Only fetch resolutions if we have valid IDs
      if (validIssueIds.isNotEmpty) {
        resolutions = await _peService.getResolutionsByIssueIds(validIssueIds);
      }

      // Update UI state
      setState(() {
        _issues = issues;
        _unreadCount = issues.where((i) => !(i.isRead ?? true)).length;
        _readCount = issues.where((i) => i.isRead ?? false).length;
        _allCount = issues.length;
        _filteredIssues = _filterIssuesByTab(issues, _tabController.index);

        // Map resolutions safely
        _resolutions = {
          for (var issue in issues)
            if (issue.id != null && issue.id! > 0)
              issue.id!: resolutions[issue.id!]
        };

        _errorMessage = null;
      });

      return issues;
    } catch (e) {
      String userMessage = 'Failed to load issues. Please try again.';

      if (e.toString().contains('400')) {
        userMessage = 'Invalid request to server. Check your connection.';
      } else if (e.toString().contains('SocketException')) {
        userMessage = 'No internet connection.';
      }

      setState(() {
        _errorMessage = userMessage;
      });
      return [];
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _filteredIssues = _filterIssuesByTab(_issues, _tabController.index);
        _currentPage = 0;
        _pageController.jumpToPage(0);
      });
    }
  }

  List<PEIssue> _filterIssuesByTab(List<PEIssue> issues, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return issues.where((i) => !(i.isRead ?? true)).toList();
      case 1:
        return issues.where((i) => i.isRead ?? false).toList();
      case 2:
      default:
        return issues.toList();
    }
  }

  void _filterIssues(String query) {
    setState(() {
      _filteredIssues = _issues.where((issue) {
        final text = (issue.issueText ?? '').toLowerCase();
        final id = issue.id?.toString() ?? '';
        final matches =
            text.contains(query.toLowerCase()) || id.contains(query);
        return matches &&
            _filterIssuesByTab([issue], _tabController.index).isNotEmpty;
      }).toList();
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  Future<void> _showResolutionDetails(PEIssue issue) async {
    final resolution = _resolutions[issue.id ?? 0];
    if (resolution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No resolution found for issue #${issue.id}',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Resolution #${issue.id}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogFieldRow(
                'Details', resolution.resolutionDetails ?? 'N/A'),
            _buildDialogFieldRow(
                'Resolved On', resolution.resolutionDate?.toString() ?? 'N/A'),
            _buildDialogFieldRow(
                'Confirmed', resolution.isConfirmed == true ? 'Yes' : 'No'),
            _buildDialogFieldRow('Confirmation Requested',
                resolution.confirmationRequestedDate?.toString() ?? 'N/A'),
            _buildDialogFieldRow('Confirmed Date',
                resolution.confirmedDate?.toString() ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: GoogleFonts.poppins(color: Colors.blue.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogFieldRow(String label, String value) =>
      _buildFieldRow(label, value);

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: value == 'N/A' ? Colors.grey : null))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 4,
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              tabs: [
                _buildTab('Unread', _unreadCount, Colors.red),
                _buildTab('Read', _readCount, Colors.green),
                _buildTab('All', _allCount, Colors.blue),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<PEIssue>>(
                future: _issuesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmer();
                  } else if (_errorMessage != null) {
                    return _buildErrorCard(_errorMessage!);
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyCard();
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: List.generate(3, (_) => _buildIssueList()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int count, Color badgeColor) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: GoogleFonts.poppins(fontSize: 14)),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: badgeColor, borderRadius: BorderRadius.circular(12)),
              child: Text('$count',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
            margin: const EdgeInsets.all(8),
            child: Container(height: 120, color: Colors.white)),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(message,
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _issuesFuture = _loadIssues();
                  });
                },
                child: Text('Retry', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Text('No issues found', style: GoogleFonts.poppins(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildIssueList() {
    final totalPages = (_filteredIssues.length / _recordsPerPage).ceil();
    if (_filteredIssues.isEmpty) {
      return Center(
          child: Text('No issues in this tab', style: GoogleFonts.poppins()));
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: totalPages,
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * _recordsPerPage;
              final end =
                  (start + _recordsPerPage).clamp(0, _filteredIssues.length);
              final pageItems = _filteredIssues.sublist(start, end);

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: pageItems.length,
                itemBuilder: (context, index) {
                  final issue = pageItems[index];
                  final hasResolution = _resolutions[issue.id ?? 0] != null;

                  return Card(
                    key: ValueKey(issue.id),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  issue.issueText ?? 'No description',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (hasResolution)
                                IconButton(
                                  icon: const Icon(Icons.info,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _showResolutionDetails(issue),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildFieldRow('ID', issue.id?.toString() ?? 'N/A'),
                          _buildFieldRow('Resolved',
                              issue.isResolved == true ? 'Yes' : 'No'),
                          _buildFieldRow(
                              'Read', issue.isRead == true ? 'Yes' : 'No'),
                          _buildFieldRow(
                              'Created',
                              issue.createdAt?.toString().split('.').first ??
                                  'N/A'),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == i
                            ? const Color.fromARGB(255, 4, 24, 96)
                            : Colors.grey.shade300,
                        foregroundColor:
                            _currentPage == i ? Colors.white : Colors.black,
                        minimumSize: const Size(40, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _pageController.animateToPage(i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                      child: Text('${i + 1}', style: GoogleFonts.poppins()),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}

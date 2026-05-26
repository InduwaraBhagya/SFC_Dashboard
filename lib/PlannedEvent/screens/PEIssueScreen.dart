// // screens/PEIssuesScreen.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import '../model/PEIsseueModel.dart';
// import '../service/PEIssueService.dart';

// class PEIssuesScreen extends StatefulWidget {
//   final int userId;

//   const PEIssuesScreen(
//       {super.key, required this.userId, required List<int> workGroupIds});

//   @override
//   _PEIssuesScreenState createState() => _PEIssuesScreenState();
// }

// class _PEIssuesScreenState extends State<PEIssuesScreen>
//     with SingleTickerProviderStateMixin {
//   final PEService _peService = PEService();
//   late Future<List<PEIssue>> _issuesFuture;
//   List<PEIssue> _issues = [];
//   List<PEIssue> _filteredIssues = [];
//   Map<int, PEIssueResolution?> _resolutions = {};
//   String? _errorMessage;
//   final int _recordsPerPage = 10;
//   late PageController _pageController;
//   int _currentPage = 0;
//   late TabController _tabController;
//   int _unreadCount = 0;
//   int _readCount = 0;
//   int _allCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(_handleTabSelection);
//     _issuesFuture = _loadIssues();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   /// Updated: Safe loading with isolated resolution fetch
//   Future<List<PEIssue>> _loadIssues() async {
//     try {
//       final issues = await _peService.getInboxIssues(widget.userId, 10);

//       // Extract valid issue IDs
//       final validIssueIds = issues
//           .map((issue) => issue.id)
//           .where((id) => id != null && id > 0)
//           .cast<int>()
//           .toList();

//       Map<int, PEIssueResolution?> resolutions = {};

//       // Only fetch resolutions if we have valid IDs
//       if (validIssueIds.isNotEmpty) {
//         resolutions = await _peService.getResolutionsByIssueIds(validIssueIds);
//       }

//       // Update UI state
//       setState(() {
//         _issues = issues;
//         _unreadCount = issues.where((i) => !(i.isRead ?? true)).length;
//         _readCount = issues.where((i) => i.isRead ?? false).length;
//         _allCount = issues.length;
//         _filteredIssues = _filterIssuesByTab(issues, _tabController.index);

//         // Map resolutions safely
//         _resolutions = {
//           for (var issue in issues)
//             if (issue.id != null && issue.id! > 0)
//               issue.id!: resolutions[issue.id!]
//         };

//         _errorMessage = null;
//       });

//       return issues;
//     } catch (e) {
//       String userMessage = 'Failed to load issues. Please try again.';

//       if (e.toString().contains('400')) {
//         userMessage = 'Invalid request to server. Check your connection.';
//       } else if (e.toString().contains('SocketException')) {
//         userMessage = 'No internet connection.';
//       }

//       setState(() {
//         _errorMessage = userMessage;
//       });
//       return [];
//     }
//   }

//   void _handleTabSelection() {
//     if (!_tabController.indexIsChanging) {
//       setState(() {
//         _filteredIssues = _filterIssuesByTab(_issues, _tabController.index);
//         _currentPage = 0;
//         _pageController.jumpToPage(0);
//       });
//     }
//   }

//   List<PEIssue> _filterIssuesByTab(List<PEIssue> issues, int tabIndex) {
//     switch (tabIndex) {
//       case 0:
//         return issues.where((i) => !(i.isRead ?? true)).toList();
//       case 1:
//         return issues.where((i) => i.isRead ?? false).toList();
//       case 2:
//       default:
//         return issues.toList();
//     }
//   }

//   void _filterIssues(String query) {
//     setState(() {
//       _filteredIssues = _issues.where((issue) {
//         final text = (issue.issueText ?? '').toLowerCase();
//         final id = issue.id?.toString() ?? '';
//         final matches =
//             text.contains(query.toLowerCase()) || id.contains(query);
//         return matches &&
//             _filterIssuesByTab([issue], _tabController.index).isNotEmpty;
//       }).toList();
//       _currentPage = 0;
//       _pageController.jumpToPage(0);
//     });
//   }

//   Future<void> _showResolutionDetails(PEIssue issue) async {
//     final resolution = _resolutions[issue.id ?? 0];
//     if (resolution == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'No resolution found for issue #${issue.id}',
//             style: GoogleFonts.poppins(),
//           ),
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text(
//           'Resolution #${issue.id}',
//           style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDialogFieldRow(
//                 'Details', resolution.resolutionDetails ?? 'N/A'),
//             _buildDialogFieldRow(
//                 'Resolved On', resolution.resolutionDate?.toString() ?? 'N/A'),
//             _buildDialogFieldRow(
//                 'Confirmed', resolution.isConfirmed == true ? 'Yes' : 'No'),
//             _buildDialogFieldRow('Confirmation Requested',
//                 resolution.confirmationRequestedDate?.toString() ?? 'N/A'),
//             _buildDialogFieldRow('Confirmed Date',
//                 resolution.confirmedDate?.toString() ?? 'N/A'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Close',
//                 style: GoogleFonts.poppins(color: Colors.blue.shade700)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDialogFieldRow(String label, String value) =>
//       _buildFieldRow(label, value);

//   Widget _buildFieldRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//               flex: 2,
//               child: Text(label,
//                   style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.bold, fontSize: 14))),
//           Expanded(
//               flex: 3,
//               child: Text(value,
//                   style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: value == 'N/A' ? Colors.grey : null))),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(48.0),
//           child: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 4,
//             automaticallyImplyLeading: false,
//             bottom: TabBar(
//               controller: _tabController,
//               indicatorColor: Colors.blue,
//               labelColor: Colors.black87,
//               unselectedLabelColor: Colors.grey,
//               tabs: [
//                 _buildTab('Unread', _unreadCount, Colors.red),
//                 _buildTab('Read', _readCount, Colors.green),
//                 _buildTab('All', _allCount, Colors.blue),
//               ],
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: FutureBuilder<List<PEIssue>>(
//                 future: _issuesFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return _buildShimmer();
//                   } else if (_errorMessage != null) {
//                     return _buildErrorCard(_errorMessage!);
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return _buildEmptyCard();
//                   }

//                   return TabBarView(
//                     controller: _tabController,
//                     children: List.generate(3, (_) => _buildIssueList()),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(String text, int count, Color badgeColor) {
//     return Tab(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(text, style: GoogleFonts.poppins(fontSize: 14)),
//           if (count > 0) ...[
//             const SizedBox(width: 6),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                   color: badgeColor, borderRadius: BorderRadius.circular(12)),
//               child: Text('$count',
//                   style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmer() {
//     return ListView.builder(
//       itemCount: 5,
//       itemBuilder: (_, __) => Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         child: Card(
//             margin: const EdgeInsets.all(8),
//             child: Container(height: 120, color: Colors.white)),
//       ),
//     );
//   }

//   Widget _buildErrorCard(String message) {
//     return Center(
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.error_outline, size: 48, color: Colors.red),
//               const SizedBox(height: 12),
//               Text(message,
//                   style: GoogleFonts.poppins(fontSize: 16),
//                   textAlign: TextAlign.center),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _issuesFuture = _loadIssues();
//                   });
//                 },
//                 child: Text('Retry', style: GoogleFonts.poppins()),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyCard() {
//     return Center(
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child:
//               Text('No issues found', style: GoogleFonts.poppins(fontSize: 16)),
//         ),
//       ),
//     );
//   }

//   Widget _buildIssueList() {
//     final totalPages = (_filteredIssues.length / _recordsPerPage).ceil();
//     if (_filteredIssues.isEmpty) {
//       return Center(
//           child: Text('No issues in this tab', style: GoogleFonts.poppins()));
//     }

//     return Column(
//       children: [
//         Expanded(
//           child: PageView.builder(
//             controller: _pageController,
//             onPageChanged: (page) => setState(() => _currentPage = page),
//             itemCount: totalPages,
//             itemBuilder: (context, pageIndex) {
//               final start = pageIndex * _recordsPerPage;
//               final end =
//                   (start + _recordsPerPage).clamp(0, _filteredIssues.length);
//               final pageItems = _filteredIssues.sublist(start, end);

//               return ListView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: pageItems.length,
//                 itemBuilder: (context, index) {
//                   final issue = pageItems[index];
//                   final hasResolution = _resolutions[issue.id ?? 0] != null;

//                   return Card(
//                     key: ValueKey(issue.id),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     margin:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   issue.issueText ?? 'No description',
//                                   style: GoogleFonts.poppins(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               if (hasResolution)
//                                 IconButton(
//                                   icon: const Icon(Icons.info,
//                                       color: Colors.blue),
//                                   onPressed: () =>
//                                       _showResolutionDetails(issue),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           _buildFieldRow('ID', issue.id?.toString() ?? 'N/A'),
//                           _buildFieldRow('Resolved',
//                               issue.isResolved == true ? 'Yes' : 'No'),
//                           _buildFieldRow(
//                               'Read', issue.isRead == true ? 'Yes' : 'No'),
//                           _buildFieldRow(
//                               'Created',
//                               issue.createdAt?.toString().split('.').first ??
//                                   'N/A'),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//         if (totalPages > 1)
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(totalPages, (i) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _currentPage == i
//                             ? const Color.fromARGB(255, 4, 24, 96)
//                             : Colors.grey.shade300,
//                         foregroundColor:
//                             _currentPage == i ? Colors.white : Colors.black,
//                         minimumSize: const Size(40, 40),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                       ),
//                       onPressed: () => _pageController.animateToPage(i,
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut),
//                       child: Text('${i + 1}', style: GoogleFonts.poppins()),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// screens/PEIssuesScreen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../model/PEIsseueModel.dart';
import '../service/PEIssueService.dart';
import '../service/NoticeService.dart';
import '../service/UrgentRecordService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'UrgentRecordScreen.dart';
import '../model/Notice.dart';
import '../model/OLAViolateRecord.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/AuthService.dart';

class PEIssuesScreen extends StatefulWidget {
  final int userId;
  final List<int> workGroupIds;
  final VoidCallback? onRefreshCounts;

  const PEIssuesScreen(
      {super.key,
      required this.userId,
      required this.workGroupIds,
      this.onRefreshCounts});

  @override
  _PEIssuesScreenState createState() => _PEIssuesScreenState();
}

enum InboxItemType { issue, notice, urgent }

class InboxItem {
  final String id;
  final InboxItemType type;
  final String title;
  final String description;
  final DateTime? date;
  bool isRead;
  final dynamic originalData;

  InboxItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.date,
    this.isRead = false,
    this.originalData,
  });
}

class _PEIssuesScreenState extends State<PEIssuesScreen> {
  final PEService _peService = PEService();
  late Future<List<InboxItem>> _inboxFuture;
  List<InboxItem> _allInboxItems = [];
  Map<int, PEIssueResolution?> _resolutions = {};
  String? _errorMessage;
  final int _recordsPerPage = 10;
  late PageController _pageController;
  int _currentPage = 0;
  int _unreadCount = 0;

  final NoticeService _noticeService = NoticeService();
  final UrgentRecordService _urgentService = UrgentRecordService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _inboxFuture = _loadInbox();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<InboxItem>> _loadInbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seenNotices = prefs.getStringList('seen_notices') ?? [];
      final seenUrgent = prefs.getStringList('seen_urgent') ?? [];

      // 1. Fetch Notices
      List<Notice> notices = [];
      try {
        notices = await _noticeService.getActiveNotices();
      } catch (e) {
        debugPrint('Error fetching notices: $e');
      }

      // 2. Fetch Urgent Records
      List<OLAViolateRecord> urgentRecords = [];
      try {
        int? selectedWorkGroupId;
        bool useRealData = false;

        if (widget.workGroupIds.length == 1) {
            selectedWorkGroupId = widget.workGroupIds.first;
            try {
                final wgs = await AuthService().getWorkGroupsByIds(widget.workGroupIds);
                if (wgs.isNotEmpty) {
                    final wgName = wgs.first.name;
                    useRealData = (wgName != 'NET-PROJ_CABLE-ACC' && wgName != 'NET-PROJ-ACC-CABLE');
                }
            } catch (e) {
                debugPrint('Error checking workgroup name: $e');
            }
        }

        final urgentResult = await _urgentService.fetchUrgentRecords(
          page: 1,
          pageSize: 2000,
          workgroupId: selectedWorkGroupId,
          fetchMultiWorkgroup: useRealData,
        );
        urgentRecords = urgentResult['records'] ?? [];
      } catch (e) {
        debugPrint('Error fetching urgent records: $e');
      }

      // Merge into InboxItems
      List<InboxItem> items = [];

      // Notices
      items.addAll(notices.map((n) => InboxItem(
            id: 'notice_${n.id}',
            type: InboxItemType.notice,
            title: 'Alert: Notice',
            description: n.description ?? 'No description',
            date: n.createdDate,
            isRead: seenNotices.contains(n.id.toString()),
            originalData: n,
          )));

      // Urgent Records
      items.addAll(urgentRecords.map((u) => InboxItem(
            id: 'urgent_${u.peNumber}',
            type: InboxItemType.urgent,
            title: 'Urgent: ${u.peNumber}',
            description: '${u.customer ?? 'No Customer'} - ${u.province ?? ''}',
            date: u.woActualStartDate != null
                ? DateTime.tryParse(u.woActualStartDate!)
                : null,
            isRead: seenUrgent.contains(u.peNumber),
            originalData: u,
          )));

      // Sort by date descending
      items.sort(
          (a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));

      if (mounted) {
        setState(() {
          _allInboxItems = items;
          _unreadCount = items.where((i) => !i.isRead).length;
          _errorMessage = null;
        });
      }

      return items;
    } catch (e) {
      debugPrint('Error in _loadInbox: $e');
      setState(() => _errorMessage = 'Failed to load inbox items.');
      return [];
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _allInboxItems = _allInboxItems.where((item) {
        final matchesQuery =
            item.title.toLowerCase().contains(query.toLowerCase()) ||
                item.description.toLowerCase().contains(query.toLowerCase());
        return matchesQuery;
      }).toList();
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  Future<void> _markItemAsRead(InboxItem item) async {
    if (item.isRead) return;

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      item.isRead = true;
      _unreadCount = _allInboxItems.where((i) => !i.isRead).length;
    });

    // Notify Dashboard
    widget.onRefreshCounts?.call();

    // Persist status
    try {
      if (item.type == InboxItemType.issue) {
        final issue = item.originalData as PEIssue;
        await _peService.markAsRead(issue.id!);
      } else if (item.type == InboxItemType.notice) {
        final notice = item.originalData as Notice;
        final list = prefs.getStringList('seen_notices') ?? [];
        if (!list.contains(notice.id.toString())) {
          list.add(notice.id.toString());
          await prefs.setStringList('seen_notices', list);
        }
      } else if (item.type == InboxItemType.urgent) {
        final record = item.originalData as OLAViolateRecord;
        final list = prefs.getStringList('seen_urgent') ?? [];
        if (!list.contains(record.peNumber)) {
          list.add(record.peNumber!);
          await prefs.setStringList('seen_urgent', list);
        }
      }
    } catch (e) {
      debugPrint('Error persisting read status: $e');
    }
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text('Inbox Alerts',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('$_unreadCount',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<InboxItem>>(
        future: _inboxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          } else if (_errorMessage != null) {
            return _buildErrorCard(_errorMessage!);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyCard();
          }

          return RefreshIndicator(
            onRefresh: _loadInbox,
            child: _buildInboxList(),
          );
        },
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
                    _inboxFuture = _loadInbox();
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

  Widget _buildInboxList() {
    final totalPages = (_allInboxItems.length / _recordsPerPage).ceil();
    if (_allInboxItems.isEmpty) {
      return _buildEmptyCard();
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
                  (start + _recordsPerPage).clamp(0, _allInboxItems.length);
              final pageItems = _allInboxItems.sublist(start, end);

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: pageItems.length,
                itemBuilder: (context, index) {
                  final item = pageItems[index];

                  Color cardColor = Colors.white;
                  IconData icon = Icons.message;
                  Color iconColor = Colors.blue;

                  if (item.type == InboxItemType.notice) {
                    cardColor = Colors.orange.withOpacity(0.05);
                    icon = Icons.campaign;
                    iconColor = Colors.orange;
                  } else if (item.type == InboxItemType.urgent) {
                    cardColor = Colors.red.withOpacity(0.05);
                    icon = Icons.notification_important;
                    iconColor = Colors.red;
                  }

                  return Card(
                    elevation: item.isRead ? 2 : 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: !item.isRead
                            ? BorderSide(
                                color: iconColor.withOpacity(0.3), width: 1)
                            : BorderSide.none),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    color: item.isRead ? Colors.grey.shade50 : cardColor,
                    child: InkWell(
                      onTap: () async {
                        _markItemAsRead(item);
                        if (item.type == InboxItemType.urgent) {
                          final record = item.originalData as OLAViolateRecord;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UrgentRecordScreen(user: {}),
                            ),
                          );
                          _loadInbox(); // Reload on return
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Icon(icon, color: iconColor, size: 24),
                                    if (!item.isRead)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: item.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold),
                                  ),
                                ),
                                if (item.type == InboxItemType.issue)
                                  if (_resolutions[
                                          (item.originalData as PEIssue).id ??
                                              0] !=
                                      null)
                                    IconButton(
                                      icon: const Icon(Icons.info,
                                          color: Colors.blue),
                                      onPressed: () => _showResolutionDetails(
                                          item.originalData as PEIssue),
                                    ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: item.isRead
                                      ? Colors.black54
                                      : Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.date?.toString().split('.').first ??
                                      'N/A',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                if (!item.isRead)
                                  Text(
                                    'NEW',
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildSummaryCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: color.withOpacity(0.05),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNoticeItem(Notice notice) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.orange, size: 20),
        title: Text(
          notice.description ?? 'No description',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        subtitle: Text(
          'By: ${notice.createdUserName ?? 'System'} on ${notice.createdDate?.toString().split(' ').first ?? 'N/A'}',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../model/Escalation.dart';
// import '../service/EscalationService.dart';
// import 'package:intl/intl.dart';

// class EscalationScreen extends StatefulWidget {
//   final String accessToken;
//   const EscalationScreen({super.key, required this.accessToken});

//   @override
//   State<EscalationScreen> createState() => _EscalationScreenState();
// }

// class _EscalationScreenState extends State<EscalationScreen>
//     with SingleTickerProviderStateMixin {
//   late EscalationService _escalationService;
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();

//   List<Escalation> _allEscalations = [];
//   List<Escalation> _filteredEscalations = [];
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _escalationService = EscalationService(accessToken: widget.accessToken);
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(() {
//       setState(() {});
//     });
//     _fetchEscalations();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchEscalations() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final escalations = await _escalationService.getAllEscalations();
//       setState(() {
//         _allEscalations = escalations;
//         _applyFilter();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   void _applyFilter() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredEscalations = _allEscalations.where((e) {
//         final matchesSearch =
//             (e.title?.toLowerCase().contains(query) ?? false) ||
//                 (e.message?.toLowerCase().contains(query) ?? false);

//         if (!matchesSearch) return false;

//         if (_tabController.index == 0) {
//           return e.isRead == false;
//         } else if (_tabController.index == 1) {
//           return e.isRead == true;
//         }
//         return true;
//       }).toList();
//     });
//   }

//   int get _unreadCount =>
//       _allEscalations.where((e) => e.isRead == false).length;
//   int get _readCount => _allEscalations.where((e) => e.isRead == true).length;
//   int get _totalCount => _allEscalations.length;

//   Future<void> _markAllAsRead() async {
//     try {
//       await _escalationService.markAllAsRead();
//       _fetchEscalations();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('All escalations marked as read')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   Future<void> _startAutoEscalation() async {
//     try {
//       await _escalationService.startAutoEscalation();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Auto escalation started')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F4F8),
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Escalations',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF102559), Color(0xFF080B42)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildMainCard(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header Section
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Color(0xFF1565C0),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.warning_amber_rounded,
//                     color: Colors.white, size: 28),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'OLA Escalations',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 OutlinedButton.icon(
//                   onPressed: _startAutoEscalation,
//                   icon: const Icon(Icons.play_circle_outline,
//                       color: Colors.white, size: 18),
//                   label: const Text('Start Auto Escalation',
//                       style: TextStyle(color: Colors.white, fontSize: 12)),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.white70),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 OutlinedButton.icon(
//                   onPressed: _fetchEscalations,
//                   icon:
//                       const Icon(Icons.refresh, color: Colors.white, size: 18),
//                   label: const Text('Refresh',
//                       style: TextStyle(color: Colors.white, fontSize: 12)),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.white70),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Search and Mark All as Read
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Row(
//                           children: [
//                             const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 12.0),
//                               child: Icon(Icons.search, color: Colors.grey),
//                             ),
//                             Expanded(
//                               child: TextField(
//                                 controller: _searchController,
//                                 decoration: const InputDecoration(
//                                   hintText: 'Type to search escalations...',
//                                   border: InputBorder.none,
//                                   isDense: true,
//                                 ),
//                                 onChanged: (value) => _applyFilter(),
//                               ),
//                             ),
//                             if (_searchController.text.isNotEmpty)
//                               IconButton(
//                                 icon: const Icon(Icons.cancel,
//                                     color: Colors.grey, size: 20),
//                                 onPressed: () {
//                                   _searchController.clear();
//                                   _applyFilter();
//                                 },
//                               ),
//                             Container(
//                               height: 40,
//                               width: 1,
//                               color: Colors.grey.shade300,
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 _searchController.clear();
//                                 _applyFilter();
//                               },
//                               child: const Text('Clear',
//                                   style: TextStyle(color: Colors.grey)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton.icon(
//                       onPressed: _markAllAsRead,
//                       icon: const Icon(Icons.done_all, size: 18),
//                       label: const Text('Mark All as Read'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF00CCFF),
//                         foregroundColor: Colors.black87,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 14),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 24),

//                 // Tabs
//                 Container(
//                   decoration: BoxDecoration(
//                     border:
//                         Border(bottom: BorderSide(color: Colors.grey.shade200)),
//                   ),
//                   child: TabBar(
//                     controller: _tabController,
//                     isScrollable: true,
//                     indicatorColor: Colors.blue,
//                     indicatorWeight: 3,
//                     labelColor: Colors.blue,
//                     unselectedLabelColor: Colors.grey,
//                     onTap: (index) => _applyFilter(),
//                     tabs: [
//                       Tab(
//                           child: _buildTabLabel(
//                               'Unread', _unreadCount, Colors.red.shade600)),
//                       Tab(
//                           child:
//                               _buildTabLabel('Read', _readCount, Colors.cyan)),
//                       Tab(
//                           child: _buildTabLabel(
//                               'All', _totalCount, Colors.grey.shade800)),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // List Content
//                 _isLoading
//                     ? const Center(
//                         child: Padding(
//                             padding: EdgeInsets.all(32.0),
//                             child: CircularProgressIndicator()))
//                     : _filteredEscalations.isEmpty
//                         ? _buildEmptyState()
//                         : _buildEscalationList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabLabel(String label, int count, Color badgeColor) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(label,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: badgeColor,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             count.toString(),
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     String message = 'No escalations found.';
//     if (_tabController.index == 0) message = 'No unread escalations.';
//     if (_tabController.index == 1) message = 'No read escalations.';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE1F5FE),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.lightBlue.shade100),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.info_outline, color: Colors.lightBlue),
//           const SizedBox(width: 12),
//           Text(message,
//               style: TextStyle(
//                   color: Colors.lightBlue.shade900,
//                   fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }

//   Widget _buildEscalationList() {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _filteredEscalations.length,
//       separatorBuilder: (context, index) => const Divider(),
//       itemBuilder: (context, index) {
//         final escalation = _filteredEscalations[index];
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundColor: _getLevelColor(escalation.level),
//             child: Text(
//               escalation.level?.toString() ?? '!',
//               style: const TextStyle(
//                   color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//           ),
//           title: Text(
//             escalation.title ?? 'No Title',
//             style: TextStyle(
//               fontWeight: escalation.isRead == false
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(escalation.message ?? ''),
//               const SizedBox(height: 4),
//               Text(
//                 escalation.createdAt != null
//                     ? DateFormat('yyyy-MM-dd HH:mm')
//                         .format(escalation.createdAt!)
//                     : '',
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//           trailing: escalation.isRead == false
//               ? const Icon(Icons.circle, color: Colors.blue, size: 12)
//               : null,
//           onTap: () {
//             // Show details or mark as read
//           },
//         );
//       },
//     );
//   }

//   Color _getLevelColor(int? level) {
//     if (level == 1) return Colors.orange;
//     if (level == 2) return Colors.deepOrange;
//     if (level == 3) return Colors.red;
//     return Colors.blue;
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/Escalation.dart';
import '../service/EscalationService.dart';
import 'package:intl/intl.dart';

class EscalationScreen extends StatefulWidget {
  final String accessToken;
  const EscalationScreen({super.key, required this.accessToken});

  @override
  State<EscalationScreen> createState() => _EscalationScreenState();
}

class _EscalationScreenState extends State<EscalationScreen>
    with SingleTickerProviderStateMixin {
  late EscalationService _escalationService;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Escalation> _allEscalations = [];
  List<Escalation> _filteredEscalations = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _escalationService = EscalationService(accessToken: widget.accessToken);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchEscalations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEscalations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final escalations = await _escalationService.getAllEscalations();
      setState(() {
        _allEscalations = escalations;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEscalations = _allEscalations.where((e) {
        final matchesSearch =
            (e.title?.toLowerCase().contains(query) ?? false) ||
                (e.message?.toLowerCase().contains(query) ?? false);

        if (!matchesSearch) return false;

        if (_tabController.index == 0) {
          return e.isRead == false;
        } else if (_tabController.index == 1) {
          return e.isRead == true;
        }
        return true;
      }).toList();
    });
  }

  int get _unreadCount =>
      _allEscalations.where((e) => e.isRead == false).length;
  int get _readCount => _allEscalations.where((e) => e.isRead == true).length;
  int get _totalCount => _allEscalations.length;

  Future<void> _markAllAsRead() async {
    try {
      await _escalationService.markAllAsRead();
      _fetchEscalations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All escalations marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _startAutoEscalation() async {
    try {
      await _escalationService.startAutoEscalation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auto escalation started')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Escalations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF102559), Color(0xFF080B42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMainCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isNarrow = constraints.maxWidth < 450;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'OLA Escalations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isNarrow) ...[
                          _buildHeaderButtons(),
                        ],
                      ],
                    ),
                    if (isNarrow) ...[
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildHeaderButtons(),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Mark All as Read
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isNarrow = constraints.maxWidth < 500;
                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 12),
                          _buildMarkAllButton(),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                        const SizedBox(width: 16),
                        _buildMarkAllButton(),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    onTap: (index) => _applyFilter(),
                    tabs: [
                      Tab(
                          child: _buildTabLabel(
                              'Unread', _unreadCount, Colors.red.shade600)),
                      Tab(
                          child:
                              _buildTabLabel('Read', _readCount, Colors.cyan)),
                      Tab(
                          child: _buildTabLabel(
                              'All', _totalCount, Colors.grey.shade800)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // List Content
                _isLoading
                    ? const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator()))
                    : _filteredEscalations.isEmpty
                        ? _buildEmptyState()
                        : _buildEscalationList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLabel(String label, int count, Color badgeColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message = 'No escalations found.';
    if (_tabController.index == 0) message = 'No unread escalations.';
    if (_tabController.index == 1) message = 'No read escalations.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5FE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightBlue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.lightBlue),
          const SizedBox(width: 12),
          Text(message,
              style: TextStyle(
                  color: Colors.lightBlue.shade900,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEscalationList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredEscalations.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final escalation = _filteredEscalations[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getLevelColor(escalation.level),
            child: Text(
              escalation.level?.toString() ?? '!',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            escalation.title ?? 'No Title',
            style: TextStyle(
              fontWeight: escalation.isRead == false
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(escalation.message ?? ''),
              const SizedBox(height: 4),
              Text(
                escalation.createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm')
                        .format(escalation.createdAt!)
                    : '',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          trailing: escalation.isRead == false
              ? const Icon(Icons.circle, color: Colors.blue, size: 12)
              : null,
          onTap: () {
            // Show details or mark as read
          },
        );
      },
    );
  }

  Color _getLevelColor(int? level) {
    if (level == 1) return Colors.orange;
    if (level == 2) return Colors.deepOrange;
    if (level == 3) return Colors.red;
    return Colors.blue;
  }

  Widget _buildHeaderButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: _startAutoEscalation,
          icon: const Icon(Icons.play_circle_outline,
              color: Colors.white, size: 16),
          label: const Text('Start Auto',
              style: TextStyle(color: Colors.white, fontSize: 11)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white70),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _fetchEscalations,
          icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
          label: const Text('Refresh',
              style: TextStyle(color: Colors.white, fontSize: 11)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white70),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.search, color: Colors.grey, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search escalations...',
                hintStyle: TextStyle(fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => _applyFilter(),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
              onPressed: () {
                _searchController.clear();
                _applyFilter();
              },
            ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _applyFilter();
            },
            child: const Text('Clear',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAllButton() {
    return ElevatedButton.icon(
      onPressed: _markAllAsRead,
      icon: const Icon(Icons.done_all, size: 18),
      label: const Text('Mark All as Read', style: TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00CCFF),
        foregroundColor: Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

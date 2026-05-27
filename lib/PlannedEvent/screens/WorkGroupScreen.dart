

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import '../model/WorkGroupModel.dart';
// import '../service/WorkGroupService.dart';

// import 'DashboardHome.dart'; // Adjust this import based on your actual DashboardHome location

// class WorkGroupScreen extends StatefulWidget {
//   final int userId;
//   const WorkGroupScreen({super.key, required this.userId});

//   @override
//   _WorkGroupScreenState createState() => _WorkGroupScreenState();
// }

// class _WorkGroupScreenState extends State<WorkGroupScreen> {
//   final WorkGroupService _service = WorkGroupService();
//   late Future<List<WorkGroupDetails>> _workGroupsFuture;
//   List<WorkGroupDetails> _workGroups = [];
//   List<WorkGroupDetails> _filteredWorkGroups = [];
//   String? _errorMessage;
//   final int _recordsPerPage = 10;
//   late PageController _pageController;
//   int _currentPage = 0;
//   bool _isSearchBarExpanded = false; 
//   bool _showCreateForm = false;
//   final TextEditingController _createController = TextEditingController();
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _workGroupsFuture = _service.fetchWorkGroups().catchError((e) {
//       print('Error in initState: $e');
//       setState(() {
//         _errorMessage = 'Failed to load work groups: $e';
//       });
//       return <WorkGroupDetails>[];
//     });
//     _workGroupsFuture.then((data) {
//       setState(() {
//         _workGroups = data;
//         _filteredWorkGroups = data;
//         _errorMessage = null;
//       });
//     }).catchError((e) {
//       setState(() {
//         _errorMessage = 'Failed to process work groups: $e';
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _createController.dispose();
//     super.dispose();
//   }

//   void _refreshData() {
//     setState(() {
//       _workGroupsFuture = _service.fetchWorkGroups();
//     });
//     _workGroupsFuture.then((data) {
//       setState(() {
//         _workGroups = data;
//         _filteredWorkGroups = data;
//         _errorMessage = null;
//       });
//     }).catchError((e) {
//       setState(() {
//         _errorMessage = 'Failed to process work groups: $e';
//       });
//     });
//   }

//   Future<void> _handleCreate() async {
//     final name = _createController.text.trim();
//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a work group name.')),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       final result = await _service.createWorkGroup(name);
//       if (result['success']) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Work group created successfully!')),
//         );
//         _createController.clear();
//         setState(() => _showCreateForm = false);
//         _refreshData();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to create: ${result['message']}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   void _filterWorkGroups(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredWorkGroups = _workGroups;
//       } else {
//         _filteredWorkGroups = _workGroups.where((workGroup) {
//           final name = workGroup.name?.toLowerCase() ?? '';
//           final id = workGroup.id?.toString() ?? '';
//           return name.contains(query.toLowerCase()) || id.contains(query);
//         }).toList();
//       }
//       _currentPage = 0;
//       _pageController.jumpToPage(0);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final int totalPages =
//         (_filteredWorkGroups.length / _recordsPerPage).ceil();

//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: _isSearchBarExpanded
//                         ? MainAxisAlignment.start
//                         : MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Search Icon and Expandable Search Bar
//                       _isSearchBarExpanded
//                           ? Expanded(
//                               child: TextField(
//                                 onChanged: _filterWorkGroups,
//                                 style: GoogleFonts.poppins(fontSize: 14),
//                                 decoration: InputDecoration(
//                                   hintText: 'Search...',
//                                   hintStyle: GoogleFonts.poppins(
//                                       color: Colors.grey.shade600,
//                                       fontSize: 14),
//                                   prefixIcon: Icon(Icons.search,
//                                       color: Colors.blue.shade700, size: 20),
//                                   filled: true,
//                                   fillColor: Colors.grey.shade100,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 10, horizontal: 12),
//                                   suffixIcon: IconButton(
//                                     icon: Icon(Icons.close,
//                                         color: Colors.blue.shade700, size: 20),
//                                     onPressed: () {
//                                       setState(() {
//                                         _isSearchBarExpanded = false;
//                                         _filterWorkGroups(''); // Clear search
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : IconButton(
//                               icon: Icon(Icons.search,
//                                   color: Colors.blue.shade700, size: 28),
//                               tooltip: 'Search Work Groups',
//                               onPressed: () {
//                                 setState(() {
//                                   _isSearchBarExpanded = true;
//                                 });
//                               },
//                             ),
//                       if (!_isSearchBarExpanded) ...[
//                         const SizedBox(width: 8),
//                         // Total Records
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 8),
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [
//                                 Color.fromARGB(225, 82, 126, 238),
//                                 Color.fromARGB(255, 7, 0, 99),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Text(
//                             'Count: ${_filteredWorkGroups.length}',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 if (!_isSearchBarExpanded) ...[
//                   const SizedBox(width: 8),
//                   // Create New Button
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       setState(() {
//                         _showCreateForm = !_showCreateForm;
//                       });
//                     },
//                     icon: Icon(
//                         _showCreateForm
//                             ? Icons.list_alt
//                             : Icons.add_circle_outline,
//                         size: 18),
//                     label: Text(_showCreateForm ? 'View List' : 'Create New'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue.shade800,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 10),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           if (_showCreateForm) _buildCreateForm(),
//           Expanded(
//             child: _showCreateForm
//                 ? const SizedBox.shrink()
//                 : FutureBuilder<List<WorkGroupDetails>>(
//               future: _workGroupsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return ListView.builder(
//                     itemCount: 5,
//                     itemBuilder: (context, index) => Shimmer.fromColors(
//                       baseColor: Colors.grey.shade300,
//                       highlightColor: Colors.grey.shade100,
//                       child: Card(
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 8, horizontal: 8),
//                         child: Container(
//                           height: 120,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   );
//                 } else if (_errorMessage != null) {
//                   return Center(
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 8.0, vertical: 4.0),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               _errorMessage!,
//                               style: GoogleFonts.poppins(
//                                   fontSize: 16, color: Colors.black87),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                     const Color.fromARGB(255, 4, 24, 96),
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8)),
//                               ),
//                               onPressed: () {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           DashboardHome(userId: widget.userId)),
//                                 );
//                               },
//                               child: Text(
//                                 'Back to Dashboard',
//                                 style: GoogleFonts.poppins(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 8.0, vertical: 4.0),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'No work groups found',
//                               style: GoogleFonts.poppins(
//                                   fontSize: 16, color: Colors.black87),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                     const Color.fromARGB(255, 4, 24, 96),
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8)),
//                               ),
//                               onPressed: () {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           DashboardHome(userId: widget.userId)),
//                                 );
//                               },
//                               child: Text(
//                                 'Back to Dashboard',
//                                 style: GoogleFonts.poppins(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 return Column(
//                   children: [
//                     Expanded(
//                       child: PageView.builder(
//                         controller: _pageController,
//                         onPageChanged: (int page) {
//                           setState(() {
//                             _currentPage = page;
//                           });
//                         },
//                         itemCount: totalPages,
//                         itemBuilder: (context, pageIndex) {
//                           final startIndex = pageIndex * _recordsPerPage;
//                           final endIndex = (startIndex + _recordsPerPage)
//                               .clamp(0, _filteredWorkGroups.length);
//                           final pageRecords =
//                               _filteredWorkGroups.sublist(startIndex, endIndex);

//                           return ListView.builder(
//                             itemCount: pageRecords.length,
//                             itemBuilder: (context, index) {
//                               final workGroup = pageRecords[index];
//                               return InkWell(
//                                 child: Card(
//                                   key: ValueKey(workGroup.id),
//                                   elevation: 4,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12)),
//                                   margin: const EdgeInsets.symmetric(
//                                       vertical: 8, horizontal: 8),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             const SizedBox(width: 8),
//                                             Expanded(
//                                               child: Text(
//                                                 '${workGroup.name}',
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         _buildFieldRow(
//                                             'ID', workGroup.id.toString()),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     if (totalPages > 1)
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(totalPages, (index) {
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 4.0),
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: _currentPage == index
//                                         ? const Color.fromARGB(255, 4, 24, 96)
//                                         : Colors.grey.shade300,
//                                     foregroundColor: _currentPage == index
//                                         ? Colors.white
//                                         : Colors.black,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8)),
//                                     minimumSize: const Size(40, 40),
//                                   ),
//                                   onPressed: () {
//                                     _pageController.animateToPage(
//                                       index,
//                                       duration:
//                                           const Duration(milliseconds: 300),
//                                       curve: Curves.easeInOut,
//                                     );
//                                   },
//                                   child: Text(
//                                     '${index + 1}',
//                                     style: GoogleFonts.poppins(),
//                                   ),
//                                 ),
//                               );
//                             }),
//                           ),
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFieldRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               textAlign: TextAlign.start,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: value == 'N/A' ? Colors.grey : Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCreateForm() {
//     return Container(
//       margin: const EdgeInsets.all(12),
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Color(0xFF1E5CCB), // Matching blue from image
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.group_add, color: Colors.white, size: 22),
//                 const SizedBox(width: 10),
//                 Text(
//                   'Create New Work Group',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Body
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Group Name',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: TextField(
//                     controller: _createController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter work group name',
//                       hintStyle: GoogleFonts.poppins(
//                           color: Colors.grey.shade400, fontSize: 14),
//                       prefixIcon: Icon(Icons.people_outline,
//                           color: Colors.grey.shade400),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 14, horizontal: 16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Buttons
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _isSubmitting ? null : _handleCreate,
//                       icon: _isSubmitting
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   strokeWidth: 2, color: Colors.white),
//                             )
//                           : const Icon(Icons.add_circle, size: 20),
//                       label: const Text('Create'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFF10408B), // Darker blue
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                         elevation: 4,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     TextButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           _showCreateForm = false;
//                         });
//                       },
//                       icon: const Icon(Icons.arrow_back, size: 20),
//                       label: const Text('Back to List'),
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.black87,
//                         backgroundColor: Colors.grey.shade100,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../model/WorkGroupModel.dart';
import '../service/WorkGroupService.dart';

import 'DashboardHome.dart'; // Adjust this import based on your actual DashboardHome location

class WorkGroupScreen extends StatefulWidget {
  final int userId;
  const WorkGroupScreen({super.key, required this.userId});

  @override
  _WorkGroupScreenState createState() => _WorkGroupScreenState();
}

class _WorkGroupScreenState extends State<WorkGroupScreen> {
  final WorkGroupService _service = WorkGroupService();
  late Future<List<WorkGroupDetails>> _workGroupsFuture;
  List<WorkGroupDetails> _workGroups = [];
  List<WorkGroupDetails> _filteredWorkGroups = [];
  String? _errorMessage;
  final int _recordsPerPage = 10;
  late PageController _pageController;
  int _currentPage = 0;
  bool _isSearchBarExpanded = false; 
  bool _showCreateForm = false;
  final TextEditingController _createController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _workGroupsFuture = _service.fetchWorkGroups().catchError((e) {
      print('Error in initState: $e');
      setState(() {
        _errorMessage = 'Failed to load work groups: $e';
      });
      return <WorkGroupDetails>[];
    });
    _workGroupsFuture.then((data) {
      setState(() {
        _workGroups = data;
        _filteredWorkGroups = data;
        _errorMessage = null;
      });
    }).catchError((e) {
      setState(() {
        _errorMessage = 'Failed to process work groups: $e';
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _createController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _workGroupsFuture = _service.fetchWorkGroups();
    });
    _workGroupsFuture.then((data) {
      setState(() {
        _workGroups = data;
        _filteredWorkGroups = data;
        _errorMessage = null;
      });
    }).catchError((e) {
      setState(() {
        _errorMessage = 'Failed to process work groups: $e';
      });
    });
  }

  Future<void> _handleCreate() async {
    final name = _createController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a work group name.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _service.createWorkGroup(name);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work group created successfully!')),
        );
        _createController.clear();
        setState(() => _showCreateForm = false);
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showEditDialog(WorkGroupDetails wg) async {
    final TextEditingController editController =
        TextEditingController(text: wg.name);
    bool isSaving = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Work Group',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: InputDecoration(
                  labelText: 'Work Group Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final newName = editController.text.trim();
                      if (newName.isEmpty) return;
                      setDialogState(() => isSaving = true);
                      final res =
                          await _service.updateWorkGroup(wg.id!, newName);
                      if (res['success']) {
                        Navigator.pop(context);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Updated successfully')));
                      } else {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error: ${res['message']}')));
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white),
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(WorkGroupDetails wg) async {
    bool isDeleting = false;
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${wg.name}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      final res = await _service.deleteWorkGroup(wg.id!);
                      if (res['success']) {
                        Navigator.pop(context);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deleted successfully')));
                      } else {
                        setDialogState(() => isDeleting = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error: ${res['message']}')));
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _filterWorkGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWorkGroups = _workGroups;
      } else {
        _filteredWorkGroups = _workGroups.where((workGroup) {
          final name = workGroup.name?.toLowerCase() ?? '';
          final id = workGroup.id?.toString() ?? '';
          return name.contains(query.toLowerCase()) || id.contains(query);
        }).toList();
      }
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages =
        (_filteredWorkGroups.length / _recordsPerPage).ceil();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: _isSearchBarExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      // Search Icon and Expandable Search Bar
                      _isSearchBarExpanded
                          ? Expanded(
                              child: TextField(
                                onChanged: _filterWorkGroups,
                                style: GoogleFonts.poppins(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 14),
                                  prefixIcon: Icon(Icons.search,
                                      color: Colors.blue.shade700, size: 20),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.close,
                                        color: Colors.blue.shade700, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _isSearchBarExpanded = false;
                                        _filterWorkGroups(''); // Clear search
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.search,
                                  color: Colors.blue.shade700, size: 28),
                              tooltip: 'Search Work Groups',
                              onPressed: () {
                                setState(() {
                                  _isSearchBarExpanded = true;
                                });
                              },
                            ),
                      if (!_isSearchBarExpanded) ...[
                        const SizedBox(width: 8),
                        // Total Records
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Count: ${_filteredWorkGroups.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!_isSearchBarExpanded) ...[
                  const SizedBox(width: 8),
                  // Create New Button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showCreateForm = !_showCreateForm;
                      });
                    },
                    icon: Icon(
                        _showCreateForm
                            ? Icons.list_alt
                            : Icons.add_circle_outline,
                        size: 18),
                    label: Text(_showCreateForm ? 'View List' : 'Create New'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_showCreateForm) _buildCreateForm(),
          Expanded(
            child: _showCreateForm
                ? const SizedBox.shrink()
                : FutureBuilder<List<WorkGroupDetails>>(
              future: _workGroupsFuture,
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
                              'No work groups found',
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
                              .clamp(0, _filteredWorkGroups.length);
                          final pageRecords =
                              _filteredWorkGroups.sublist(startIndex, endIndex);

                          return ListView.builder(
                            itemCount: pageRecords.length,
                            itemBuilder: (context, index) {
                              final workGroup = pageRecords[index];
                              return InkWell(
                                  child: Card(
                                    key: ValueKey(workGroup.id),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${workGroup.name}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              // Actions
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.blue,
                                                        size: 20),
                                                    onPressed: () =>
                                                        _showEditDialog(workGroup),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                        size: 20),
                                                    onPressed: () =>
                                                        _confirmDelete(workGroup),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          _buildFieldRow(
                                              'ID', workGroup.id.toString()),
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

  Widget _buildCreateForm() {
    return Container(
      margin: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E5CCB), // Matching blue from image
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.group_add, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Create New Work Group',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Name',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _createController,
                    decoration: InputDecoration(
                      hintText: 'Enter work group name',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.people_outline,
                          color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleCreate,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add_circle, size: 20),
                      label: const Text('Create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF10408B), // Darker blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showCreateForm = false;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: const Text('Back to List'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

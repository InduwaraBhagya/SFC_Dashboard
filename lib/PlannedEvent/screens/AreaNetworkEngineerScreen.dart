// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import '../model/AreaNetworkEngineer.dart';
// import '../service/AreaNetworkEngineerService.dart';
// import 'DashboardHome.dart'; // Adjust this import based on your actual DashboardHome location

// class AreaNetworkEngineerScreen extends StatefulWidget {
//   final int userId;
//   const AreaNetworkEngineerScreen({super.key, required this.userId});

//   @override
//   _AreaNetworkEngineerScreenState createState() =>
//       _AreaNetworkEngineerScreenState();
// }

// class _AreaNetworkEngineerScreenState extends State<AreaNetworkEngineerScreen> {
//   final AreaNetworkEngineerService _service = AreaNetworkEngineerService();
//   late Future<List<AreaNetworkEngineer>> _engineersFuture;
//   List<AreaNetworkEngineer> _engineers = [];
//   List<AreaNetworkEngineer> _filteredEngineers = [];
//   String? _errorMessage;
//   final int _recordsPerPage = 10;
//   late PageController _pageController;
//   int _currentPage = 0;
//   bool _isSearchBarExpanded = false; // Track search bar expansion state
//   final TextEditingController _areaController = TextEditingController();
//   String? _engineerName;
//   final bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _engineersFuture = _service.getAllEngineers().catchError((e) {
//       print('Error in initState: $e');
//       setState(() {
//         _errorMessage = 'Failed to load engineers: $e';
//       });
//       return <AreaNetworkEngineer>[];
//     });
//     _engineersFuture.then((data) {
//       setState(() {
//         _engineers = data;
//         _filteredEngineers = data;
//         _errorMessage = null;
//       });
//     }).catchError((e) {
//       setState(() {
//         _errorMessage = 'Failed to process engineers: $e';
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _areaController.dispose();
//     super.dispose();
//   }

//   void _filterEngineers(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredEngineers = _engineers;
//       } else {
//         _filteredEngineers = _engineers.where((engineer) {
//           final name = engineer.engineerName?.toLowerCase() ?? '';
//           final id = engineer.id.toString();
//           final area = engineer.area?.toLowerCase() ?? '';
//           return name.contains(query.toLowerCase()) ||
//               id.contains(query) ||
//               area.contains(query.toLowerCase());
//         }).toList();
//       }
//       _currentPage = 0;
//       _pageController.jumpToPage(0);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final int totalPages = (_filteredEngineers.length / _recordsPerPage).ceil();

//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: _isSearchBarExpanded
//                   ? MainAxisAlignment.start
//                   : MainAxisAlignment.spaceBetween,
//               children: [
//                 // Search Icon and Expandable Search Bar
//                 _isSearchBarExpanded
//                     ? Expanded(
//                         child: TextField(
//                           onChanged: _filterEngineers,
//                           style: GoogleFonts.poppins(fontSize: 16),
//                           decoration: InputDecoration(
//                             hintText: 'Search by Name, ID, or Area',
//                             hintStyle: GoogleFonts.poppins(
//                                 color: Colors.grey.shade600),
//                             prefixIcon:
//                                 Icon(Icons.search, color: Colors.blue.shade700),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 16, horizontal: 20),
//                             suffixIcon: IconButton(
//                               icon: Icon(Icons.close,
//                                   color: Colors.blue.shade700),
//                               onPressed: () {
//                                 setState(() {
//                                   _isSearchBarExpanded = false;
//                                   _filterEngineers(''); // Clear search
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       )
//                     : IconButton(
//                         icon: Icon(Icons.search,
//                             color: Colors.blue.shade700, size: 28),
//                         tooltip: 'Search Engineers',
//                         onPressed: () {
//                           setState(() {
//                             _isSearchBarExpanded = true;
//                           });
//                         },
//                       ),
//                 // Total Records
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: _isSearchBarExpanded ? 8 : 12,
//                     vertical: _isSearchBarExpanded ? 6 : 8,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color.fromARGB(225, 82, 126, 238),
//                         Color.fromARGB(255, 7, 0, 99),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       if (!_isSearchBarExpanded) ...[
//                         Icon(
//                           Icons.list,
//                           size: _isSearchBarExpanded ? 16 : 20,
//                           color: Colors.white,
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//                       Text(
//                         _isSearchBarExpanded
//                             ? '${_filteredEngineers.length}'
//                             : 'Total Records: ${_filteredEngineers.length}',
//                         style: GoogleFonts.poppins(
//                           fontSize: _isSearchBarExpanded ? 20 : 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isLoading) const Center(child: CircularProgressIndicator()),
//           if (_engineerName != null)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Text(
//                 'Engineer: $_engineerName',
//                 style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
//               ),
//             ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: FutureBuilder<List<AreaNetworkEngineer>>(
//               future: _engineersFuture,
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
//                               'No engineers found',
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
//                               .clamp(0, _filteredEngineers.length);
//                           final pageRecords =
//                               _filteredEngineers.sublist(startIndex, endIndex);

//                           return ListView.builder(
//                             itemCount: pageRecords.length,
//                             itemBuilder: (context, index) {
//                               final engineer = pageRecords[index];
//                               return Card(
//                                 key: ValueKey(engineer.id),
//                                 elevation: 4,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12)),
//                                 margin: const EdgeInsets.symmetric(
//                                     vertical: 8, horizontal: 8),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           const SizedBox(width: 8),
//                                           Expanded(
//                                             child: Text(
//                                               engineer.engineerName ??
//                                                   'Unknown',
//                                               style: GoogleFonts.poppins(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 8),
//                                       _buildFieldRow(
//                                           'ID', engineer.id.toString()),
//                                       _buildFieldRow(
//                                           'Area', engineer.area ?? 'N/A'),
//                                     ],
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
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import '../model/AreaNetworkEngineer.dart';
// import '../service/AreaNetworkEngineerService.dart';
// import 'DashboardHome.dart'; // Adjust this import based on your actual DashboardHome location

// class AreaNetworkEngineerScreen extends StatefulWidget {
//   final int userId;
//   const AreaNetworkEngineerScreen({super.key, required this.userId});

//   @override
//   _AreaNetworkEngineerScreenState createState() =>
//       _AreaNetworkEngineerScreenState();
// }

// class _AreaNetworkEngineerScreenState extends State<AreaNetworkEngineerScreen> {
//   final AreaNetworkEngineerService _service = AreaNetworkEngineerService();
//   late Future<List<AreaNetworkEngineer>> _engineersFuture;
//   List<AreaNetworkEngineer> _engineers = [];
//   List<AreaNetworkEngineer> _filteredEngineers = [];
//   String? _errorMessage;
//   final int _recordsPerPage = 10;
//   late PageController _pageController;
//   int _currentPage = 0;
//   bool _isAddingMapping = false;
//   final TextEditingController _areaCodeController = TextEditingController();
//   final TextEditingController _engineerNameFormController =
//       TextEditingController();
//   bool _isCreating = false;
//   bool _isSearchBarExpanded = false;
//   final TextEditingController _areaController = TextEditingController();
//   String? _engineerName;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _engineersFuture = _service.getAllEngineers().catchError((e) {
//       print('Error in initState: $e');
//       setState(() {
//         _errorMessage = 'Failed to load engineers: $e';
//       });
//       return <AreaNetworkEngineer>[];
//     });
//     _engineersFuture.then((data) {
//       setState(() {
//         _engineers = data;
//         _filteredEngineers = data;
//         _errorMessage = null;
//       });
//     }).catchError((e) {
//       setState(() {
//         _errorMessage = 'Failed to process engineers: $e';
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _areaController.dispose();
//     _areaCodeController.dispose();
//     _engineerNameFormController.dispose();
//     super.dispose();
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       _errorMessage = null;
//     });
//     try {
//       final data = await _service.getAllEngineers();
//       setState(() {
//         _engineers = data;
//         _filteredEngineers = data;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to refresh data: $e';
//       });
//     }
//   }

//   Future<void> _submitMapping() async {
//     if (_areaCodeController.text.isEmpty ||
//         _engineerNameFormController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all required fields')),
//       );
//       return;
//     }

//     setState(() => _isCreating = true);
//     final success = await _service.createMapping(
//       _areaCodeController.text,
//       _engineerNameFormController.text,
//     );

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Mapping created successfully')),
//       );
//       _areaCodeController.clear();
//       _engineerNameFormController.clear();
//       setState(() {
//         _isAddingMapping = false;
//         _isCreating = false;
//       });
//       await _refreshData();
//     } else {
//       setState(() => _isCreating = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to create mapping')),
//       );
//     }
//   }

//   void _filterEngineers(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredEngineers = _engineers;
//       } else {
//         _filteredEngineers = _engineers.where((engineer) {
//           final name = engineer.engineerName?.toLowerCase() ?? '';
//           final id = engineer.id.toString();
//           final area = engineer.area?.toLowerCase() ?? '';
//           return name.contains(query.toLowerCase()) ||
//               id.contains(query) ||
//               area.contains(query.toLowerCase());
//         }).toList();
//       }
//       _currentPage = 0;
//       _pageController.jumpToPage(0);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final int totalPages = (_filteredEngineers.length / _recordsPerPage).ceil();

//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               alignment: WrapAlignment.spaceBetween,
//               crossAxisAlignment: WrapCrossAlignment.center,
//               children: [
//                 if (!_isAddingMapping)
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       _areaCodeController.clear();
//                       _engineerNameFormController.clear();
//                       setState(() => _isAddingMapping = true);
//                     },
//                     icon: const Icon(Icons.add_circle_outline, size: 20),
//                     label: Text('Add New Mapping',
//                         style:
//                             GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1D4ED8),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Search Icon and Expandable Search Bar
//                     if (!_isAddingMapping)
//                       _isSearchBarExpanded
//                           ? SizedBox(
//                               width: 200,
//                               child: TextField(
//                                 onChanged: _filterEngineers,
//                                 style: GoogleFonts.poppins(fontSize: 14),
//                                 decoration: InputDecoration(
//                                   hintText: 'Search...',
//                                   prefixIcon:
//                                       const Icon(Icons.search, size: 18),
//                                   filled: true,
//                                   fillColor: Colors.grey.shade100,
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide.none),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       vertical: 0, horizontal: 12),
//                                   suffixIcon: IconButton(
//                                     icon: const Icon(Icons.close, size: 18),
//                                     onPressed: () => setState(() {
//                                       _isSearchBarExpanded = false;
//                                       _filterEngineers('');
//                                     }),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : IconButton(
//                               icon: Icon(Icons.search,
//                                   color: Colors.blue.shade700, size: 28),
//                               onPressed: () =>
//                                   setState(() => _isSearchBarExpanded = true),
//                             ),
//                     const SizedBox(width: 8),
//                     // Total Records
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2))
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.list, size: 18, color: Colors.white),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Total: ${_filteredEngineers.length}',
//                             style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           if (_isLoading) const Center(child: CircularProgressIndicator()),
//           if (_engineerName != null)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Text(
//                 'Engineer: $_engineerName',
//                 style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
//               ),
//             ),
//           const SizedBox(height: 8),
//           _isAddingMapping
//               ? _buildAddMappingForm()
//               : Expanded(
//                   child: FutureBuilder<List<AreaNetworkEngineer>>(
//                     future: _engineersFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return ListView.builder(
//                           itemCount: 5,
//                           itemBuilder: (context, index) => Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Card(
//                               margin: const EdgeInsets.symmetric(
//                                   vertical: 8, horizontal: 8),
//                               child: Container(
//                                 height: 120,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         );
//                       } else if (_errorMessage != null) {
//                         return Center(
//                           child: Card(
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 8.0, vertical: 4.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     _errorMessage!,
//                                     style: GoogleFonts.poppins(
//                                         fontSize: 16, color: Colors.black87),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor:
//                                           const Color.fromARGB(255, 4, 24, 96),
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8)),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) => DashboardHome(
//                                                 userId: widget.userId)),
//                                       );
//                                     },
//                                     child: Text(
//                                       'Back to Dashboard',
//                                       style: GoogleFonts.poppins(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                         return Center(
//                           child: Card(
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 8.0, vertical: 4.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     'No engineers found',
//                                     style: GoogleFonts.poppins(
//                                         fontSize: 16, color: Colors.black87),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor:
//                                           const Color.fromARGB(255, 4, 24, 96),
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8)),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) => DashboardHome(
//                                                 userId: widget.userId)),
//                                       );
//                                     },
//                                     child: Text(
//                                       'Back to Dashboard',
//                                       style: GoogleFonts.poppins(),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                       return Column(
//                         children: [
//                           Expanded(
//                             child: PageView.builder(
//                               controller: _pageController,
//                               onPageChanged: (int page) {
//                                 setState(() {
//                                   _currentPage = page;
//                                 });
//                               },
//                               itemCount: totalPages,
//                               itemBuilder: (context, pageIndex) {
//                                 final startIndex = pageIndex * _recordsPerPage;
//                                 final endIndex = (startIndex + _recordsPerPage)
//                                     .clamp(0, _filteredEngineers.length);
//                                 final pageRecords = _filteredEngineers.sublist(
//                                     startIndex, endIndex);

//                                 return ListView.builder(
//                                   itemCount: pageRecords.length,
//                                   itemBuilder: (context, index) {
//                                     final engineer = pageRecords[index];
//                                     return Card(
//                                       key: ValueKey(engineer.id),
//                                       elevation: 4,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12)),
//                                       margin: const EdgeInsets.symmetric(
//                                           vertical: 8, horizontal: 8),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(16),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 const SizedBox(width: 8),
//                                                 Expanded(
//                                                   child: Text(
//                                                     engineer.engineerName ??
//                                                         'Unknown',
//                                                     style: GoogleFonts.poppins(
//                                                       fontSize: 16,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.black87,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 8),
//                                             _buildFieldRow(
//                                                 'ID', engineer.id.toString()),
//                                             _buildFieldRow(
//                                                 'Area', engineer.area ?? 'N/A'),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                           ),
//                           if (totalPages > 1)
//                             Container(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: List.generate(totalPages, (index) {
//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4.0),
//                                       child: ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: _currentPage == index
//                                               ? const Color.fromARGB(
//                                                   255, 4, 24, 96)
//                                               : Colors.grey.shade300,
//                                           foregroundColor: _currentPage == index
//                                               ? Colors.white
//                                               : Colors.black,
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8)),
//                                           minimumSize: const Size(40, 40),
//                                         ),
//                                         onPressed: () {
//                                           _pageController.animateToPage(
//                                             index,
//                                             duration: const Duration(
//                                                 milliseconds: 300),
//                                             curve: Curves.easeInOut,
//                                           );
//                                         },
//                                         child: Text(
//                                           '${index + 1}',
//                                           style: GoogleFonts.poppins(),
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
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

//   Widget _buildAddMappingForm() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Form Header
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF2E7D32), // Green from image
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(10),
//                     topRight: Radius.circular(10),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.add_circle, color: Colors.white, size: 24),
//                     const SizedBox(width: 10),
//                     Text(
//                       'Add Network Engineer Mapping',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Area Code/Name',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                         color: const Color(0xFF334155),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _areaCodeController,
//                       decoration: InputDecoration(
//                         hintText:
//                             'Enter area code or name (e.g., NORTH, SOUTH, CENTRAL)',
//                         hintStyle: GoogleFonts.poppins(
//                             color: Colors.grey.shade400, fontSize: 14),
//                         filled: true,
//                         fillColor: Colors.grey.shade50,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 16),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Enter the geographical area or zone identifier.',
//                       style: GoogleFonts.poppins(
//                           fontSize: 12, color: Colors.grey.shade500),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'Engineer Name',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                         color: const Color(0xFF334155),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _engineerNameFormController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter engineer\'s full name',
//                         hintStyle: GoogleFonts.poppins(
//                             color: Colors.grey.shade400, fontSize: 14),
//                         filled: true,
//                         fillColor: Colors.grey.shade50,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 16),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Enter the full name of the network engineer responsible for this area.',
//                       style: GoogleFonts.poppins(
//                           fontSize: 12, color: Colors.grey.shade500),
//                     ),
//                     const SizedBox(height: 32),
//                     Row(
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: _isCreating ? null : _submitMapping,
//                           icon: _isCreating
//                               ? const SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                       strokeWidth: 2, color: Colors.white))
//                               : const Icon(Icons.check_circle_outline,
//                                   size: 18),
//                           label: Text(
//                             'Create Mapping',
//                             style: GoogleFonts.poppins(
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 const Color(0xFF108E5F), // Green from image
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 16),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         TextButton.icon(
//                           onPressed: () =>
//                               setState(() => _isAddingMapping = false),
//                           icon: const Icon(Icons.arrow_back, size: 18),
//                           label: Text(
//                             'Cancel',
//                             style: GoogleFonts.poppins(
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           style: TextButton.styleFrom(
//                             backgroundColor:
//                                 const Color(0xFF64748B), // Grey from image
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 16),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                         const Spacer(),
//                         Row(
//                           children: [
//                             Icon(Icons.info_outline,
//                                 size: 16, color: Colors.grey.shade600),
//                             const SizedBox(width: 4),
//                             Text(
//                               'All fields are required',
//                               style: GoogleFonts.poppins(
//                                   fontSize: 12, color: Colors.grey.shade600),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
  bool _isAddingMapping = false;
  final TextEditingController _areaCodeController = TextEditingController();
  final TextEditingController _engineerNameFormController =
      TextEditingController();
  bool _isCreating = false;
  bool _isSearchBarExpanded = false;
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
    _areaCodeController.dispose();
    _engineerNameFormController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      final data = await _service.getAllEngineers();
      setState(() {
        _engineers = data;
        _filteredEngineers = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to refresh data: $e';
      });
    }
  }

  Future<void> _submitMapping() async {
    if (_areaCodeController.text.isEmpty ||
        _engineerNameFormController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isCreating = true);
    final success = await _service.createMapping(
      _areaCodeController.text,
      _engineerNameFormController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mapping created successfully')),
      );
      _areaCodeController.clear();
      _engineerNameFormController.clear();
      setState(() {
        _isAddingMapping = false;
        _isCreating = false;
      });
      await _refreshData();
    } else {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create mapping')),
      );
    }
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
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Side: Search (if not adding mapping)
                if (!_isAddingMapping)
                  _isSearchBarExpanded
                      ? SizedBox(
                          width: 250,
                          child: TextField(
                            onChanged: _filterEngineers,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search engineers...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 12),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => setState(() {
                                  _isSearchBarExpanded = false;
                                  _filterEngineers('');
                                }),
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.search,
                              color: Colors.blue.shade700, size: 28),
                          onPressed: () =>
                              setState(() => _isSearchBarExpanded = true),
                        )
                else
                  const SizedBox(), // Spacer if adding mapping

                // Right Side: Total Records and Add Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Total Records
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.list, size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Total: ${_filteredEngineers.length}',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_isAddingMapping)
                      ElevatedButton.icon(
                        onPressed: () {
                          _areaCodeController.clear();
                          _engineerNameFormController.clear();
                          setState(() => _isAddingMapping = true);
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: Text('Add New Mapping',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                  ],
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
            child: _isAddingMapping
                ? _buildAddMappingForm()
                : FutureBuilder<List<AreaNetworkEngineer>>(
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
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DashboardHome(
                                                userId: widget.userId)),
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
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DashboardHome(
                                                userId: widget.userId)),
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
                                final pageRecords = _filteredEngineers.sublist(
                                    startIndex, endIndex);

                                return ListView.builder(
                                  itemCount: pageRecords.length,
                                  itemBuilder: (context, index) {
                                    final engineer = pageRecords[index];
                                    return Card(
                                      key: ValueKey(engineer.id),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(totalPages, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _currentPage == index
                                              ? const Color.fromARGB(
                                                  255, 4, 24, 96)
                                              : Colors.grey.shade300,
                                          foregroundColor: _currentPage == index
                                              ? Colors.white
                                              : Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          minimumSize: const Size(40, 40),
                                        ),
                                        onPressed: () {
                                          _pageController.animateToPage(
                                            index,
                                            duration: const Duration(
                                                milliseconds: 300),
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

  Widget _buildAddMappingForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32), // Green from image
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Add Network Engineer Mapping',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Area Code/Name',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _areaCodeController,
                      decoration: InputDecoration(
                        hintText:
                            'Enter area code or name (e.g., NORTH, SOUTH, CENTRAL)',
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter the geographical area or zone identifier.',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Engineer Name',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _engineerNameFormController,
                      decoration: InputDecoration(
                        hintText: 'Enter engineer\'s full name',
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter the full name of the network engineer responsible for this area.',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isCreating ? null : _submitMapping,
                          icon: _isCreating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline,
                                  size: 18),
                          label: Text(
                            'Create Mapping',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF108E5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _isAddingMapping = false),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF64748B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'All fields are required',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

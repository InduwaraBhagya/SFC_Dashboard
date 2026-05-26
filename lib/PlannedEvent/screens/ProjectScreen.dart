// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import '../model/Project.dart';
// import '../model/ProjectUserPermissionsDto.dart';
// import '../service/ProjectService.dart';
// import 'ProjectDetailsScreen.dart';
// import 'DashboardHome.dart';

// class ProjectScreen extends StatefulWidget {
//   final int userId;
//   const ProjectScreen({super.key, required this.userId});

//   @override
//   _ProjectScreenState createState() => _ProjectScreenState();
// }

// class _ProjectScreenState extends State<ProjectScreen> {
//   final ProjectService _service = ProjectService();
//   late Future<List<Project>> _projectsFuture;
//   List<Project> _projects = [];
//   List<Project> _filteredProjects = [];
//   ProjectUserPermissionsDto? _permissions;
//   String? _errorMessage;
//   final int _recordsPerPage = 10;
//   late PageController _pageController;
//   int _currentPage = 0;
//   bool _isSearchBarExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _projectsFuture = _service.fetchProjects().catchError((e) {
//       print('Error in initState: $e');
//       setState(() {
//         _errorMessage = 'Failed to load projects: $e';
//       });
//       return <Project>[];
//     });
//     _projectsFuture.then((data) {
//       _service.fetchUserPermissions().then((permissions) {
//         setState(() {
//           _projects = data;
//           _filteredProjects = data;
//           _permissions = permissions;
//           _errorMessage = null;
//         });
//       }).catchError((e) {
//         print('Permissions fetch failed: $e');
//         setState(() {
//           _permissions = ProjectUserPermissionsDto(canManageProjects: false);
//           _errorMessage = 'Failed to load permissions: $e';
//         });
//       });
//     }).catchError((e) {
//       setState(() {
//         _errorMessage = 'Failed to process projects: $e';
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _filterProjects(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredProjects = _projects;
//       } else {
//         _filteredProjects = _projects.where((project) {
//           final name = project.projectName.toLowerCase();
//           final id = project.id.toString();
//           return name.contains(query.toLowerCase()) || id.contains(query);
//         }).toList();
//       }
//       _currentPage = 0;
//       _pageController.jumpToPage(0);
//     });
//   }

//   Future<void> _createProject() async {
//     final TextEditingController nameController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Create Project', style: GoogleFonts.poppins()),
//         content: TextField(
//           controller: nameController,
//           style: GoogleFonts.poppins(fontSize: 16),
//           decoration: InputDecoration(
//             hintText: 'Project Name',
//             hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.grey.shade100,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: GoogleFonts.poppins()),
//           ),
//           TextButton(
//             onPressed: () async {
//               if (nameController.text.isNotEmpty) {
//                 try {
//                   final project = Project(
//                     id: 0,
//                     projectName: nameController.text,
//                     createdDate: DateTime.now(),
//                     projectPEs: [],
//                   );
//                   final success = await _service.createProject(project);
//                   if (success) {
//                     Navigator.pop(context);
//                     setState(() {
//                       _projectsFuture = _service.fetchProjects();
//                       _projectsFuture.then((data) {
//                         setState(() {
//                           _projects = data;
//                           _filteredProjects = data;
//                         });
//                       });
//                     });
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                           content: Text('Project created successfully',
//                               style: GoogleFonts.poppins())),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                         content: Text('Error creating project: $e',
//                             style: GoogleFonts.poppins())),
//                   );
//                 }
//               }
//             },
//             child: Text('Create', style: GoogleFonts.poppins()),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final int totalPages = (_filteredProjects.length / _recordsPerPage).ceil();

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
//                 _isSearchBarExpanded
//                     ? Expanded(
//                         child: TextField(
//                           onChanged: _filterProjects,
//                           style: GoogleFonts.poppins(fontSize: 16),
//                           decoration: InputDecoration(
//                             hintText: 'Search by Name or ID',
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
//                                   _filterProjects('');
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       )
//                     : IconButton(
//                         icon: Icon(Icons.search,
//                             color: Colors.blue.shade700, size: 28),
//                         tooltip: 'Search Projects',
//                         onPressed: () {
//                           setState(() {
//                             _isSearchBarExpanded = true;
//                           });
//                         },
//                       ),
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
//                             ? '${_filteredProjects.length}'
//                             : 'Total Records: ${_filteredProjects.length}',
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
//           Expanded(
//             child: FutureBuilder<List<Project>>(
//               future: _projectsFuture,
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
//                               'No projects found',
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
//                               .clamp(0, _filteredProjects.length);
//                           final pageRecords =
//                               _filteredProjects.sublist(startIndex, endIndex);

//                           return ListView.builder(
//                             itemCount: pageRecords.length,
//                             itemBuilder: (context, index) {
//                               final project = pageRecords[index];
//                               return InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ProjectDetailsScreen(
//                                         projectName: project.projectName,
//                                         projectId: project.id,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Card(
//                                   key: ValueKey(project.id),
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
//                                                 project.projectName,
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                             ),
//                                             if (_permissions
//                                                     ?.canManageProjects ==
//                                                 true)
//                                               IconButton(
//                                                 icon: const Icon(Icons.delete,
//                                                     color: Colors.red),
//                                                 onPressed: () async {
//                                                   try {
//                                                     final success =
//                                                         await _service
//                                                             .deleteProject(
//                                                                 project.id);
//                                                     if (success) {
//                                                       setState(() {
//                                                         _projectsFuture =
//                                                             _service
//                                                                 .fetchProjects();
//                                                         _projectsFuture
//                                                             .then((data) {
//                                                           setState(() {
//                                                             _projects = data;
//                                                             _filteredProjects =
//                                                                 data;
//                                                           });
//                                                         });
//                                                       });
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         SnackBar(
//                                                           content: Text(
//                                                               'Project deleted successfully',
//                                                               style: GoogleFonts
//                                                                   .poppins()),
//                                                         ),
//                                                       );
//                                                     }
//                                                   } catch (e) {
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       SnackBar(
//                                                         content: Text(
//                                                             'Error deleting project: $e',
//                                                             style: GoogleFonts
//                                                                 .poppins()),
//                                                       ),
//                                                     );
//                                                   }
//                                                 },
//                                               ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         _buildFieldRow(
//                                             'ID', project.id.toString()),
//                                         _buildFieldRow('Created',
//                                             project.createdDate.toString()),
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
//       floatingActionButton: _permissions?.canManageProjects == true
//           ? FloatingActionButton(
//               backgroundColor: const Color.fromARGB(255, 4, 24, 96),
//               onPressed: _createProject,
//               child: const Icon(Icons.add, color: Colors.white),
//             )
//           : null,
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
// import 'package:intl/intl.dart';
// import '../model/Project.dart';
// import '../model/ProjectUserPermissionsDto.dart';
// import '../service/ProjectService.dart';
// import 'ProjectDetailsScreen.dart';
// import 'DashboardHome.dart';

// class ProjectScreen extends StatefulWidget {
//   final int userId;
//   const ProjectScreen({super.key, required this.userId});

//   @override
//   _ProjectScreenState createState() => _ProjectScreenState();
// }

// class _ProjectScreenState extends State<ProjectScreen> {
//   final ProjectService _service = ProjectService();
//   late Future<List<Project>> _projectsFuture;
//   List<Project> _projects = [];
//   List<Project> _filteredProjects = [];
//   ProjectUserPermissionsDto? _permissions;
//   String? _errorMessage;
//   final int _recordsPerPage = 10;
//   late PageController _pageController;
//   int _currentPage = 0;
//   bool _isSearchBarExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _projectsFuture = _service.fetchProjects().catchError((e) {
//       print('Error in initState: $e');
//       setState(() {
//         _errorMessage = 'Failed to load projects: $e';
//       });
//       return <Project>[];
//     });
//     _projectsFuture.then((data) {
//       _service.fetchUserPermissions().then((permissions) {
//         setState(() {
//           _projects = data;
//           _filteredProjects = data;
//           _permissions = permissions;
//           _errorMessage = null;
//         });
//       }).catchError((e) {
//         print('Permissions fetch failed: $e');
//         setState(() {
//           _permissions = ProjectUserPermissionsDto(canManageProjects: false);
//           _errorMessage = 'Failed to load permissions: $e';
//         });
//       });
//     }).catchError((e) {
//       setState(() {
//         _errorMessage = 'Failed to process projects: $e';
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _filterProjects(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredProjects = _projects;
//       } else {
//         _filteredProjects = _projects.where((project) {
//           final name = project.projectName.toLowerCase();
//           final id = project.id.toString();
//           return name.contains(query.toLowerCase()) || id.contains(query);
//         }).toList();
//       }
//       _currentPage = 0;
//       _pageController.jumpToPage(0);
//     });
//   }

//   Future<void> _createProject() async {
//     final TextEditingController nameController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           width: 400,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                       child: Text('Create New Project',
//                           style: GoogleFonts.poppins(
//                               fontSize: 18, fontWeight: FontWeight.bold))),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text('Project Name',
//                   style: GoogleFonts.poppins(
//                       fontSize: 14, fontWeight: FontWeight.w500)),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: nameController,
//                 style: GoogleFonts.poppins(fontSize: 16),
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: const BorderSide(color: Colors.blue),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey.shade600,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: Text('Cancel',
//                           style:
//                               GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         if (nameController.text.isNotEmpty) {
//                           try {
//                             final project = Project(
//                               id: 0,
//                               projectName: nameController.text,
//                               createdDate: DateTime.now(),
//                               projectPEs: [],
//                             );
//                             final success =
//                                 await _service.createProject(project);
//                             if (success) {
//                               Navigator.pop(context);
//                               setState(() {
//                                 _projectsFuture = _service.fetchProjects();
//                                 _projectsFuture.then((data) {
//                                   setState(() {
//                                     _projects = data;
//                                     _filteredProjects = data;
//                                   });
//                                 });
//                               });
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                     content: Text(
//                                         'Project created successfully',
//                                         style: GoogleFonts.poppins())),
//                               );
//                             }
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                   content: Text('Error creating project: $e',
//                                       style: GoogleFonts.poppins())),
//                             );
//                           }
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0052CC),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: Text('Create Project',
//                           style:
//                               GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final int totalPages = (_filteredProjects.length / _recordsPerPage).ceil();

//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 12),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               Color.fromARGB(225, 82, 126, 238),
//                               Color.fromARGB(255, 7, 0, 99)
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2))
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.list,
//                                 size: 20, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Total Records: ${_filteredProjects.length}',
//                               style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: _createProject,
//                       icon: const Icon(Icons.add_circle_outline, size: 18),
//                       label: Text('Create',
//                           style:
//                               GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF1E88E5),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   onChanged: _filterProjects,
//                   style: GoogleFonts.poppins(fontSize: 16),
//                   decoration: InputDecoration(
//                     hintText: 'Search by Name or ID...',
//                     hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
//                     prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
//                     filled: true,
//                     fillColor: Colors.grey.shade100,
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 14, horizontal: 20),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: FutureBuilder<List<Project>>(
//               future: _projectsFuture,
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
//                               'No projects found',
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
//                               .clamp(0, _filteredProjects.length);
//                           final pageRecords =
//                               _filteredProjects.sublist(startIndex, endIndex);

//                           return ListView.builder(
//                             itemCount: pageRecords.length,
//                             itemBuilder: (context, index) {
//                               final project = pageRecords[index];
//                               return InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ProjectDetailsScreen(
//                                         projectName: project.projectName,
//                                         projectId: project.id,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Card(
//                                   key: ValueKey(project.id),
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
//                                             Expanded(
//                                               child: Text(
//                                                 project.projectName,
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 12),
//                                         _buildFieldRow(
//                                             'ID', project.id.toString()),
//                                         _buildFieldRow(
//                                             'Created',
//                                             DateFormat('yyyy-MM-dd HH:mm')
//                                                 .format(project.createdDate)),
//                                         const SizedBox(height: 16),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: ElevatedButton.icon(
//                                                 onPressed: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           ProjectDetailsScreen(
//                                                         projectName:
//                                                             project.projectName,
//                                                         projectId: project.id,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                                 icon: const Icon(
//                                                     Icons.folder_open,
//                                                     size: 18),
//                                                 label: Text('View Project',
//                                                     style: GoogleFonts.poppins(
//                                                         fontWeight:
//                                                             FontWeight.w600)),
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                       const Color(0xFF0052CC),
//                                                   foregroundColor: Colors.white,
//                                                   padding: const EdgeInsets
//                                                       .symmetric(vertical: 12),
//                                                   shape: RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               8)),
//                                                 ),
//                                               ),
//                                             ),
//                                             const SizedBox(width: 12),
//                                             Container(
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     color: Colors.red.shade300,
//                                                     width: 1.5),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                               ),
//                                               child: IconButton(
//                                                 icon: const Icon(
//                                                     Icons.delete_outline,
//                                                     color: Colors.red),
//                                                 onPressed: () async {
//                                                   try {
//                                                     final success =
//                                                         await _service
//                                                             .deleteProject(
//                                                                 project.id);
//                                                     if (success) {
//                                                       setState(() {
//                                                         _projectsFuture =
//                                                             _service
//                                                                 .fetchProjects();
//                                                         _projectsFuture
//                                                             .then((data) {
//                                                           setState(() {
//                                                             _projects = data;
//                                                             _filteredProjects =
//                                                                 data;
//                                                           });
//                                                         });
//                                                       });
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         SnackBar(
//                                                             content: Text(
//                                                                 'Project deleted successfully',
//                                                                 style: GoogleFonts
//                                                                     .poppins())),
//                                                       );
//                                                     }
//                                                   } catch (e) {
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       SnackBar(
//                                                           content: Text(
//                                                               'Error deleting project: $e',
//                                                               style: GoogleFonts
//                                                                   .poppins())),
//                                                     );
//                                                   }
//                                                 },
//                                               ),
//                                             ),
//                                           ],
//                                         ),
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
//       // Floating action button removed since we added Create to the top
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../model/Project.dart';
import '../model/ProjectUserPermissionsDto.dart';
import '../service/ProjectService.dart';
import 'ProjectDetailsScreen.dart';
import 'DashboardHome.dart';

class ProjectScreen extends StatefulWidget {
  final int userId;
  const ProjectScreen({super.key, required this.userId});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final ProjectService _service = ProjectService();
  late Future<List<Project>> _projectsFuture;
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  ProjectUserPermissionsDto? _permissions;
  String? _errorMessage;
  final int _recordsPerPage = 10;
  late PageController _pageController;
  int _currentPage = 0;
  bool _isSearchBarExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _projectsFuture = _service.fetchProjects().catchError((e) {
      print('Error in initState: $e');
      setState(() {
        _errorMessage = 'Failed to load projects: $e';
      });
      return <Project>[];
    });
    _projectsFuture.then((data) {
      _service.fetchUserPermissions().then((permissions) {
        setState(() {
          _projects = data;
          _filteredProjects = data;
          _permissions = permissions;
          _errorMessage = null;
        });
      }).catchError((e) {
        print('Permissions fetch failed: $e');
        setState(() {
          _permissions = ProjectUserPermissionsDto(canManageProjects: false);
          _errorMessage = 'Failed to load permissions: $e';
        });
      });
    }).catchError((e) {
      setState(() {
        _errorMessage = 'Failed to process projects: $e';
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _filterProjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProjects = _projects;
      } else {
        _filteredProjects = _projects.where((project) {
          final name = project.projectName.toLowerCase();
          final id = project.id.toString();
          return name.contains(query.toLowerCase()) || id.contains(query);
        }).toList();
      }
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  Future<void> _createProject() async {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text('Create New Project',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Project Name',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          try {
                            final project = Project(
                              id: 0,
                              projectName: nameController.text,
                              createdDate: DateTime.now(),
                              projectPEs: [],
                            );
                            final success =
                                await _service.createProject(project);
                            if (success) {
                              Navigator.pop(context);
                              setState(() {
                                _projectsFuture = _service.fetchProjects();
                                _projectsFuture.then((data) {
                                  setState(() {
                                    _projects = data;
                                    _filteredProjects = data;
                                  });
                                });
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Project created successfully',
                                        style: GoogleFonts.poppins())),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error creating project: $e',
                                      style: GoogleFonts.poppins())),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Create Project',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (_filteredProjects.length / _recordsPerPage).ceil();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(225, 82, 126, 238),
                              Color.fromARGB(255, 7, 0, 99)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.list,
                                size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Total Records: ${_filteredProjects.length}',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _createProject,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: Text('Create',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: _filterProjects,
                  style: GoogleFonts.poppins(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search by Name or ID...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Project>>(
              future: _projectsFuture,
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
                              'No projects found',
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
                              .clamp(0, _filteredProjects.length);
                          final pageRecords =
                              _filteredProjects.sublist(startIndex, endIndex);

                          return ListView.builder(
                            itemCount: pageRecords.length,
                            itemBuilder: (context, index) {
                              final project = pageRecords[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProjectDetailsScreen(
                                        projectName: project.projectName,
                                        projectId: project.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  key: ValueKey(project.id),
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
                                            Expanded(
                                              child: Text(
                                                project.projectName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildFieldRow(
                                            'ID', project.id.toString()),
                                        _buildFieldRow(
                                            'Created',
                                            DateFormat('yyyy-MM-dd HH:mm')
                                                .format(project.createdDate)),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProjectDetailsScreen(
                                                        projectName:
                                                            project.projectName,
                                                        projectId: project.id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                    Icons.folder_open,
                                                    size: 18),
                                                label: Text('View Project',
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF0052CC),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.red.shade300,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red),
                                                onPressed: () async {
                                                  try {
                                                    final success =
                                                        await _service
                                                            .deleteProject(
                                                                project.id);
                                                    if (success) {
                                                      setState(() {
                                                        _projectsFuture =
                                                            _service
                                                                .fetchProjects();
                                                        _projectsFuture
                                                            .then((data) {
                                                          setState(() {
                                                            _projects = data;
                                                            _filteredProjects =
                                                                data;
                                                          });
                                                        });
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Project deleted successfully',
                                                                style: GoogleFonts
                                                                    .poppins())),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Error deleting project: $e',
                                                              style: GoogleFonts
                                                                  .poppins())),
                                                    );
                                                  }
                                                },
                                              ),
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
      // Floating action button removed since we added Create to the top
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

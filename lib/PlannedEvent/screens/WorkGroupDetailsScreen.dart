// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../model/WorkGroupModel.dart';
// import '../service/WorkGroupService.dart';

// class WorkGroupDetailsScreen extends StatefulWidget {
//   final String workGroupName;

//   const WorkGroupDetailsScreen({super.key, required this.workGroupName});

//   @override
//   _WorkGroupDetailsScreenState createState() => _WorkGroupDetailsScreenState();
// }

// class _WorkGroupDetailsScreenState extends State<WorkGroupDetailsScreen> {
//   final WorkGroupService _service = WorkGroupService();
//   Future<List<WorkGroupDetails>> _detailsFuture = Future.value([]); // Default initialization
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     print('Fetching details for workGroupName: ${widget.workGroupName}');
//     _loadWorkGroupDetails();
//   }

//   Future<void> _loadWorkGroupDetails() async {
//     final workGroupId = await _service.getWorkGroupIdByName(widget.workGroupName);
//     if (workGroupId == null) {
//       setState(() {
//         _errorMessage = 'Work group "${widget.workGroupName}" not found or failed to load.';
//       });
//       _detailsFuture = Future.value([]); // Set to empty list on error
//     } else {
//       setState(() {
//         _detailsFuture = _service.fetchWorkGroupDetails(workGroupId).catchError((e) {
//           print('Error in initState: $e');
//           _errorMessage = e.toString().contains('Bad request')
//               ? 'Invalid work group ID or request: $e'
//               : 'Failed to load work group details: $e';
//           return <WorkGroupDetails>[]; // Return empty list on error
//         });
//       });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         iconTheme: IconThemeData(
//           color: Colors.white,
//         ),
//         title: Text(
//           '${widget.workGroupName}',
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(226, 16, 37, 89),
//                 Color.fromARGB(255, 8, 11, 66),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         elevation: 4,
//       ),
//       body: FutureBuilder<List<WorkGroupDetails>>(
//         future: _detailsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (_errorMessage != null) {
//             return Center(
//               child: Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         _errorMessage!,
//                         style: const TextStyle(fontSize: 16, color: Colors.black87),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(255, 4, 24, 96),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onPressed: () {
//                           Navigator.pushReplacementNamed(context, '/dashboard');
//                         },
//                         child: const Text('Back to Dashboard'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'No details found for "${widget.workGroupName}"',
//                         style: const TextStyle(fontSize: 16, color: Colors.black87),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(255, 4, 24, 96),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onPressed: () {
//                           Navigator.pushReplacementNamed(context, '/dashboard');
//                         },
//                         child: const Text('Back to Dashboard'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }

//           final records = snapshot.data!;
//           return ListView.builder(
//             itemCount: records.length,
//             itemBuilder: (context, index) {
//               final detail = records[index];
//               return Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 child: ExpansionTile(
//                   title: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     title: Text(
//                       'PE Number: ${detail.pE_NUMBER ?? 'N/A'}',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     subtitle: Text(
//                       'Customer: ${detail.customer ?? 'N/A'}',
//                       style: const TextStyle(fontSize: 14, color: Colors.black54),
//                     ),
//                   ),
//                   children: [
//                     _buildFieldRow('Work Group', detail.name ?? 'N/A'),
//                     _buildFieldRow('ID', detail.id?.toString() ?? 'N/A'),
//                     _buildFieldRow('PE Record ID', detail.peRecordId?.toString() ?? 'N/A'),
//                     _buildFieldRow('Province', detail.province ?? 'N/A'),
//                     _buildFieldRow('PE Title', detail.pE_TITLE ?? 'N/A'),
//                     _buildFieldRow('PE Area', detail.pE_AREA ?? 'N/A'),
//                     _buildFieldRow('SO Number', detail.sO_NUMBER ?? 'N/A'),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFieldRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: const TextStyle(
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
//               style: TextStyle(
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
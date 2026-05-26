// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../model/ProjectDetailsDto.dart';
// import '../model/OLAViolateRecord.dart';
// import '../service/ProjectService.dart';
// import '../model/ProjectUserPermissionsDto.dart';

// class ProjectDetailsScreen extends StatefulWidget {
//   final String projectName;
//   final int projectId;

//   const ProjectDetailsScreen({
//     super.key,
//     required this.projectName,
//     required this.projectId,
//   });

//   @override
//   _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
// }

// class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
//   final ProjectService _service = ProjectService();
//   final TextEditingController _searchController = TextEditingController();

//   ProjectDetailsDto? _projectDetails;
//   ProjectUserPermissionsDto? _permissions;
//   List<OLAViolateRecord> _searchResults = [];
//   final List<int> _selectedPEIds = [];

//   bool _isLoading = true;
//   bool _isSearching = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInitialData();
//   }

//   Future<void> _fetchInitialData() async {
//     setState(() => _isLoading = true);
//     try {
//       final details = await _service.fetchProjectDetails(widget.projectId);
//       final permissions = await _service.fetchUserPermissions();
//       setState(() {
//         _projectDetails = details;
//         _permissions = permissions;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _handleSearch(String term) async {
//     if (term.trim().isEmpty) {
//       setState(() => _searchResults = []);
//       return;
//     }
//     setState(() => _isSearching = true);
//     try {
//       final results =
//           await _service.searchPlannedEvents(term, widget.projectId);
//       setState(() {
//         _searchResults = results;
//         _isSearching = false;
//       });
//     } catch (e) {
//       setState(() => _isSearching = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Search failed: $e')));
//     }
//   }

//   Future<void> _assignSelected() async {
//     if (_selectedPEIds.isEmpty) return;
//     try {
//       final success = await _service.assignMultiplePEsToProject(
//           widget.projectId, _selectedPEIds);
//       if (success) {
//         _selectedPEIds.clear();
//         _searchController.clear();
//         _searchResults = [];
//         _fetchInitialData();
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('PEs assigned successfully')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Assignment failed: $e')));
//     }
//   }

//   Future<void> _removePE(int plannedEventId) async {
//     try {
//       final success =
//           await _service.removePEFromProject(widget.projectId, plannedEventId);
//       if (success) {
//         _fetchInitialData();
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('PE removed successfully')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Removal failed: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F4F8),
//       appBar: AppBar(
//         title: Text(widget.projectName,
//             style: GoogleFonts.poppins(
//                 color: Colors.white, fontWeight: FontWeight.w600)),
//         backgroundColor: const Color(0xFF041860),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _fetchInitialData,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     _buildAddPEsSection(),
//                     const SizedBox(height: 20),
//                     _buildAssignedPEsSection(),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildAddPEsSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Color(0xFF1565C0),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//             ),
//             child: const Row(
//               children: [
//                 Text('Add PEs to Project',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16)),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 _buildSearchBar(),
//                 if (_isSearching)
//                   const Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: CircularProgressIndicator()),
//                 if (_searchResults.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   _buildSearchResultsTable(),
//                   const SizedBox(height: 16),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: ElevatedButton.icon(
//                       onPressed:
//                           _selectedPEIds.isEmpty ? null : _assignSelected,
//                       icon: const Icon(Icons.add_circle_outline, size: 18),
//                       label: const Text('Assign Selected PEs'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF007BFF),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: TextField(
//         controller: _searchController,
//         decoration: const InputDecoration(
//           hintText: 'Search PE by number or customer...',
//           prefixIcon: Icon(Icons.search),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(vertical: 12),
//         ),
//         onSubmitted: _handleSearch,
//       ),
//     );
//   }

//   Widget _buildSearchResultsTable() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         columnSpacing: 24,
//         columns: const [
//           DataColumn(label: Text('')),
//           DataColumn(
//               label: Text('PE Number',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           DataColumn(
//               label: Text('Customer',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//         ],
//         rows: _searchResults.map((pe) {
//           final isSelected = _selectedPEIds.contains(pe.id);
//           return DataRow(
//             selected: isSelected,
//             onSelectChanged: (val) {
//               setState(() {
//                 if (val == true)
//                   _selectedPEIds.add(pe.id!);
//                 else
//                   _selectedPEIds.remove(pe.id);
//               });
//             },
//             cells: [
//               DataCell(Checkbox(
//                 value: isSelected,
//                 onChanged: (val) {
//                   setState(() {
//                     if (val == true)
//                       _selectedPEIds.add(pe.id!);
//                     else
//                       _selectedPEIds.remove(pe.id);
//                   });
//                 },
//               )),
//               DataCell(Text(pe.peNumber ?? '')),
//               DataCell(Text(pe.customer ?? '')),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildAssignedPEsSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: const BoxDecoration(
//               color: Color(0xFF1565C0),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//             ),
//             child: Wrap(
//               alignment: WrapAlignment.spaceBetween,
//               crossAxisAlignment: WrapCrossAlignment.center,
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 const Text('Assigned PEs',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16)),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildExportButton('Excel', Icons.table_view, Colors.green),
//                     const SizedBox(width: 8),
//                     _buildExportButton('PDF', Icons.picture_as_pdf, Colors.red),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: (_projectDetails?.projectPEs.isEmpty ?? true)
//                 ? _buildEmptyState('No PEs assigned to this project yet')
//                 : _buildAssignedPEsTable(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExportButton(String label, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration:
//           BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white, size: 14),
//           const SizedBox(width: 4),
//           Text(label,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(String msg) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//           color: const Color(0xFFE3F2FD),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.blue.shade100, width: 2)),
//       child: Row(
//         children: [
//           const Icon(Icons.info_outline, color: Colors.blue),
//           const SizedBox(width: 12),
//           Expanded(
//               child: Text(msg,
//                   style: const TextStyle(
//                       color: Color(0xFF0D47A1), fontWeight: FontWeight.w500))),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssignedPEsTable() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         columnSpacing: 20,
//         headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
//         columns: const [
//           DataColumn(label: Text('Status')),
//           DataColumn(label: Text('PE Number')),
//           DataColumn(label: Text('Customer')),
//           DataColumn(label: Text('Job Reference')),
//           DataColumn(label: Text('Required Date')),
//           DataColumn(label: Text('Current Task')),
//           DataColumn(label: Text('Current WG')),
//           DataColumn(label: Text('Action')),
//         ],
//         rows: (_projectDetails?.projectPEs ?? []).map((pe) {
//           final peNo = pe.peNumber ??
//               pe.plannedEvent?.fiberPeNo ??
//               pe.plannedEventId.toString();
//           final cust = pe.customer ?? '';
//           final jobRef = pe.jobReference ?? pe.plannedEvent?.crmOrder ?? '';
//           final reqDate = pe.serviceRequiredDate ??
//               pe.plannedEvent?.serviceRequiredDate ??
//               '';
//           final currTask =
//               pe.currentTask ?? pe.plannedEvent?.pendingTaskName ?? '';
//           final currWg = pe.currentWg ?? pe.plannedEvent?.pendingWg ?? '';

//           return DataRow(cells: [
//             DataCell(const Icon(Icons.circle, color: Colors.green, size: 16)),
//             DataCell(Text(peNo)),
//             DataCell(Text(cust)),
//             DataCell(Text(jobRef)),
//             DataCell(Text(reqDate)),
//             DataCell(Row(
//               children: [
//                 const Icon(Icons.settings, color: Colors.green, size: 16),
//                 const SizedBox(width: 4),
//                 Text(currTask,
//                     style: const TextStyle(
//                         color: Colors.green, fontWeight: FontWeight.w600)),
//               ],
//             )),
//             DataCell(Row(
//               children: [
//                 const Icon(Icons.group, color: Colors.blue, size: 16),
//                 const SizedBox(width: 4),
//                 Text(currWg,
//                     style: const TextStyle(
//                         color: Colors.blue, fontWeight: FontWeight.w600)),
//               ],
//             )),
//             DataCell(Row(
//               children: [
//                 TextButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.visibility, size: 16),
//                   label: const Text('View Details'),
//                   style: TextButton.styleFrom(
//                       backgroundColor: const Color(0xFF00D1FF),
//                       foregroundColor: Colors.white),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => _removePE(pe.plannedEventId),
//                   icon: const Icon(Icons.delete_outline, color: Colors.red),
//                 ),
//               ],
//             )),
//           ]);
//         }).toList(),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/ProjectDetailsDto.dart';
import '../model/OLAViolateRecord.dart';
import '../service/ProjectService.dart';
import '../model/ProjectUserPermissionsDto.dart';
import '../service/PERecordService.dart';
import 'PEDetailsScreen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectName;
  final int projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.projectName,
    required this.projectId,
  });

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ProjectService _service = ProjectService();
  final TextEditingController _searchController = TextEditingController();

  ProjectDetailsDto? _projectDetails;
  ProjectUserPermissionsDto? _permissions;
  List<OLAViolateRecord> _searchResults = [];
  final List<int> _selectedPEIds = [];
  final PERecordService _peRecordService = PERecordService();

  bool _isLoading = true;
  bool _isSearching = false;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final details = await _service.fetchProjectDetails(widget.projectId);
      final permissions = await _service.fetchUserPermissions();
      setState(() {
        _projectDetails = details;
        _permissions = permissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSearch(String term) async {
    if (term.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results =
          await _service.searchPlannedEvents(term, widget.projectId);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Search failed: $e')));
    }
  }

  Future<void> _assignSelected() async {
    if (_selectedPEIds.isEmpty) return;
    try {
      final success = await _service.assignMultiplePEsToProject(
          widget.projectId, _selectedPEIds);
      if (success) {
        _selectedPEIds.clear();
        _searchController.clear();
        _searchResults = [];
        _fetchInitialData();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PEs assigned successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Assignment failed: $e')));
    }
  }

  Future<void> _removePE(int plannedEventId) async {
    try {
      final success =
          await _service.removePEFromProject(widget.projectId, plannedEventId);
      if (success) {
        _fetchInitialData();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PE removed successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Removal failed: $e')));
    }
  }

  Future<void> _viewDetails(String peNumber) async {
    setState(() => _isLoading = true);
    try {
      final peRecord = await _peRecordService.fetchPERecordByNumber(peNumber);
      setState(() => _isLoading = false);
      if (peRecord != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PEDetailsScreen(peRecord: peRecord)));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('PE Record not found')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch details: $e')));
    }
  }

  Future<void> _exportToExcel() async {
    if (_projectDetails == null || _projectDetails!.projectPEs.isEmpty) return;
    setState(() => _isExporting = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Assigned PEs'];
      excel.rename('Sheet1', 'Assigned PEs');

      // Headers
      final headers = [
        'Status',
        'PE Number',
        'Customer',
        'Job Reference',
        'Required Date',
        'Current Task',
        'Current WG'
      ];
      for (int i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(headers[i]);
      }

      // Rows
      for (int rowIdx = 0;
          rowIdx < _projectDetails!.projectPEs.length;
          rowIdx++) {
        final pe = _projectDetails!.projectPEs[rowIdx];
        final peNo = pe.peNumber ??
            pe.plannedEvent?.fiberPeNo ??
            pe.plannedEventId.toString();
        final cust = pe.customer ?? '';
        final jobRef = pe.jobReference ?? pe.plannedEvent?.crmOrder ?? '';
        final reqDate = pe.serviceRequiredDate ??
            pe.plannedEvent?.serviceRequiredDate ??
            '';
        final currTask =
            pe.currentTask ?? pe.plannedEvent?.pendingTaskName ?? '';
        final currWg = pe.currentWg ?? pe.plannedEvent?.pendingWg ?? '';

        final rowData = [
          'Active',
          peNo,
          cust,
          jobRef,
          reqDate,
          currTask,
          currWg
        ];
        for (int colIdx = 0; colIdx < rowData.length; colIdx++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: colIdx, rowIndex: rowIdx + 1))
              .value = TextCellValue(rowData[colIdx]);
        }
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/Project_${widget.projectId}_PEs_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        await File(filePath).writeAsBytes(fileBytes);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel exported to: $filePath')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Excel Export failed: $e')));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPdf() async {
    if (_projectDetails == null || _projectDetails!.projectPEs.isEmpty) return;
    setState(() => _isExporting = true);
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          header: (context) => pw.Column(
            children: [
              pw.Text('${widget.projectName} - Assigned PEs',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
            ],
          ),
          build: (context) {
            return [
              pw.Table.fromTextArray(
                headers: [
                  'Status',
                  'PE Number',
                  'Customer',
                  'Job Reference',
                  'Required Date',
                  'Current Task',
                  'Current WG'
                ],
                data: _projectDetails!.projectPEs.map((pe) {
                  final peNo = pe.peNumber ??
                      pe.plannedEvent?.fiberPeNo ??
                      pe.plannedEventId.toString();
                  final cust = pe.customer ?? '';
                  final jobRef =
                      pe.jobReference ?? pe.plannedEvent?.crmOrder ?? '';
                  final reqDate = pe.serviceRequiredDate ??
                      pe.plannedEvent?.serviceRequiredDate ??
                      '';
                  final currTask =
                      pe.currentTask ?? pe.plannedEvent?.pendingTaskName ?? '';
                  final currWg =
                      pe.currentWg ?? pe.plannedEvent?.pendingWg ?? '';
                  return [
                    'Active',
                    peNo,
                    cust,
                    jobRef,
                    reqDate,
                    currTask,
                    currWg
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                  5: pw.Alignment.centerLeft,
                  6: pw.Alignment.centerLeft,
                },
              ),
            ];
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/Project_${widget.projectId}_PEs_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await doc.save());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PDF exported to: $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PDF Export failed: $e')));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(widget.projectName,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF041860),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInitialData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildAddPEsSection(),
                    const SizedBox(height: 20),
                    _buildAssignedPEsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAddPEsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Text('Add PEs to Project',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                if (_isSearching)
                  const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator()),
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSearchResultsTable(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed:
                          _selectedPEIds.isEmpty ? null : _assignSelected,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Assign Selected PEs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search PE by number or customer...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: _handleSearch,
      ),
    );
  }

  Widget _buildSearchResultsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('')),
          DataColumn(
              label: Text('PE Number',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Customer',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _searchResults.map((pe) {
          final isSelected = _selectedPEIds.contains(pe.id);
          return DataRow(
            selected: isSelected,
            onSelectChanged: (val) {
              setState(() {
                if (val == true)
                  _selectedPEIds.add(pe.id!);
                else
                  _selectedPEIds.remove(pe.id);
              });
            },
            cells: [
              DataCell(Checkbox(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true)
                      _selectedPEIds.add(pe.id!);
                    else
                      _selectedPEIds.remove(pe.id);
                  });
                },
              )),
              DataCell(Text(pe.peNumber ?? '')),
              DataCell(Text(pe.customer ?? '')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignedPEsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text('Assigned PEs',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                        onTap: _exportToExcel,
                        child: _buildExportButton(
                            'Excel', Icons.table_view, Colors.green)),
                    const SizedBox(width: 8),
                    InkWell(
                        onTap: _exportToPdf,
                        child: _buildExportButton(
                            'PDF', Icons.picture_as_pdf, Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (_projectDetails?.projectPEs.isEmpty ?? true)
                ? _buildEmptyState('No PEs assigned to this project yet')
                : _buildAssignedPEsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade100, width: 2)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Color(0xFF0D47A1), fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildAssignedPEsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('PE Number')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Job Reference')),
          DataColumn(label: Text('Required Date')),
          DataColumn(label: Text('Current Task')),
          DataColumn(label: Text('Current WG')),
          DataColumn(label: Text('Action')),
        ],
        rows: (_projectDetails?.projectPEs ?? []).map((pe) {
          final peNo = pe.peNumber ??
              pe.plannedEvent?.fiberPeNo ??
              pe.plannedEventId.toString();
          final cust = pe.customer ?? '';
          final jobRef = pe.jobReference ?? pe.plannedEvent?.crmOrder ?? '';
          final reqDate = pe.serviceRequiredDate ??
              pe.plannedEvent?.serviceRequiredDate ??
              '';
          final currTask =
              pe.currentTask ?? pe.plannedEvent?.pendingTaskName ?? '';
          final currWg = pe.currentWg ?? pe.plannedEvent?.pendingWg ?? '';

          return DataRow(cells: [
            DataCell(const Icon(Icons.circle, color: Colors.green, size: 16)),
            DataCell(Text(peNo)),
            DataCell(Text(cust)),
            DataCell(Text(jobRef)),
            DataCell(Text(reqDate)),
            DataCell(Row(
              children: [
                const Icon(Icons.settings, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(currTask,
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            )),
            DataCell(Row(
              children: [
                const Icon(Icons.group, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(currWg,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600)),
              ],
            )),
            DataCell(Row(
              children: [
                TextButton.icon(
                  onPressed: () => _viewDetails(peNo),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                  style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF00D1FF),
                      foregroundColor: Colors.white),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removePE(pe.plannedEventId),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}

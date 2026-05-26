// import 'dart:io';
// import 'package:excel/excel.dart' hide Border;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import '../model/PERecord.dart';
// import '../model/PETask.dart';
// import '../service/PERecordService.dart';
// import '../service/PETaskService.dart';

// class PEReportScreen extends StatefulWidget {
//   const PEReportScreen({super.key});

//   @override
//   State<PEReportScreen> createState() => _PEReportScreenState();
// }

// class _PEReportScreenState extends State<PEReportScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final PERecordService _peRecordService = PERecordService();
//   final PETaskService _peTaskService = PETaskService();

//   PERecord? _peRecord;
//   List<PETask> _tasks = [];

//   bool _isSearching = false;
//   bool _isExporting = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _search() async {
//     final peNumber = _searchController.text.trim();
//     if (peNumber.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a PE Number')),
//       );
//       return;
//     }

//     setState(() {
//       _isSearching = true;
//       _errorMessage = null;
//       _peRecord = null;
//       _tasks = [];
//     });

//     try {
//       final found = await _peRecordService.fetchPERecordByNumber(peNumber);

//       if (found == null) {
//         setState(() {
//           _errorMessage = 'No PE record found for "$peNumber"';
//           _isSearching = false;
//         });
//         return;
//       }

//       // Fetch tasks for this PE
//       List<PETask> tasks = [];
//       try {
//         tasks = await _peTaskService.getTasksByPENumber(found.peNumber ?? peNumber);
//       } catch (_) {}

//       setState(() {
//         _peRecord = found;
//         _tasks = tasks;
//         _isSearching = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching data: $e';
//         _isSearching = false;
//       });
//     }
//   }

//   // ── Progress calculation ─────────────────────────────────────────────────
//   double get _progressPercent {
//     if (_tasks.isEmpty) return 0.0;
//     final completed =
//         _tasks.where((t) => t.taskStatus.toUpperCase() == 'COMPLETED').length;
//     return completed / _tasks.length;
//   }

//   // ── Excel Export ─────────────────────────────────────────────────────────
//   Future<void> _exportToExcel() async {
//     if (_peRecord == null) return;
//     setState(() => _isExporting = true);

//     try {
//       final excel = Excel.createExcel();
//       excel.rename('Sheet1', 'PE Report');
//       final Sheet sheet = excel['PE Report'];

//       // ─ Helper to add a row ─
//       void addRow(String label, String? value, {bool isHeader = false}) {
//         final row = sheet.rows.length;
//         final labelCell = sheet
//             .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
//         final valueCell = sheet
//             .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));

//         labelCell.value = TextCellValue(label);
//         valueCell.value = TextCellValue(value ?? '—');

//         if (isHeader) {
//           labelCell.cellStyle = CellStyle(
//             bold: true,
//             backgroundColorHex: ExcelColor.fromHexString('FF102559'),
//             fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
//           );
//           valueCell.cellStyle = CellStyle(
//             bold: true,
//             backgroundColorHex: ExcelColor.fromHexString('FF102559'),
//             fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
//           );
//         } else {
//           labelCell.cellStyle = CellStyle(bold: true);
//         }
//       }

//       void addSectionTitle(String title) {
//         final row = sheet.rows.length;
//         final cell = sheet
//             .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
//         cell.value = TextCellValue(title);
//         cell.cellStyle = CellStyle(
//           bold: true,
//           backgroundColorHex: ExcelColor.fromHexString('FFD0E4F7'),
//         );
//         sheet
//             .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//             .cellStyle = CellStyle(
//           backgroundColorHex: ExcelColor.fromHexString('FFD0E4F7'),
//         );
//       }

//       void addBlank() {
//         final row = sheet.rows.length;
//         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
//       }

//       // Set column widths
//       sheet.setColumnWidth(0, 30);
//       sheet.setColumnWidth(1, 45);

//       final pe = _peRecord!;

//       // Title
//       addRow('PE REPORT', '', isHeader: true);
//       addBlank();

//       // PE Information
//       addSectionTitle('PE Information');
//       addRow('PE Number', pe.peNumber);
//       addRow('PE Title', pe.peTitle);
//       addRow('PE Activity', pe.peActivity);
//       addRow('PE Nature', pe.peNature);
//       addRow('PE Objective', pe.peObjective);
//       addRow('PE Area', pe.peArea);
//       addRow('PE Status', pe.peStatus);
//       addRow('Priority', pe.priority);
//       addRow('PE Created Date', pe.peCreatedDate?.split('T').first);
//       addRow('On Hold', pe.isHold != null ? (pe.isHold! ? 'Yes' : 'No') : null);
//       addBlank();

//       // Location
//       addSectionTitle('Location');
//       addRow('Province', pe.province);
//       addRow('Region', pe.region);
//       addRow('RTOM', pe.rtom);
//       addRow('RTOM Description', pe.rtomDescription);
//       addRow('Location A Address', pe.locationAAddress);
//       addRow('Location B Address', pe.locationBAddress);
//       addBlank();

//       // Service Order
//       addSectionTitle('Service Order');
//       addRow('SO Number', pe.soNumber);
//       addRow('SO ID', pe.soId);
//       addRow('SO Create Date', pe.soCreateDate);
//       addRow('Order Type', pe.orderType);
//       addRow('CRM Order', pe.crmOrder);
//       addRow('Job Reference', pe.jobReference);
//       addRow('Request Reference No', pe.requestReferenceNo);
//       addBlank();

//       // Work Order
//       addSectionTitle('Work Order');
//       addRow('WO ID', pe.woId);
//       addRow('WO Status', pe.woStatus);
//       addRow('WO Start Date', pe.woStartDate);
//       addRow('WO Actual Start Date', pe.woActualStartDate);
//       addRow('WO Comments', pe.woComments);
//       addRow('PE WO Comments', pe.peWoComments);
//       addBlank();

//       // Customer & Service
//       addSectionTitle('Customer & Service');
//       addRow('Customer', pe.customer);
//       addRow('Customer Type', pe.cusType);
//       addRow('Account Manager', pe.accountManager);
//       addRow('Service Category', pe.serviceCategory);
//       addRow('Service Type', pe.serviceType);
//       addRow('Service Speed', pe.serviceSpeed);
//       addRow('Service Required Date', pe.serviceRequiredDate);
//       addRow('Contractor', pe.contractorName);
//       addRow('Section Handled By', pe.sectionHandledBy);
//       addBlank();

//       // Task
//       addSectionTitle('Current Task');
//       addRow('Task Sequence', pe.taskSeq?.toString());
//       addRow('Task Name', pe.taskName);
//       addRow('Task WG', pe.taskWg);
//       addRow('Pending Task Name', pe.pendingTaskName);
//       addRow('Pending WG', pe.pendingWg);
//       addBlank();

//       // Fiber & Access
//       addSectionTitle('Fiber & Access');
//       addRow('Fiber PE No', pe.fiberPeNo);
//       addRow('Fiber SO ID', pe.fiberSoId);
//       addRow('NTU Type', pe.ntuType);
//       addRow('Access Medium', pe.accessMedium);
//       addRow('Access Medium A-End', pe.accessMediumAEnd);
//       addRow('Access Medium B-End', pe.accessMediumBEnd);
//       addRow('CCT ID', pe.cctId);
//       addRow('LEA', pe.lea);
//       addBlank();

//       // Progress
//       final completedCount =
//           _tasks.where((t) => t.taskStatus.toUpperCase() == 'COMPLETED').length;
//       addSectionTitle('Progress');
//       addRow('Total Tasks', _tasks.length.toString());
//       addRow('Completed Tasks', completedCount.toString());
//       addRow(
//           'Progress', '${(_progressPercent * 100).toStringAsFixed(1)}%');
//       addBlank();

//       // Task list
//       if (_tasks.isNotEmpty) {
//         addSectionTitle('Task List');
//         // header row
//         final headerRow = sheet.rows.length;
//         _taskHeaderCells(sheet, headerRow,
//             ['#', 'Task', 'Status', 'OLA', 'Created', 'Completed', 'Urgent?']);

//         for (int i = 0; i < _tasks.length; i++) {
//           final t = _tasks[i];
//           final rowIdx = sheet.rows.length;
//           _taskDataCells(sheet, rowIdx, [
//             (i + 1).toString(),
//             t.task,
//             t.taskStatus,
//             t.ola,
//             t.taskCreatedDate?.toIso8601String().split('T').first ?? '—',
//             t.taskCompleteDate?.toIso8601String().split('T').first ?? '—',
//             t.isUrgent ? 'Yes' : 'No',
//           ]);
//         }
//       }

//       // Save file
//       final dir = await getApplicationDocumentsDirectory();
//       final fileName =
//           'PE_Report_${pe.peNumber ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
//       final filePath = '${dir.path}/$fileName';
//       final fileBytes = excel.encode();
//       if (fileBytes != null) {
//         final file = File(filePath);
//         await file.writeAsBytes(fileBytes);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Report saved: $filePath'),
//               duration: const Duration(seconds: 5),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Export failed: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   void _taskHeaderCells(Sheet sheet, int rowIdx, List<String> headers) {
//     for (int c = 0; c < headers.length; c++) {
//       final cell =
//           sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx));
//       cell.value = TextCellValue(headers[c]);
//       cell.cellStyle = CellStyle(
//         bold: true,
//         backgroundColorHex: ExcelColor.fromHexString('FF102559'),
//         fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
//       );
//     }
//   }

//   void _taskDataCells(Sheet sheet, int rowIdx, List<String> values) {
//     for (int c = 0; c < values.length; c++) {
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx))
//           .value = TextCellValue(values[c]);
//     }
//   }

//   // ── Status colour ────────────────────────────────────────────────────────
//   Color _statusColor(String? status) {
//     switch ((status ?? '').toUpperCase()) {
//       case 'COMPLETED':
//         return Colors.green;
//       case 'IN PROGRESS':
//       case 'INPROGRESS':
//         return Colors.blue;
//       case 'HOLD':
//         return Colors.orange;
//       case 'CANCELLED':
//         return Colors.red;
//       default:
//         return const Color.fromARGB(255, 16, 37, 89);
//     }
//   }

//   Color _taskStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'COMPLETED':
//         return Colors.green;
//       case 'IN PROGRESS':
//       case 'INPROGRESS':
//         return Colors.blue;
//       case 'PENDING':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   // ── Build ────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'PE Report',
//           style: TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//         ),
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
//       body: Column(
//         children: [
//           // ── Search bar ──────────────────────────────────────────────
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     textInputAction: TextInputAction.search,
//                     decoration: InputDecoration(
//                       hintText: 'Enter PE Number...',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 14),
//                     ),
//                     onSubmitted: (_) => _search(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _isSearching ? null : _search,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(226, 16, 37, 89),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 18, vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: _isSearching
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.white),
//                         )
//                       : const Text('Search'),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),

//           // ── Body ────────────────────────────────────────────────────
//           Expanded(
//             child: _isSearching
//                 ? const Center(child: CircularProgressIndicator())
//                 : _errorMessage != null
//                     ? _buildError()
//                     : _peRecord == null
//                         ? _buildEmpty()
//                         : _buildReport(),
//           ),

//           // ── Export button ────────────────────────────────────────────
//           if (_peRecord != null)
//             SafeArea(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: _isExporting ? null : _exportToExcel,
//                     icon: _isExporting
//                         ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.white),
//                           )
//                         : const Icon(Icons.file_download_outlined),
//                     label: Text(
//                         _isExporting ? 'Exporting...' : 'Export Report (XL)'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green.shade700,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       textStyle: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.w600),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ── Empty / Error states ─────────────────────────────────────────────────
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.article_outlined, size: 72, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           Text('Search by PE Number to view report',
//               style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
//         ],
//       ),
//     );
//   }

//   Widget _buildError() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 48, color: Colors.red),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Text(_errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 14)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Main Report ────────────────────────────────────────────────────────
//   Widget _buildReport() {
//     final pe = _peRecord!;
//     final sc = _statusColor(pe.peStatus);
//     final completed =
//         _tasks.where((t) => t.taskStatus.toUpperCase() == 'COMPLETED').length;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Status header card ──────────────────────────────────────
//           Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               pe.peNumber ?? '—',
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color.fromARGB(255, 16, 37, 89),
//                               ),
//                             ),
//                             if (pe.peTitle != null)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Text(pe.peTitle!,
//                                     style: const TextStyle(
//                                         fontSize: 13, color: Colors.black54)),
//                               ),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           if (pe.peStatus != null)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: sc.withOpacity(0.1),
//                                 border: Border.all(color: sc),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(pe.peStatus!,
//                                   style: TextStyle(
//                                       color: sc,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12)),
//                             ),
//                           if (pe.isHold == true)
//                             Container(
//                               margin: const EdgeInsets.only(top: 4),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.1),
//                                 border: Border.all(color: Colors.orange),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Text('ON HOLD',
//                                   style: TextStyle(
//                                       color: Colors.orange,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12)),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 20),
//                   Wrap(spacing: 14, runSpacing: 6, children: [
//                     if (pe.priority != null)
//                       _chip(Icons.flag_outlined,
//                           'Priority: ${pe.priority!}'),
//                     if (pe.peCreatedDate != null)
//                       _chip(Icons.calendar_today_outlined,
//                           'Created: ${pe.peCreatedDate!.split('T').first}'),
//                     if (pe.customer != null)
//                       _chip(Icons.person_outline, pe.customer!),
//                     if (pe.soNumber != null)
//                       _chip(Icons.receipt_outlined, 'SO: ${pe.soNumber!}'),
//                   ]),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ── Progress card ───────────────────────────────────────────
//           if (_tasks.isNotEmpty) ...[
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text('Task Progress',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                                 color: Color.fromARGB(255, 16, 37, 89))),
//                         Text(
//                           '$completed / ${_tasks.length} completed',
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey.shade600),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: LinearProgressIndicator(
//                         value: _progressPercent,
//                         minHeight: 14,
//                         backgroundColor: Colors.grey.shade200,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           _progressPercent == 1.0
//                               ? Colors.green
//                               : const Color.fromARGB(255, 16, 37, 89),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         '${(_progressPercent * 100).toStringAsFixed(1)}%',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: _progressPercent == 1.0
//                                 ? Colors.green
//                                 : const Color.fromARGB(255, 16, 37, 89)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],

//           // ── PE Information ──────────────────────────────────────────
//           _buildSection('PE Information', [
//             _row('PE Number', pe.peNumber),
//             _row('PE Title', pe.peTitle),
//             _row('PE Activity', pe.peActivity),
//             _row('PE Nature', pe.peNature),
//             _row('PE Objective', pe.peObjective),
//             _row('PE Area', pe.peArea),
//             _row('PE Status', pe.peStatus),
//             _row('Priority', pe.priority),
//             _row('PE Created Date', pe.peCreatedDate?.split('T').first),
//             _row('On Hold',
//                 pe.isHold != null ? (pe.isHold! ? 'Yes' : 'No') : null),
//           ]),

//           _buildSection('Location', [
//             _row('Province', pe.province),
//             _row('Region', pe.region),
//             _row('RTOM', pe.rtom),
//             _row('RTOM Description', pe.rtomDescription),
//             _row('Location A', pe.locationAAddress),
//             _row('Location B', pe.locationBAddress),
//           ]),

//           _buildSection('Service Order', [
//             _row('SO Number', pe.soNumber),
//             _row('SO ID', pe.soId),
//             _row('SO Create Date', pe.soCreateDate),
//             _row('Order Type', pe.orderType),
//             _row('CRM Order', pe.crmOrder),
//             _row('Job Reference', pe.jobReference),
//             _row('Request Ref No', pe.requestReferenceNo),
//           ]),

//           _buildSection('Work Order', [
//             _row('WO ID', pe.woId),
//             _row('WO Status', pe.woStatus),
//             _row('WO Start Date', pe.woStartDate),
//             _row('WO Actual Start Date', pe.woActualStartDate),
//             _row('WO Comments', pe.woComments),
//             _row('PE WO Comments', pe.peWoComments),
//           ]),

//           _buildSection('Customer & Service', [
//             _row('Customer', pe.customer),
//             _row('Customer Type', pe.cusType),
//             _row('Account Manager', pe.accountManager),
//             _row('Service Category', pe.serviceCategory),
//             _row('Service Type', pe.serviceType),
//             _row('Service Speed', pe.serviceSpeed),
//             _row('Service Required Date', pe.serviceRequiredDate),
//             _row('Contractor', pe.contractorName),
//             _row('Section Handled By', pe.sectionHandledBy),
//           ]),

//           _buildSection('Current Task', [
//             _row('Task Sequence', pe.taskSeq?.toString()),
//             _row('Task Name', pe.taskName),
//             _row('Task WG', pe.taskWg),
//             _row('Pending Task Name', pe.pendingTaskName),
//             _row('Pending WG', pe.pendingWg),
//           ]),

//           _buildSection('Fiber & Access', [
//             _row('Fiber PE No', pe.fiberPeNo),
//             _row('Fiber SO ID', pe.fiberSoId),
//             _row('NTU Type', pe.ntuType),
//             _row('Access Medium', pe.accessMedium),
//             _row('Access Medium A-End', pe.accessMediumAEnd),
//             _row('Access Medium B-End', pe.accessMediumBEnd),
//             _row('CCT ID', pe.cctId),
//             _row('LEA', pe.lea),
//           ]),

//           // ── Task list ───────────────────────────────────────────────
//           if (_tasks.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             _sectionHeader('Task List'),
//             const SizedBox(height: 8),
//             ...List.generate(_tasks.length, (i) {
//               final t = _tasks[i];
//               final tc = _taskStatusColor(t.taskStatus);
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: tc.withOpacity(0.15),
//                     child: Text('${i + 1}',
//                         style: TextStyle(
//                             color: tc, fontWeight: FontWeight.bold)),
//                   ),
//                   title: Text(t.task,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.w600, fontSize: 13)),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 2),
//                       Row(children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: tc.withOpacity(0.1),
//                             border: Border.all(color: tc),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(t.taskStatus,
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   color: tc,
//                                   fontWeight: FontWeight.w600)),
//                         ),
//                         if (t.isUrgent) ...[
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.red.withOpacity(0.1),
//                               border: Border.all(color: Colors.red),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Text('URGENT',
//                                 style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.w600)),
//                           ),
//                         ],
//                       ]),
//                       if (t.taskCreatedDate != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 3),
//                           child: Text(
//                               'OLA: ${t.ola}  |  Created: ${t.taskCreatedDate!.toIso8601String().split('T').first}',
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey.shade500)),
//                         ),
//                     ],
//                   ),
//                   trailing: t.taskCompleteDate != null
//                       ? Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             const Icon(Icons.check_circle,
//                                 color: Colors.green, size: 16),
//                             Text(
//                               t.taskCompleteDate!
//                                   .toIso8601String()
//                                   .split('T')
//                                   .first,
//                               style: TextStyle(
//                                   fontSize: 10, color: Colors.grey.shade500),
//                             ),
//                           ],
//                         )
//                       : null,
//                 ),
//               );
//             }),
//           ],

//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }

//   // ── Helpers ──────────────────────────────────────────────────────────────
//   Widget _chip(IconData icon, String text) => Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: Colors.grey.shade600),
//           const SizedBox(width: 4),
//           Text(text,
//               style:
//                   TextStyle(fontSize: 12, color: Colors.grey.shade700)),
//         ],
//       );

//   Widget _sectionHeader(String title) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               Color.fromARGB(226, 16, 37, 89),
//               Color.fromARGB(200, 16, 50, 120),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(children: [
//           const Icon(Icons.list_alt, color: Colors.white70, size: 16),
//           const SizedBox(width: 8),
//           Text(title,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14)),
//         ]),
//       );

//   Widget _buildSection(String title, List<Widget> rows) {
//     final nonEmpty = rows
//         .whereType<_DetailRow>()
//         .where((w) => w.value != null && w.value!.isNotEmpty)
//         .toList();
//     if (nonEmpty.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 12),
//         _sectionHeader(title),
//         const SizedBox(height: 6),
//         Card(
//           elevation: 2,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Column(children: nonEmpty),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _row(String label, String? value) =>
//       _DetailRow(label: label, value: value);
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String? value;

//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     if (value == null || value!.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 4,
//             child: Text(label,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                     color: Colors.black54)),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             flex: 6,
//             child: Text(value!,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'DashboardScreen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../model/PERecord.dart';
import '../model/PETask.dart';
import '../service/PERecordService.dart';
import '../service/PETaskService.dart';

class PEReportScreen extends StatefulWidget {
  const PEReportScreen({super.key});

  @override
  State<PEReportScreen> createState() => _PEReportScreenState();
}

class _PEReportScreenState extends State<PEReportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PERecordService _peRecordService = PERecordService();
  final PETaskService _peTaskService = PETaskService();

  PERecord? _peRecord;
  List<PETask> _tasks = [];

  bool _isSearching = false;
  bool _isExporting = false;
  bool _isExportingPdf = false;
  String? _errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final storedId = await _storage.read(key: 'userId');
    if (storedId != null) {
      setState(() {
        _userId = int.tryParse(storedId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final peNumber = _searchController.text.trim();
    if (peNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a PE Number')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _peRecord = null;
      _tasks = [];
    });

    try {
      final found = await _peRecordService.fetchPERecordByNumber(peNumber);

      if (found == null) {
        setState(() {
          _errorMessage = 'No PE record found for "$peNumber"';
          _isSearching = false;
        });
        return;
      }

      // Fetch tasks for this PE
      List<PETask> tasks = [];
      try {
        tasks =
            await _peTaskService.getTasksByPENumber(found.peNumber ?? peNumber);
      } catch (_) {}

      setState(() {
        _peRecord = found;
        _tasks = tasks;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _isSearching = false;
      });
    }
  }

  // ── Progress calculation ─────────────────────────────────────────────────
  double get _progressPercent {
    if (_tasks.isEmpty) return 0.0;
    final completed =
        _tasks.where((t) => t.taskStatus.toUpperCase() == 'COMPLETED').length;
    return completed / _tasks.length;
  }

  // ── Excel Export ─────────────────────────────────────────────────────────
  Future<void> _exportToExcel() async {
    if (_peRecord == null) return;
    setState(() => _isExporting = true);

    try {
      final excel = Excel.createExcel();
      excel.rename('Sheet1', 'PE Report');
      final Sheet sheet = excel['PE Report'];

      // ─ Helper to add a row ─
      void addRow(String label, String? value, {bool isHeader = false}) {
        final row = sheet.rows.length;
        final labelCell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
        final valueCell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));

        labelCell.value = TextCellValue(label);
        valueCell.value = TextCellValue(value ?? '—');

        if (isHeader) {
          labelCell.cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: ExcelColor.fromHexString('FF102559'),
            fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
          );
          valueCell.cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: ExcelColor.fromHexString('FF102559'),
            fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
          );
        } else {
          labelCell.cellStyle = CellStyle(bold: true);
        }
      }

      void addSectionTitle(String title) {
        final row = sheet.rows.length;
        final cell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
        cell.value = TextCellValue(title);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('FFD0E4F7'),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .cellStyle = CellStyle(
          backgroundColorHex: ExcelColor.fromHexString('FFD0E4F7'),
        );
      }

      void addBlank() {
        final row = sheet.rows.length;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      }

      // Set column widths
      sheet.setColumnWidth(0, 30);
      sheet.setColumnWidth(1, 45);

      final pe = _peRecord!;

      // Title
      addRow('PE REPORT', '', isHeader: true);
      addBlank();

      // PE Information
      addSectionTitle('PE Information');
      addRow('PE Number', pe.peNumber);
      addRow('PE Title', pe.peTitle);
      addRow('PE Activity', pe.peActivity);
      addRow('PE Nature', pe.peNature);
      addRow('PE Objective', pe.peObjective);
      addRow('PE Area', pe.peArea);
      addRow('PE Status', pe.peStatus);
      addRow('Priority', pe.priority);
      addRow('PE Created Date', pe.peCreatedDate?.split('T').first);
      addRow('On Hold', pe.isHold != null ? (pe.isHold! ? 'Yes' : 'No') : null);
      addBlank();

      // Location
      addSectionTitle('Location');
      addRow('Province', pe.province);
      addRow('Region', pe.region);
      addRow('RTOM', pe.rtom);
      addRow('RTOM Description', pe.rtomDescription);
      addRow('Location A Address', pe.locationAAddress);
      addRow('Location B Address', pe.locationBAddress);
      addBlank();

      // Service Order
      addSectionTitle('Service Order');
      addRow('SO Number', pe.soNumber);
      addRow('SO ID', pe.soId);
      addRow('SO Create Date', pe.soCreateDate);
      addRow('Order Type', pe.orderType);
      addRow('CRM Order', pe.crmOrder);
      addRow('Job Reference', pe.jobReference);
      addRow('Request Reference No', pe.requestReferenceNo);
      addBlank();

      // Work Order
      addSectionTitle('Work Order');
      addRow('WO ID', pe.woId);
      addRow('WO Status', pe.woStatus);
      addRow('WO Start Date', pe.woStartDate);
      addRow('WO Actual Start Date', pe.woActualStartDate);
      addRow('WO Comments', pe.woComments);
      addRow('PE WO Comments', pe.peWoComments);
      addBlank();

      // Customer & Service
      addSectionTitle('Customer & Service');
      addRow('Customer', pe.customer);
      addRow('Customer Type', pe.cusType);
      addRow('Account Manager', pe.accountManager);
      addRow('Service Category', pe.serviceCategory);
      addRow('Service Type', pe.serviceType);
      addRow('Service Speed', pe.serviceSpeed);
      addRow('Service Required Date', pe.serviceRequiredDate);
      addRow('Contractor', pe.contractorName);
      addRow('Section Handled By', pe.sectionHandledBy);
      addBlank();

      // Task
      addSectionTitle('Current Task');
      addRow('Task Sequence', pe.taskSeq?.toString());
      addRow('Task Name', pe.taskName);
      addRow('Task WG', pe.taskWg);
      addRow('Pending Task Name', pe.pendingTaskName);
      addRow('Pending WG', pe.pendingWg);
      addBlank();

      // Fiber & Access
      addSectionTitle('Fiber & Access');
      addRow('Fiber PE No', pe.fiberPeNo);
      addRow('Fiber SO ID', pe.fiberSoId);
      addRow('NTU Type', pe.ntuType);
      addRow('Access Medium', pe.accessMedium);
      addRow('Access Medium A-End', pe.accessMediumAEnd);
      addRow('Access Medium B-End', pe.accessMediumBEnd);
      addRow('CCT ID', pe.cctId);
      addRow('LEA', pe.lea);
      addBlank();

      // Progress
      final completedCount =
          _tasks.where((t) => t.taskStatus.toUpperCase() == 'COMPLETED').length;
      addSectionTitle('Progress');
      addRow('Total Tasks', _tasks.length.toString());
      addRow('Completed Tasks', completedCount.toString());
      addRow('Progress', '${(_progressPercent * 100).toStringAsFixed(1)}%');
      addBlank();

      // Task list
      if (_tasks.isNotEmpty) {
        addSectionTitle('Task List');
        // header row
        final headerRow = sheet.rows.length;
        _taskHeaderCells(sheet, headerRow,
            ['#', 'Task', 'Status', 'OLA', 'Created', 'Completed', 'Urgent?']);

        for (int i = 0; i < _tasks.length; i++) {
          final t = _tasks[i];
          final rowIdx = sheet.rows.length;
          _taskDataCells(sheet, rowIdx, [
            (i + 1).toString(),
            t.task,
            t.taskStatus,
            t.ola,
            t.taskCreatedDate?.toIso8601String().split('T').first ?? '—',
            t.taskCompleteDate?.toIso8601String().split('T').first ?? '—',
            t.isUrgent ? 'Yes' : 'No',
          ]);
        }
      }

      // Save file
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'PE_Report_${pe.peNumber ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${dir.path}/$fileName';
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report saved: $filePath'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ── PDF Export ───────────────────────────────────────────────────────────
  Future<void> _exportToPdf() async {
    if (_peRecord == null) return;
    setState(() => _isExportingPdf = true);

    try {
      final doc = pw.Document();
      final pe = _peRecord!;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PE PROGRESS REPORT',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                  pw.Text(DateTime.now().toIso8601String().split('T').first,
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 20),
            ],
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ),
          build: (context) => [
            // ── PE Status Summary ──
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(pe.peNumber ?? '—',
                          style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800)),
                      pw.SizedBox(height: 4),
                      pw.Text(pe.peTitle ?? 'NO TITLE PROVIDED',
                          style: const pw.TextStyle(
                              fontSize: 11, color: PdfColors.black)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('STATUS: ${pe.peStatus ?? 'N/A'}',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      if (pe.isHold == true)
                        pw.Text('ON HOLD',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.orange)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // ── Progress ──
            if (_tasks.isNotEmpty) ...[
              pw.Text('Execution Progress',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Row(children: [
                pw.Expanded(
                  child: pw.Container(
                    height: 10,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Container(
                        width: _progressPercent * 400, // rough estimate scale
                        decoration: pw.BoxDecoration(
                          color: _progressPercent == 1.0
                              ? PdfColors.green
                              : PdfColors.blue800,
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(5)),
                        ),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text('${(_progressPercent * 100).toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ]),
              pw.SizedBox(height: 20),
            ],

            // ── Details Table ──
            _pwSectionTitle('Core Information'),
            _pwDetailTable([
              ['PE Number', pe.peNumber],
              ['PE Activity', pe.peActivity],
              ['PE Nature', pe.peNature],
              ['PE Area', pe.peArea],
              ['Priority', pe.priority],
              ['Customer', pe.customer],
              ['SO Number', pe.soNumber],
            ]),

            pw.SizedBox(height: 15),
            _pwSectionTitle('Location & Service'),
            _pwDetailTable([
              ['Province', pe.province],
              ['Region', pe.region],
              ['RTOM', pe.rtom],
              ['Address A', pe.locationAAddress],
              ['Address B', pe.locationBAddress],
              ['Service Category', pe.serviceCategory],
              ['Contractor', pe.contractorName],
            ]),

            pw.SizedBox(height: 15),
            _pwSectionTitle('Current Status'),
            _pwDetailTable([
              ['WO ID', pe.woId],
              ['WO Status', pe.woStatus],
              ['WO Start', pe.woStartDate],
              ['Pending Task', pe.pendingTaskName],
              ['Pending WG', pe.pendingWg],
            ]),

            pw.NewPage(),

            // ── Task List ──
            if (_tasks.isNotEmpty) ...[
              pw.Text('Detailed Task List',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(25),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.blue900),
                    children: [
                      _pwTableCell('#', isHeader: true),
                      _pwTableCell('Task Description', isHeader: true),
                      _pwTableCell('Status', isHeader: true),
                      _pwTableCell('OLA', isHeader: true),
                      _pwTableCell('Date', isHeader: true),
                    ],
                  ),
                  ...List.generate(_tasks.length, (i) {
                    final t = _tasks[i];
                    return pw.TableRow(
                      children: [
                        _pwTableCell((i + 1).toString()),
                        _pwTableCell(t.task),
                        _pwTableCell(t.taskStatus),
                        _pwTableCell(t.ola),
                        _pwTableCell(t.taskCompleteDate != null
                            ? t.taskCompleteDate!
                                .toIso8601String()
                                .split('T')
                                .first
                            : (t.taskCreatedDate
                                    ?.toIso8601String()
                                    .split('T')
                                    .first ??
                                '—')),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ],
        ),
      );

      // Save or Share
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save(),
          name: 'PE_Report_${pe.peNumber}.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  pw.Widget _pwSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blue50,
        border:
            pw.Border(left: pw.BorderSide(color: PdfColors.blue800, width: 4)),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900)),
    );
  }

  pw.Widget _pwDetailTable(List<List<String?>> data) {
    return pw.Table(
      border: const pw.TableBorder(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
      children:
          data.where((row) => row[1] != null && row[1]!.isNotEmpty).map((row) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: pw.Text(row[0]!,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: pw.Text(row[1] ?? '—',
                  style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _pwTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  void _taskHeaderCells(Sheet sheet, int rowIdx, List<String> headers) {
    for (int c = 0; c < headers.length; c++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('FF102559'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
      );
    }
  }

  void _taskDataCells(Sheet sheet, int rowIdx, List<String> values) {
    for (int c = 0; c < values.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx))
          .value = TextCellValue(values[c]);
    }
  }

  // ── Status colour ────────────────────────────────────────────────────────
  Color _statusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'IN PROGRESS':
      case 'INPROGRESS':
        return Colors.blue;
      case 'HOLD':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return const Color.fromARGB(255, 16, 37, 89);
    }
  }

  Color _taskStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'IN PROGRESS':
      case 'INPROGRESS':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_userId != null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(userId: _userId!),
                ),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'PE Report',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
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
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Enter PE Number...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearching ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(226, 16, 37, 89),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildError()
                    : _peRecord == null
                        ? _buildEmpty()
                        : _buildReport(),
          ),

          // ── Export buttons ────────────────────────────────────────────
          if (_peRecord != null)
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportToExcel,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.table_view_outlined),
                        label: Text(_isExporting ? '...' : 'Export Excel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExportingPdf ? null : _exportToPdf,
                        icon: _isExportingPdf
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(_isExportingPdf ? '...' : 'Export PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty / Error states ─────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Search by PE Number to view report',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── Main Report ────────────────────────────────────────────────────────
  Widget _buildReport() {
    final pe = _peRecord!;
    final sc = _statusColor(pe.peStatus);
    final completed =
        _tasks.where((t) => t.taskStatus.toUpperCase() == 'COMPLETED').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status header card ──────────────────────────────────────
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pe.peNumber ?? '—',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 16, 37, 89),
                              ),
                            ),
                            if (pe.peTitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(pe.peTitle!,
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black54)),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (pe.peStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: sc.withOpacity(0.1),
                                border: Border.all(color: sc),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(pe.peStatus!,
                                  style: TextStyle(
                                      color: sc,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          if (pe.isHold == true)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('ON HOLD',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Wrap(spacing: 14, runSpacing: 6, children: [
                    if (pe.priority != null)
                      _chip(Icons.flag_outlined, 'Priority: ${pe.priority!}'),
                    if (pe.peCreatedDate != null)
                      _chip(Icons.calendar_today_outlined,
                          'Created: ${pe.peCreatedDate!.split('T').first}'),
                    if (pe.customer != null)
                      _chip(Icons.person_outline, pe.customer!),
                    if (pe.soNumber != null)
                      _chip(Icons.receipt_outlined, 'SO: ${pe.soNumber!}'),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Progress card ───────────────────────────────────────────
          if (_tasks.isNotEmpty) ...[
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Task Progress',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color.fromARGB(255, 16, 37, 89))),
                        Text(
                          '$completed / ${_tasks.length} completed',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progressPercent,
                        minHeight: 14,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progressPercent == 1.0
                              ? Colors.green
                              : const Color.fromARGB(255, 16, 37, 89),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(_progressPercent * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _progressPercent == 1.0
                                ? Colors.green
                                : const Color.fromARGB(255, 16, 37, 89)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── PE Information ──────────────────────────────────────────
          _buildSection('PE Information', [
            _row('PE Number', pe.peNumber),
            _row('PE Title', pe.peTitle),
            _row('PE Activity', pe.peActivity),
            _row('PE Nature', pe.peNature),
            _row('PE Objective', pe.peObjective),
            _row('PE Area', pe.peArea),
            _row('PE Status', pe.peStatus),
            _row('Priority', pe.priority),
            _row('PE Created Date', pe.peCreatedDate?.split('T').first),
            _row('On Hold',
                pe.isHold != null ? (pe.isHold! ? 'Yes' : 'No') : null),
          ]),

          _buildSection('Location', [
            _row('Province', pe.province),
            _row('Region', pe.region),
            _row('RTOM', pe.rtom),
            _row('RTOM Description', pe.rtomDescription),
            _row('Location A', pe.locationAAddress),
            _row('Location B', pe.locationBAddress),
          ]),

          _buildSection('Service Order', [
            _row('SO Number', pe.soNumber),
            _row('SO ID', pe.soId),
            _row('SO Create Date', pe.soCreateDate),
            _row('Order Type', pe.orderType),
            _row('CRM Order', pe.crmOrder),
            _row('Job Reference', pe.jobReference),
            _row('Request Ref No', pe.requestReferenceNo),
          ]),

          _buildSection('Work Order', [
            _row('WO ID', pe.woId),
            _row('WO Status', pe.woStatus),
            _row('WO Start Date', pe.woStartDate),
            _row('WO Actual Start Date', pe.woActualStartDate),
            _row('WO Comments', pe.woComments),
            _row('PE WO Comments', pe.peWoComments),
          ]),

          _buildSection('Customer & Service', [
            _row('Customer', pe.customer),
            _row('Customer Type', pe.cusType),
            _row('Account Manager', pe.accountManager),
            _row('Service Category', pe.serviceCategory),
            _row('Service Type', pe.serviceType),
            _row('Service Speed', pe.serviceSpeed),
            _row('Service Required Date', pe.serviceRequiredDate),
            _row('Contractor', pe.contractorName),
            _row('Section Handled By', pe.sectionHandledBy),
          ]),

          _buildSection('Current Task', [
            _row('Task Sequence', pe.taskSeq?.toString()),
            _row('Task Name', pe.taskName),
            _row('Task WG', pe.taskWg),
            _row('Pending Task Name', pe.pendingTaskName),
            _row('Pending WG', pe.pendingWg),
          ]),

          _buildSection('Fiber & Access', [
            _row('Fiber PE No', pe.fiberPeNo),
            _row('Fiber SO ID', pe.fiberSoId),
            _row('NTU Type', pe.ntuType),
            _row('Access Medium', pe.accessMedium),
            _row('Access Medium A-End', pe.accessMediumAEnd),
            _row('Access Medium B-End', pe.accessMediumBEnd),
            _row('CCT ID', pe.cctId),
            _row('LEA', pe.lea),
          ]),

          // ── Task list ───────────────────────────────────────────────
          if (_tasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            _sectionHeader('Task List'),
            const SizedBox(height: 8),
            ...List.generate(_tasks.length, (i) {
              final t = _tasks[i];
              final tc = _taskStatusColor(t.taskStatus);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tc.withOpacity(0.15),
                    child: Text('${i + 1}',
                        style:
                            TextStyle(color: tc, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(t.task,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tc.withOpacity(0.1),
                            border: Border.all(color: tc),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(t.taskStatus,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: tc,
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (t.isUrgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('URGENT',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ]),
                      if (t.taskCreatedDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                              'OLA: ${t.ola}  |  Created: ${t.taskCreatedDate!.toIso8601String().split('T').first}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ),
                    ],
                  ),
                  trailing: t.taskCompleteDate != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            Text(
                              t.taskCompleteDate!
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            }),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _chip(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      );

  Widget _sectionHeader(String title) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(226, 16, 37, 89),
              Color.fromARGB(200, 16, 50, 120),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          const Icon(Icons.list_alt, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ]),
      );

  Widget _buildSection(String title, List<Widget> rows) {
    final nonEmpty = rows
        .whereType<_DetailRow>()
        .where((w) => w.value != null && w.value!.isNotEmpty)
        .toList();
    if (nonEmpty.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _sectionHeader(title),
        const SizedBox(height: 6),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: nonEmpty),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String? value) =>
      _DetailRow(label: label, value: value);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(value!,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

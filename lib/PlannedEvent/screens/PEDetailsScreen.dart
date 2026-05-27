import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/PERecord.dart';

class PEDetailsScreen extends StatelessWidget {
  final PERecord peRecord;

  const PEDetailsScreen({super.key, required this.peRecord});

  Color get _statusColor {
    switch ((peRecord.peStatus ?? '').toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          peRecord.peNumber ?? 'PE Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status header card ─────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                                peRecord.peNumber ?? '—',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 16, 37, 89),
                                ),
                              ),
                              if (peRecord.peTitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    peRecord.peTitle!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (peRecord.peStatus != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor.withOpacity(0.1),
                                  border: Border.all(color: _statusColor),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  peRecord.peStatus!,
                                  style: TextStyle(
                                    color: _statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (peRecord.isHold == true)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'ON HOLD',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (peRecord.priority != null)
                          _chipInfo(Icons.flag_outlined,
                              'Priority: ${peRecord.priority!}'),
                        if (peRecord.peCreatedDate != null)
                          _chipInfo(Icons.calendar_today_outlined,
                              'Created: ${peRecord.peCreatedDate!.split('T').first}'),
                        if (peRecord.customer != null)
                          _chipInfo(Icons.person_outline, peRecord.customer!),
                        if (peRecord.soNumber != null)
                          _chipInfo(Icons.receipt_outlined,
                              'SO: ${peRecord.soNumber!}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── PE Information ─────────────────────────────────────
            _buildSection('PE Information', [
              _row('PE Number', peRecord.peNumber),
              _row('PE Title', peRecord.peTitle),
              _row('PE Activity', peRecord.peActivity),
              _row('PE Nature', peRecord.peNature),
              _row('PE Objective', peRecord.peObjective),
              _row('PE Area', peRecord.peArea),
              _row('PE Status', peRecord.peStatus),
              _row('Priority', peRecord.priority),
              _row('PE Created Date', peRecord.peCreatedDate),
              _row(
                  'On Hold',
                  peRecord.isHold != null
                      ? (peRecord.isHold! ? 'Yes' : 'No')
                      : null),
            ]),

            // ── Location ───────────────────────────────────────────
            _buildSection('Location', [
              _row('Province', peRecord.province),
              _row('Region', peRecord.region),
              _row('RTOM', peRecord.rtom),
              _row('RTOM Description', peRecord.rtomDescription),
              _row('Region 1', peRecord.region1),
              _row('Province 1', peRecord.province1),
              _row('RTOM 1', peRecord.rtom1),
              _row('Location A Address', peRecord.locationAAddress),
              _row('Location B Address', peRecord.locationBAddress),
            ]),

            // ── Service Order ──────────────────────────────────────
            _buildSection('Service Order', [
              _row('SO Number', peRecord.soNumber),
              _row('SO ID', peRecord.soId),
              _row('SO Create Date', peRecord.soCreateDate),
              _row('Order Type', peRecord.orderType),
              _row('CRM Order', peRecord.crmOrder),
              _row('Job Reference', peRecord.jobReference),
              _row('Request Reference No', peRecord.requestReferenceNo),
            ]),

            // ── Work Order ─────────────────────────────────────────
            _buildSection('Work Order', [
              _row('WO ID', peRecord.woId),
              _row('WO Status', peRecord.woStatus),
              _row('WO Start Date', peRecord.woStartDate),
              _row('WO Actual Start Date', peRecord.woActualStartDate),
              _row('WO Comments', peRecord.woComments),
              _row('PE WO Comments', peRecord.peWoComments),
            ]),

            // ── Task ───────────────────────────────────────────────
            _buildSection('Task', [
              _row('Task Sequence', peRecord.taskSeq?.toString()),
              _row('Task Name', peRecord.taskName),
              _row('Task WG', peRecord.taskWg),
              _row('Pending Task Name', peRecord.pendingTaskName),
              _row('Pending WG', peRecord.pendingWg),
            ]),

            // ── Customer & Service ─────────────────────────────────
            _buildSection('Customer & Service', [
              _row('Customer', peRecord.customer),
              _row('Customer Type', peRecord.cusType),
              _row('Account Manager', peRecord.accountManager),
              _row('Service Category', peRecord.serviceCategory),
              _row('Service Type', peRecord.serviceType),
              _row('Service Speed', peRecord.serviceSpeed),
              _row('Service Required Date', peRecord.serviceRequiredDate),
              _row('Contractor', peRecord.contractorName),
              _row('Section Handled By', peRecord.sectionHandledBy),
              _row('Urgent Requested By', peRecord.urgentRequestedByName),
            ]),

            // ── Fiber & Access ─────────────────────────────────────
            _buildSection('Fiber & Access', [
              _row('Fiber PE No', peRecord.fiberPeNo),
              _row('Fiber SO ID', peRecord.fiberSoId),
              _row('Product SO ID', peRecord.productSoId),
              _row('Fiber PE Task Name', peRecord.fiberPeTaskName),
              _row('Fiber PE Task WG', peRecord.fiberPeTaskWg),
              _row('NTU Type', peRecord.ntuType),
              _row('Access Medium', peRecord.accessMedium),
              _row('Access Medium A-End', peRecord.accessMediumAEnd),
              _row('Access Medium B-End', peRecord.accessMediumBEnd),
              _row('CCT ID', peRecord.cctId),
              _row('LEA', peRecord.lea),
            ]),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _chipInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    final nonEmpty = rows
        .whereType<_RowWidget>()
        .where((w) => w.value != null && w.value!.isNotEmpty)
        .toList();
    if (nonEmpty.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(226, 16, 37, 89),
                Color.fromARGB(200, 16, 50, 120),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: nonEmpty),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String? value) =>
      _RowWidget(label: label, value: value);
}

class _RowWidget extends StatelessWidget {
  final String label;
  final String? value;

  const _RowWidget({required this.label, required this.value});

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
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value!,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

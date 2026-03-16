import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../model/OLAViolateRecord.dart';
import 'PETaskScreen.dart';

class OLAViolateRecordDetailsScreen extends StatelessWidget {
  final OLAViolateRecord record;

  const OLAViolateRecordDetailsScreen({super.key, required this.record});

  void _navigateToPETasksScreen(BuildContext context) {
    if (record.peNumber != null && record.peNumber!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PETaskScreen(peNumber: record.peNumber!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PE Number is not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Rendering with record: ${record.toJson()}');
      print('peTask available: ${record.peTask != null}');
      print('plannedEvent available: ${record.plannedEvent != null}');
      print(
          'additionalData available: ${record.additionalData != null && record.additionalData!.isNotEmpty}');
      print(
          'General fields: peNumber=${record.peNumber}, customer=${record.customer}, peActivity=${record.peActivity}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          record.peNumber ?? 'Details',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        centerTitle: true,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSection(
                  context,
                  title: 'General Information',
                  icon: Icons.info,
                  fields: [
                    _Field('ID', record.id?.toString() ?? 'N/A'),
                    _Field('PE Number', record.peNumber ?? 'N/A'),
                    _Field('Customer', record.customer ?? 'N/A'),
                    _Field('Customer Type', record.cusType ?? 'N/A'),
                    _Field('Account Manager', record.accountManager ?? 'N/A'),
                    _Field(
                        'Section Handled By', record.sectionHandledBy ?? 'N/A'),
                    _Field('Contractor', record.contractorName ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'PE Details',
                  icon: Icons.description,
                  fields: [
                    _Field('PE Activity', record.peActivity ?? 'N/A'),
                    _Field('PE Nature', record.peNature ?? 'N/A'),
                    _Field('PE Title', record.peTitle ?? 'N/A'),
                    _Field('PE Objective', record.peObjective ?? 'N/A'),
                    _Field('PE Area', record.peArea ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Location Information',
                  icon: Icons.location_on,
                  fields: [
                    _Field('Province', record.province ?? 'N/A'),
                    _Field('Region', record.region ?? 'N/A'),
                    _Field('RTOM', record.rtom ?? 'N/A'),
                    _Field('RTOM Description', record.rtomDescription ?? 'N/A'),
                    _Field(
                        'Location A Address', record.locationAAddress ?? 'N/A'),
                    _Field(
                        'Location B Address', record.locationBAddress ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Service Information',
                  icon: Icons.build,
                  fields: [
                    _Field('Service Type', record.serviceType ?? 'N/A'),
                    _Field('Service Category', record.serviceCategory ?? 'N/A'),
                    _Field('Task Workgroup', record.taskWg ?? 'N/A'),
                    _Field('Service Speed',
                        record.plannedEvent?.serviceSpeed ?? 'N/A'),
                    _Field('Service Required Date',
                        record.plannedEvent?.serviceRequiredDate ?? 'N/A'),
                    _Field('NTU Type', record.plannedEvent?.ntuType ?? 'N/A'),
                    _Field('Access Medium',
                        record.plannedEvent?.accessMedium ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Work Order Details',
                  icon: Icons.work,
                  fields: [
                    _Field('SO Number', record.soNumber ?? 'N/A'),
                    _Field('SO ID', record.soId ?? 'N/A'),
                    _Field('Request Reference No',
                        record.requestReferenceNo ?? 'N/A'),
                    _Field('Work Order Start Date',
                        record.woActualStartDate ?? 'N/A'),
                    _Field('SO Create Date', record.soCreateDate ?? 'N/A'),
                    _Field('Order Type', record.orderType ?? 'N/A'),
                    _Field(
                        'Task Sequence', record.taskSeq?.toString() ?? 'N/A'),
                    _Field('Work Order ID', record.woId ?? 'N/A'),
                    _Field('Work Order Status', record.woStatus ?? 'N/A'),
                    _Field('Pending Task Name',
                        record.plannedEvent?.pendingTaskName ?? 'N/A'),
                    _Field('Pending Workgroup',
                        record.plannedEvent?.pendingWg ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'PE Task Information',
                  icon: Icons.task,
                  fields: [
                    _Field('Task ID', record.peTask?.id?.toString() ?? 'N/A'),
                    _Field('Task', record.peTask?.task ?? 'N/A'),
                    _Field('Task Sequence',
                        record.peTask?.taskSeq?.toString() ?? 'N/A'),
                    _Field('Task Workgroup',
                        record.peTask?.taskWorkGroup ?? 'N/A'),
                    _Field('OLA', record.peTask?.ola ?? 'N/A'),
                    _Field('Task Status', record.peTask?.taskStatus ?? 'N/A'),
                    _Field('Task Created Date',
                        record.peTask?.taskCreatedDate ?? 'N/A'),
                    _Field('Task Complete Date',
                        record.peTask?.taskCompleteDate ?? 'N/A'),
                    _Field('Actual Task Created Date',
                        record.peTask?.actualTaskCreatedDate ?? 'N/A'),
                    _Field('Actual Task Complete Date',
                        record.peTask?.aCtualTaskCompleteDate ?? 'N/A'),
                    _Field('Is Urgent',
                        record.peTask?.isUrgent?.toString() ?? 'N/A'),
                    _Field('Urgent Requested',
                        record.peTask?.urgentRequested?.toString() ?? 'N/A'),
                    _Field('Priority', record.peTask?.priority ?? 'N/A'),
                    _Field('Estimated Time',
                        record.peTask?.estimatedTime ?? 'N/A'),
                    _Field('Is OLA Violated',
                        record.peTask?.isOLAViolate?.toString() ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Fiber Information',
                  icon: Icons.cable,
                  fields: [
                    _Field('CCT ID', record.plannedEvent?.cctId ?? 'N/A'),
                    _Field('LEA', record.plannedEvent?.lea ?? 'N/A'),
                    _Field('CRM Order', record.plannedEvent?.crmOrder ?? 'N/A'),
                    _Field('Work Order Comments',
                        record.plannedEvent?.woComments ?? 'N/A'),
                    _Field('PE Work Order Comments',
                        record.plannedEvent?.peWoComments ?? 'N/A'),
                    _Field('Fiber PE Number',
                        record.plannedEvent?.fiberPeNo ?? 'N/A'),
                    _Field(
                        'Fiber SO ID', record.plannedEvent?.fiberSoId ?? 'N/A'),
                    _Field('Product SO ID',
                        record.plannedEvent?.productSoId ?? 'N/A'),
                    _Field('Fiber PE Task Name',
                        record.plannedEvent?.fiberPeTaskName ?? 'N/A'),
                    _Field('Fiber PE Task Workgroup',
                        record.plannedEvent?.fiberPeTaskWg ?? 'N/A'),
                    _Field('PE Created Date',
                        record.plannedEvent?.peCreatedDate ?? 'N/A'),
                    _Field('Is Hold',
                        record.plannedEvent?.isHold?.toString() ?? 'N/A'),
                  ],
                ),
                if (record.additionalData != null &&
                    record.additionalData!.isNotEmpty)
                  _buildSection(
                    context,
                    title: 'Additional Details',
                    icon: Icons.details,
                    fields: record.additionalData!.entries
                        .map((e) => _Field(e.key, e.value.toString()))
                        .toList(),
                  ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 28, 136),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _navigateToPETasksScreen(context),
              child: const Text(
                'Tasks',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title,
      required IconData icon,
      required List<_Field> fields}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 6, 38, 84)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 6, 38, 84),
          ),
        ),
        children: fields.map((field) => _buildFieldRow(field)).toList(),
      ),
    );
  }

  Widget _buildFieldRow(_Field field) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              field.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              field.value,
              style: TextStyle(
                fontSize: 14,
                color: field.value == 'N/A' ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field {
  final String label;
  final String value;

  _Field(this.label, this.value);
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/RegularRecord.dart';
import 'PETaskScreen.dart'; // <-- import your PETaskScreen

class RegularRecordDetailsScreen extends StatelessWidget {
  final RegularRecord record;

  const RegularRecordDetailsScreen({super.key, required this.record});

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${record.peNumber}',
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
                    _Field('Province', record.province ?? 'N/A'),
                    _Field('Region', record.region ?? 'N/A'),
                    _Field('RTOM', record.rtom ?? 'N/A'),
                    _Field('RTOM Description', record.rtomDescription ?? 'N/A'),
                    _Field('Job Reference', record.jobReference ?? 'N/A'),
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
                  title: 'Task Information',
                  icon: Icons.task,
                  fields: [
                    _Field(
                        'Task Sequence', record.taskSeq?.toString() ?? 'N/A'),
                    _Field('Task Name', record.taskName ?? 'N/A'),
                    _Field('Task Workgroup', record.taskWg ?? 'N/A'),
                    _Field(
                        'Pending Task Name', record.pendingTaskName ?? 'N/A'),
                    _Field('Pending Workgroup', record.pendingWg ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Work Order Details',
                  icon: Icons.work,
                  fields: [
                    _Field('WO Actual Start Date',
                        record.woActualStartDate ?? 'N/A'),
                    _Field('WO Start Date', record.woStartDate ?? 'N/A'),
                    _Field('WO Status', record.woStatus ?? 'N/A'),
                    _Field('WO ID', record.woId ?? 'N/A'),
                    _Field('Request Reference No',
                        record.requestReferenceNo ?? 'N/A'),
                    _Field('Service Category', record.serviceCategory ?? 'N/A'),
                    _Field('Service Type', record.serviceType ?? 'N/A'),
                    _Field('Service Speed', record.serviceSpeed ?? 'N/A'),
                    _Field('Service Required Date',
                        record.serviceRequiredDate ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Service Order Details',
                  icon: Icons.receipt,
                  fields: [
                    _Field('SO Number', record.soNumber ?? 'N/A'),
                    _Field('SO ID', record.soId ?? 'N/A'),
                    _Field('SO Create Date', record.soCreateDate ?? 'N/A'),
                    _Field('Order Type', record.orderType ?? 'N/A'),
                    _Field('CRM Order', record.crmOrder ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Fiber Information',
                  icon: Icons.cable,
                  fields: [
                    _Field('Fiber PE No', record.fiberPeNo ?? 'N/A'),
                    _Field('Fiber SO ID', record.fiberSoId ?? 'N/A'),
                    _Field('Product SO ID', record.productSoId ?? 'N/A'),
                    _Field(
                        'Fiber PE Task Name', record.fiberPeTaskName ?? 'N/A'),
                    _Field('Fiber PE Task WG', record.fiberPeTaskWg ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Additional Details',
                  icon: Icons.details,
                  fields: [
                    _Field('Region 1', record.region1 ?? 'N/A'),
                    _Field('Province 1', record.province1 ?? 'N/A'),
                    _Field('RTOM 1', record.rtom1 ?? 'N/A'),
                    _Field('LEA', record.lea ?? 'N/A'),
                    _Field('CCT ID', record.cctId ?? 'N/A'),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Tasks Button added here
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

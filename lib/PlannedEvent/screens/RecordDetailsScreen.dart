import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/PERecord.dart';
import 'PETaskScreen.dart';

class RecordDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> record;
  final String searchCategory;

  const RecordDetailsScreen({
    super.key,
    required this.record,
    required this.searchCategory,
  });

  void _navigateToPETasksScreen(BuildContext context) {
    if (PERecord.fromJson(record).pENUMBER != null &&
        PERecord.fromJson(record).pENUMBER!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PETaskScreen(peNumber: PERecord.fromJson(record).pENUMBER!),
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
    final peRecord = PERecord.fromJson(record);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          peRecord.pENUMBER ?? 'Details',
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
                    _Field('ID', peRecord.id?.toString() ?? 'N/A'),
                    _Field('PE Number', peRecord.pENUMBER ?? 'N/A'),
                    _Field('Customer', peRecord.cUSTOMER ?? 'N/A'),
                    _Field(
                        'Contractor Name', peRecord.contractoR_NAME ?? 'N/A'),
                    _Field(
                        'Account Manager', peRecord.accounT_MANAGER ?? 'N/A'),
                    _Field('Section Handled By',
                        peRecord.sectioN_HANDLED_BY ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'PE Details',
                  icon: Icons.description,
                  fields: [
                    _Field('PE Activity', peRecord.pE_ACTIVITY ?? 'N/A'),
                    _Field('PE Nature', peRecord.pE_NATURE ?? 'N/A'),
                    _Field('PE Title', peRecord.pETITLE ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Location Information',
                  icon: Icons.location_on,
                  fields: [
                    _Field('Province', peRecord.province ?? 'N/A'),
                    _Field('Region', peRecord.region ?? 'N/A'),
                    _Field('RTOM', peRecord.rtom ?? 'N/A'),
                    _Field(
                        'RTOM Description', peRecord.rtoM_DESCRIPTION ?? 'N/A'),
                    _Field('Location A Address',
                        peRecord.locatioN_A_ADDRESS ?? 'N/A'),
                    _Field('Location B Address',
                        peRecord.locatioN_B_ADDRESS ?? 'N/A'),
                    _Field('LEA', peRecord.lea ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Service Information',
                  icon: Icons.build,
                  fields: [
                    _Field(
                        'Service Category', peRecord.servicE_CATEGORY ?? 'N/A'),
                    _Field('Service Type', peRecord.servicE_TYPE ?? 'N/A'),
                    _Field('Service Speed', peRecord.servicE_SPEED ?? 'N/A'),
                    _Field('Access Medium', peRecord.accesS_MEDIUM ?? 'N/A'),
                    _Field('Access Medium A End',
                        peRecord.accesS_MEDIUM_A_END ?? 'N/A'),
                    _Field('Access Medium B End',
                        peRecord.accesS_MEDIUM_B_END ?? 'N/A'),
                    _Field('NTU Type', peRecord.nTUTYPE ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Work Order Details',
                  icon: Icons.work,
                  fields: [
                    _Field('SO Number', peRecord.sONUMBER ?? 'N/A'),
                    _Field('SO ID', peRecord.sO_ID ?? 'N/A'),
                    _Field('WO ID', peRecord.wO_ID ?? 'N/A'),
                    _Field('WO Status', peRecord.wO_STATUS ?? 'N/A'),
                    _Field('WO Actual Start Date',
                        peRecord.wO_ACTUAL_START_DATE ?? 'N/A'),
                    _Field('WO Comments', peRecord.wO_COMMENTS ?? 'N/A'),
                    _Field('PE WO Comments', peRecord.pE_WO_COMMENTS ?? 'N/A'),
                  ],
                ),
                _buildSection(
                  context,
                  title: 'Additional Details',
                  icon: Icons.details,
                  fields: [
                    _Field('Order Type', peRecord.ordeR_TYPE ?? 'N/A'),
                    _Field('CRM Order', peRecord.crM_ORDER ?? 'N/A'),
                    _Field('Fiber PE Number', peRecord.fibeR_PE_NO ?? 'N/A'),
                  ],
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

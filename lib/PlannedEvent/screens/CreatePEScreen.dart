import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/PERecordService.dart';
import 'PEListScreen.dart';

class CreatePEScreen extends StatefulWidget {
  const CreatePEScreen({super.key});

  @override
  State<CreatePEScreen> createState() => _CreatePEScreenState();
}

class _CreatePEScreenState extends State<CreatePEScreen> {
  final _formKey = GlobalKey<FormState>();
  final PERecordService _service = PERecordService();
  bool _isSubmitting = false;

  // Controllers
  final _peNumberCtrl = TextEditingController();
  final _peTitleCtrl = TextEditingController();
  final _peActivityCtrl = TextEditingController();
  final _peNatureCtrl = TextEditingController();
  final _peObjectiveCtrl = TextEditingController();
  final _peAreaCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _rtomCtrl = TextEditingController();
  final _soNumberCtrl = TextEditingController();
  final _soIdCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _jobReferenceCtrl = TextEditingController();
  final _woIdCtrl = TextEditingController();
  final _taskNameCtrl = TextEditingController();
  final _taskWgCtrl = TextEditingController();
  final _contractorCtrl = TextEditingController();
  final _locationACtrl = TextEditingController();
  final _locationBCtrl = TextEditingController();
  final _woCommentsCtrl = TextEditingController();

  @override
  void dispose() {
    _peNumberCtrl.dispose();
    _peTitleCtrl.dispose();
    _peActivityCtrl.dispose();
    _peNatureCtrl.dispose();
    _peObjectiveCtrl.dispose();
    _peAreaCtrl.dispose();
    _provinceCtrl.dispose();
    _regionCtrl.dispose();
    _rtomCtrl.dispose();
    _soNumberCtrl.dispose();
    _soIdCtrl.dispose();
    _customerCtrl.dispose();
    _jobReferenceCtrl.dispose();
    _woIdCtrl.dispose();
    _taskNameCtrl.dispose();
    _taskWgCtrl.dispose();
    _contractorCtrl.dispose();
    _locationACtrl.dispose();
    _locationBCtrl.dispose();
    _woCommentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'peNumber': _peNumberCtrl.text.trim(),
      'peTitle': _peTitleCtrl.text.trim(),
      'peActivity': _peActivityCtrl.text.trim(),
      'peNature': _peNatureCtrl.text.trim(),
      'peObjective': _peObjectiveCtrl.text.trim(),
      'peArea': _peAreaCtrl.text.trim(),
      'province': _provinceCtrl.text.trim(),
      'region': _regionCtrl.text.trim(),
      'rtom': _rtomCtrl.text.trim(),
      'soNumber': _soNumberCtrl.text.trim(),
      'soId': _soIdCtrl.text.trim(),
      'customer': _customerCtrl.text.trim(),
      'jobReference': _jobReferenceCtrl.text.trim(),
      'woId': _woIdCtrl.text.trim(),
      'taskName': _taskNameCtrl.text.trim(),
      'taskWg': _taskWgCtrl.text.trim(),
      'contractorName': _contractorCtrl.text.trim(),
      'locationAAddress': _locationACtrl.text.trim(),
      'locationBAddress': _locationBCtrl.text.trim(),
      'woComments': _woCommentsCtrl.text.trim(),
    };

    final result = await _service.createPERecord(data);
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      // Show success dialog then go to PE List
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.green, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'PE Created Successfully!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'PE Number: ${_peNumberCtrl.text.trim()}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PEListScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 16, 37, 89),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.list_alt, color: Colors.white),
                  label: const Text('View PE List',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  // Reset form for another entry
                  _formKey.currentState?.reset();
                  _peNumberCtrl.clear();
                  _peTitleCtrl.clear();
                  _peActivityCtrl.clear();
                  _peNatureCtrl.clear();
                  _peObjectiveCtrl.clear();
                  _peAreaCtrl.clear();
                  _provinceCtrl.clear();
                  _regionCtrl.clear();
                  _rtomCtrl.clear();
                  _soNumberCtrl.clear();
                  _soIdCtrl.clear();
                  _customerCtrl.clear();
                  _jobReferenceCtrl.clear();
                  _woIdCtrl.clear();
                  _taskNameCtrl.clear();
                  _taskWgCtrl.clear();
                  _contractorCtrl.clear();
                  _locationACtrl.clear();
                  _locationBCtrl.clear();
                  _woCommentsCtrl.clear();
                },
                child: const Text('Create Another PE'),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to create PE record.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Create PE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save, color: Colors.white, size: 20),
            label: Text(
              _isSubmitting ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('PE Information', Icons.event_note),
              _buildField(
                controller: _peNumberCtrl,
                label: 'PE Number *',
                hint: 'e.g. PE-2024-001',
                required: true,
              ),
              _buildField(
                controller: _peTitleCtrl,
                label: 'PE Title *',
                hint: 'Enter PE title',
                required: true,
              ),
              _buildField(
                controller: _peActivityCtrl,
                label: 'PE Activity',
                hint: 'Enter PE activity',
              ),
              _buildField(
                controller: _peNatureCtrl,
                label: 'PE Nature',
                hint: 'e.g. New Installation',
              ),
              _buildField(
                controller: _peObjectiveCtrl,
                label: 'PE Objective',
                hint: 'Enter PE objective',
                maxLines: 2,
              ),
              _buildField(
                controller: _peAreaCtrl,
                label: 'PE Area',
                hint: 'Enter PE area',
              ),
              const SizedBox(height: 16),
              _sectionHeader('Location', Icons.location_on),
              _buildField(
                controller: _provinceCtrl,
                label: 'Province',
                hint: 'e.g. Western',
              ),
              _buildField(
                controller: _regionCtrl,
                label: 'Region',
                hint: 'Enter region',
              ),
              _buildField(
                controller: _rtomCtrl,
                label: 'RTOM',
                hint: 'Enter RTOM',
              ),
              _buildField(
                controller: _locationACtrl,
                label: 'Location A Address',
                hint: 'Enter location A',
                maxLines: 2,
              ),
              _buildField(
                controller: _locationBCtrl,
                label: 'Location B Address',
                hint: 'Enter location B',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _sectionHeader('Service Order', Icons.description),
              _buildField(
                controller: _soNumberCtrl,
                label: 'SO Number',
                hint: 'Enter SO number',
              ),
              _buildField(
                controller: _soIdCtrl,
                label: 'SO ID',
                hint: 'Enter SO ID',
              ),
              _buildField(
                controller: _jobReferenceCtrl,
                label: 'Job Reference',
                hint: 'Enter job reference',
              ),
              const SizedBox(height: 16),
              _sectionHeader('Work Order & Task', Icons.work),
              _buildField(
                controller: _woIdCtrl,
                label: 'WO ID',
                hint: 'Enter WO ID',
              ),
              _buildField(
                controller: _taskNameCtrl,
                label: 'Task Name',
                hint: 'Enter task name',
              ),
              _buildField(
                controller: _taskWgCtrl,
                label: 'Task WG',
                hint: 'Enter task workgroup',
              ),
              _buildField(
                controller: _woCommentsCtrl,
                label: 'WO Comments',
                hint: 'Enter work order comments',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _sectionHeader('Customer & Contractor', Icons.person),
              _buildField(
                controller: _customerCtrl,
                label: 'Customer',
                hint: 'Enter customer name',
              ),
              _buildField(
                controller: _contractorCtrl,
                label: 'Contractor',
                hint: 'Enter contractor name',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(226, 16, 37, 89),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'Creating...' : 'Create PE Record',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
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
            Icon(icon, color: Colors.white70, size: 16),
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
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
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
            borderSide: const BorderSide(
                color: Color.fromARGB(226, 16, 37, 89), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        validator: required
            ? (val) {
                if (val == null || val.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }
}

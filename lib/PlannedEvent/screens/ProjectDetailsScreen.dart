
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart'; // Added import for shimmer
import '../model/ProjectDetailsDto.dart';
import '../model/ProjectUserPermissionsDto.dart';
import '../service/ProjectService.dart';
import '../screens/DashboardHome.dart'; // Adjust based on actual path

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
  late Future<ProjectDetailsDto> _projectDetailsFuture;
  ProjectUserPermissionsDto? _permissions; // Added permissions variable
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _projectDetailsFuture = _service.fetchProjectDetails(widget.projectId).catchError((e) {
      setState(() {
        _errorMessage = 'Failed to load project details: $e';
      });
      return ProjectDetailsDto(id: 0, projectName: '', createdDate: DateTime.now(), projectPEs: []);
    });
    // Fetch permissions
    _service.fetchUserPermissions().then((permissions) {
      setState(() {
        _permissions = permissions;
      });
    }).catchError((e) {
      setState(() {
        _errorMessage = 'Failed to load permissions: $e';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName, style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 4, 24, 96),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ProjectDetailsDto>(
        future: _projectDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 4, 24, 96),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => DashboardHome(userId: widget.projectId)),
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
          } else if (!snapshot.hasData || snapshot.data!.projectPEs.isEmpty) {
            return Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No planned events found for this project',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 4, 24, 96),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final projectDetails = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectDetails.projectName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFieldRow('ID', projectDetails.id.toString()),
                      _buildFieldRow('Created', projectDetails.createdDate.toString()),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Planned Events',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...projectDetails.projectPEs.map((pe) => Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Expanded(
                              //   // child: Text(
                              //   //   //pe.plannedEvent.name,
                              //   //   style: GoogleFonts.poppins(
                              //   //     fontSize: 16,
                              //   //     fontWeight: FontWeight.bold,
                              //   //     color: Colors.black87,
                              //   //   ),
                              //   // ),
                              // ),
                              if (_permissions?.canManageProjects == true)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    try {
                                      final success = await _service.removePEFromProject(
                                          widget.projectId, pe.plannedEventId);
                                      if (success) {
                                        setState(() {
                                          _projectDetailsFuture = _service.fetchProjectDetails(widget.projectId);
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Planned event removed successfully',
                                                style: GoogleFonts.poppins()),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error removing planned event: $e',
                                              style: GoogleFonts.poppins()),
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildFieldRow('Event ID', pe.plannedEventId.toString()),
                          _buildFieldRow('Current Task', pe.currentTask ?? 'N/A'),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
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
}
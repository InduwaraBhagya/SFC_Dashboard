import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/PEIsseueModel.dart';

class PEService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));

  // PE Issues GET Endpoints
  Future<List<PEIssue>> getAllPEIssues() async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissues'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PEIssue.fromJson(json)).toList();
    }
    throw Exception('Failed to load all PE issues: ${response.statusCode}');
  }

  Future<PEIssue?> getPEIssue(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissues/$id'));
    if (response.statusCode == 200) {
      return PEIssue.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to load PE issue: ${response.statusCode}');
  }

  Future<List<PEIssue>> getInboxIssues(int userId, int limit) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissues/inbox/$userId?limit=$limit'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PEIssue.fromJson(json)).toList();
    }
    throw Exception('Failed to load inbox issues: ${response.statusCode}');
  }

  Future<List<PEIssue>> getReminders(int userId, bool showAll) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissues/reminders/$userId?showAll=$showAll'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PEIssue.fromJson(json)).toList();
    }
    throw Exception('Failed to load reminders: ${response.statusCode}');
  }

  Future<int> getReminderCount(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissues/reminders/$userId/count'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    }
    throw Exception('Failed to load reminder count: ${response.statusCode}');
  }

  Future<Map<int, List<PEIssue>>> getIssuesByPlannedEventIds(List<int> peIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/peissues/by-plannedevent-ids'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(peIds),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data.map((key, value) => MapEntry(int.parse(key), (value as List).map((json) => PEIssue.fromJson(json)).toList()));
    }
    throw Exception('Failed to load issues by planned event IDs: ${response.statusCode}');
  }

  Future<List<PEIssue>> getPEIssuesByPlannedEvent(int plannedEventId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissues/plannedevent/$plannedEventId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PEIssue.fromJson(json)).toList();
    }
    throw Exception('Failed to load PE issues by planned event: ${response.statusCode}');
  }

  // PE Issue Resolutions GET Endpoints
  Future<List<PEIssueResolution>> getAllPEIssueResolutions() async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissueresolutions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PEIssueResolution.fromJson(json)).toList();
    }
    throw Exception('Failed to load all PE issue resolutions: ${response.statusCode}');
  }

  Future<PEIssueResolution?> getPEIssueResolution(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissueresolutions/$id'));
    if (response.statusCode == 200) {
      return PEIssueResolution.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to load PE issue resolution: ${response.statusCode}');
  }

  Future<PEIssueResolution?> getPendingResolution(int issueId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissueresolutions/pending/$issueId'));
    if (response.statusCode == 200) {
      return PEIssueResolution.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to load pending resolution: ${response.statusCode}');
  }

 Future<Map<int, PEIssueResolution?>> getResolutionsByIssueIds(List<int> issueIds) async {
    if (issueIds.isEmpty) {
      return {}; // Return empty map if no valid IDs
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/peissueresolutions/by-issue-ids'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(issueIds),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(
              int.parse(key),
              value is Map<String, dynamic> ? PEIssueResolution.fromJson(value) : null,
            ));
      } else if (response.statusCode == 400) {
        print('API 400: Invalid issue IDs sent: $issueIds');
        return {};
      } else {
        print('API Error ${response.statusCode}: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Network error fetching resolutions: $e');
      return {};
    }
  }

  Future<PEIssueResolution?> getByIssueId(int issueId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/peissueresolutions/byissue/$issueId'));
    if (response.statusCode == 200) {
      return PEIssueResolution.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to load resolution by issue ID: ${response.statusCode}');
  }
}
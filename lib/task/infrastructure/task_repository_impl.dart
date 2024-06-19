// apiImpl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_concierge/config.dart';
import 'package:mobile_concierge/task/domain/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<dynamic> fetchInProgressTasks() async {
    final response = await _getNotionApi('task/inprogress/');
    return response['data'];
  }

  @override
  Future<dynamic> completeTask(String taskPageId) async {
    final response = await _postNotionApi('task/$taskPageId/complete/');
    return response['data'];
  }

  @override
  Future<dynamic> startTask(String taskPageId) async {
    final response = await _postNotionApi('task/$taskPageId/start/');
    return response['data'];
  }

  @override
  Future<List<dynamic>> fetchCurrentTasks() async {
    final response = await _getNotionApi('tasks/current');
    return response['data'];
  }

  Future<dynamic> _getNotionApi(String path) async {
    var response = await http.get(
      Uri.parse('$notionApiUrl/$path'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> _postNotionApi(String path) async {
    var response = await http.post(
      Uri.parse('$notionApiUrl/$path'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
    return jsonDecode(response.body);
  }
}

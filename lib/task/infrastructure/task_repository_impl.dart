// apiImpl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_concierge/config.dart';
import 'package:mobile_concierge/task/domain/task.dart';
import 'package:mobile_concierge/task/domain/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<InprogressTask?> fetchInProgressTasks() async {
    final response = await _getNotionApi('task/inprogress/');
    final dynamic data = response['data'];
    if (data == null || data['id'] == null) {
      return null;
    }
    return InprogressTask(data['id'], data['title'], data['text'],
        DateTime.parse(data['updated_at']));
  }

  @override
  Future<dynamic> completeTask(String taskPageId) async {
    final response = await _postNotionApi('task/$taskPageId/complete/');
    return response['data'];
  }

  @override
  Future<InprogressTask> startTask(String taskPageId) async {
    final response = await _postNotionApi('task/$taskPageId/start/');
    final dynamic data = response['data'];
    // 開始した場合は現時刻を開始時刻とする
    return InprogressTask(
        data['id'], data['title'], data['text'], DateTime.now());
  }

  @override
  Future<List<TodoTask>> fetchCurrentTasks() async {
    final response = await _getNotionApi('tasks/current');
    final List<dynamic> data = response['data'];
    return data
        .map((task) => TodoTask(
            task['id'], task['title'], task['text'], _convertToDate(task)))
        .toList();
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

  DateTime? _convertToDate(dynamic responseData) {
    if (responseData == null) {
      return null;
    }
    final pomodoroStartDatetime = responseData['pomodoro_start_datetime'];
    print(pomodoroStartDatetime);
    if (pomodoroStartDatetime != null && pomodoroStartDatetime != "") {
      // 2024-06-21T13:53:00+09:00 の形式をDateTimeに変換する
      return DateTime.parse(pomodoroStartDatetime);
    }
    return null;
  }
}

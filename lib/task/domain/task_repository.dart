import 'package:mobile_concierge/task/domain/task.dart';

abstract class TaskRepository {
  Future<InprogressTask?> fetchInProgressTasks();

  Future<dynamic> completeTask(String taskPageId);

  Future<InprogressTask> startTask(String taskPageId);

  Future<List<TodoTask>> fetchCurrentTasks();
}

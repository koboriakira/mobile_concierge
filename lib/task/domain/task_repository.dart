abstract class TaskRepository {
  Future<dynamic> fetchInProgressTasks();

  Future<dynamic> completeTask(String taskPageId);

  Future<dynamic> startTask(String taskPageId);

  Future<List<dynamic>> fetchCurrentTasks();
}

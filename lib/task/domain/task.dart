sealed class Task {
  const Task._(this.pageId, this.title, this.text, this.updatedAt);
  const factory Task.inprogress(
          String pageId, String title, String text, DateTime updatedAt) =
      InprogressTask;
  const factory Task.todo(
      String pageId, String title, String text, DateTime updatedAt) = TodoTask;

  final String pageId;
  final String title;
  final String text;
  final DateTime updatedAt;
}

/// 仕掛中タスク
class InprogressTask extends Task {
  const InprogressTask(super.pageId, super.title, super.text, super.updatedAt)
      : super._();
}

/// 未完了タスク
class TodoTask extends Task {
  const TodoTask(super.pageId, super.title, super.text, super.updatedAt)
      : super._();
}

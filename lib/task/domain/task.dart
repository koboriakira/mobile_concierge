sealed class Task {
  const Task._(this.pageId, this.title, this.text);
  const factory Task.inprogress(String pageId, String title, String text) =
      InprogressTask;
  const factory Task.todo(String pageId, String title, String text) = TodoTask;

  final String pageId;
  final String title;
  final String text;
}

/// 仕掛中タスク
class InprogressTask extends Task {
  const InprogressTask(super.pageId, super.title, super.text) : super._();
}

/// 未完了タスク
class TodoTask extends Task {
  const TodoTask(super.pageId, super.title, super.text) : super._();
}

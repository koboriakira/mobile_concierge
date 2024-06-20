import 'package:flutter/material.dart';

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

  TextStyle titleTextStyle() {
    if (title.length < 10) {
      return const TextStyle(fontSize: 64);
    } else if (title.length < 20) {
      return const TextStyle(fontSize: 48);
    } else {
      return const TextStyle(fontSize: 32);
    }
  }
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

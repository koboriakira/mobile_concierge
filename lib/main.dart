import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_concierge/task/domain/task_repository.dart';
import 'package:mobile_concierge/task/infrastructure/task_repository_impl.dart';
import 'config.dart'; // config.dartをインポートします。

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String pageId = 'a';
  String taskTitle = 'Loading...';
  String memoText = "";
  bool existsTask = false;
  List currentTasks = [];
  bool isApiExecuting = false;

  final TaskRepository _taskRepository = TaskRepositoryImpl();

  /// タスクの状態を最新の状態に更新します。
  Future<void> upToDate() async {
    final improgressTask = await _taskRepository.fetchInProgressTasks();

    if (existsTask) {
      // 仕掛中タスクが存在する場合
      setState(() {
        existsTask = true;
        pageId = improgressTask['id'];
        taskTitle = improgressTask['title'];
        memoText = improgressTask['text'];
      });
      return;
    }

    // 仕掛中タスクが存在しない場合
    final currentTasksResponse = await _taskRepository.fetchCurrentTasks();
    setState(() {
      pageId = "";
      taskTitle = "タスクなし";
      memoText = "";
      currentTasks = currentTasksResponse.sublist(0, 3);
    });
  }

  /// 仕掛中タスクを完了します。
  Future<void> completeTask() async {
    var _ = await _taskRepository.completeTask(pageId);
    setState(() {
      existsTask = false;
    });
    upToDate();
  }

  Future<void> startTask(String taskPageId) async {
    var startedTask = await _taskRepository.startTask(taskPageId);
    setState(() {
      existsTask = true;
      pageId = startedTask['id'];
      taskTitle = startedTask['title'];
      memoText = startedTask['text'];
    });
  }

  Widget inprogressTaskColumn() {
    return Column(
      children: <Widget>[
        Text(
          taskTitle,
          style: const TextStyle(fontSize: 60),
        ),
        const SizedBox(height: 20), // これはテキスト間のスペースを作るためです。
        Text(
          memoText,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: completeTask,
          child: const Text('Complete Task'),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // タスクの状態を最新の状態に更新
    upToDate();

    // タスクの状態を定期的に更新
    Timer.periodic(const Duration(seconds: duration), (Timer t) => upToDate());
  }

  Widget taskListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: currentTasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(currentTasks[index]['title']),
          trailing: ElevatedButton(
            child: const Text('開始する'),
            onPressed: () {
              startTask(currentTasks[index]['id']);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isApiExecuting ? const CircularProgressIndicator() : Container(),
              existsTask ? inprogressTaskColumn() : taskListView(),
            ],
          ),
        ),
      ),
    );
  }
}

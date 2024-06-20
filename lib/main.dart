import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_concierge/task/domain/task.dart';
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
  List<TodoTask> currentTasks = [];
  bool isApiExecuting = false;
  Duration elapsed = const Duration();
  Timer? timer;

  final TaskRepository _taskRepository = TaskRepositoryImpl();

  /// タスクの状態を最新の状態に更新します。
  Future<void> upToDate() async {
    final improgressTask = await _taskRepository.fetchInProgressTasks();
    if (improgressTask != null) {
      print("仕掛中タスクが存在する");
      setExistsTask(improgressTask);
      return;
    }
    print("仕掛中タスクが存在しない");

    // 仕掛中タスクが存在しない場合
    final currentTasksResponse = await _taskRepository.fetchCurrentTasks();
    setState(() {
      existsTask = false;
      pageId = "";
      taskTitle = "";
      memoText = "";
      currentTasks = currentTasksResponse.sublist(0, 3);
    });
  }

  void setExistsTask(Task task) {
    setState(() {
      existsTask = task is InprogressTask; // 仕掛中タスクが存在する場合
      pageId = task.pageId;
      taskTitle = task.title;
      memoText = task.text;
    });
  }

  /// 仕掛中タスクを完了します。
  Future<void> completeTask() async {
    var _ = await _taskRepository.completeTask(pageId);
    upToDate();
  }

  Future<void> startTask(String taskPageId) async {
    final inprogressTask = await _taskRepository.startTask(taskPageId);
    startTimer();
    setExistsTask(inprogressTask);
  }

  @override
  void initState() {
    super.initState();
    // タスクの状態を最新の状態に更新
    upToDate();

    // タスクの状態を定期的に更新
    Timer.periodic(const Duration(seconds: duration), (Timer t) => upToDate());

    startTimer();
  }

  void startTimer() {
    elapsed = const Duration();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        // 経過時間を更新
        elapsed = Duration(seconds: t.tick);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget inprogressTaskColumn() {
    String formattedTime =
        "${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    return Column(
      children: <Widget>[
        Text(
          formattedTime,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
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

  Widget taskListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: currentTasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(currentTasks[index].title),
          trailing: ElevatedButton(
            child: const Text('開始する'),
            onPressed: () {
              startTask(currentTasks[index].pageId);
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

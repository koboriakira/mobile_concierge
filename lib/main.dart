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
  InprogressTask? inprogressTask;
  List<TodoTask> currentTasks = [];
  bool isApiExecuting = false;
  Duration elapsed = const Duration();
  Timer? timer;

  final TaskRepository _taskRepository = TaskRepositoryImpl();

  /// タスクの状態を最新の状態に更新します。
  Future<void> upToDate() async {
    final improgressTask = await _taskRepository.fetchInProgressTasks();
    setInprogressTask(improgressTask);
    if (inprogressTask != null) {
      return;
    }

    // 仕掛中タスクが存在しない場合
    final currentTasksResponse = await _taskRepository.fetchCurrentTasks();
    setState(() {
      currentTasks = currentTasksResponse.sublist(0, 3);
    });
  }

  /// 仕掛中タスクを完了します。
  Future<void> completeTask() async {
    var _ = await _taskRepository.completeTask(inprogressTask!.pageId);
    upToDate();
  }

  Future<void> startTask(String taskPageId) async {
    final improgressTask = await _taskRepository.startTask(taskPageId);
    setInprogressTask(improgressTask);
  }

  void setInprogressTask(InprogressTask? task) {
    // タスクがnullの場合は、仕掛中タスクをクリアします。
    if (task == null) {
      setState(() {
        inprogressTask = null;
      });
      timer?.cancel();
      return;
    }

    if (task.pageId == inprogressTask?.pageId) {
      return;
    }
    setState(() {
      inprogressTask = task;
    });
    startTimer();
  }

  void startTimer() {
    elapsed = DateTime.now().difference(inprogressTask!.updatedAt);
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        // 経過時間を更新
        elapsed = Duration(seconds: elapsed.inSeconds + 1);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // タスクの状態を最新の状態に更新
    upToDate();

    // タスクの状態を定期的に更新
    Timer.periodic(const Duration(seconds: duration), (Timer t) => upToDate());
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
          inprogressTask!.title,
          style: inprogressTask!.titleTextStyle(),
        ),
        const SizedBox(height: 20), // これはテキスト間のスペースを作るためです。
        Text(
          inprogressTask!.text,
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
              inprogressTask != null ? inprogressTaskColumn() : taskListView(),
            ],
          ),
        ),
      ),
    );
  }
}

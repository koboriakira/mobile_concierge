import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_concierge/task/domain/task.dart';
import 'package:mobile_concierge/task/domain/task_repository.dart';
import 'package:mobile_concierge/task/infrastructure/task_repository_impl.dart';
import 'config.dart'; // config.dartをインポートします。

void main() {
  runApp(MaterialApp(
    title: 'Mobile Concierge',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: MyApp(),
  ));
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
    setState(() {
      isApiExecuting = true;
    });
    final improgressTask = await _taskRepository.fetchInProgressTasks();
    setInprogressTask(improgressTask);
    if (inprogressTask != null) {
      setState(() {
        isApiExecuting = false;
      });
      return;
    }

    // 仕掛中タスクが存在しない場合
    final currentTasksResponse = await _taskRepository.fetchCurrentTasks();
    setState(() {
      isApiExecuting = false;
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

      // 25分経過したらアラートを表示
      if (elapsed.inMinutes == 25 && elapsed.inSeconds == 0) {
        showAlert();
      }
    });
  }

  void showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('時間経過'),
          content: const Text('タスクの経過時間が25分を超えました。'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: completeTask,
          child: const Text('Complete Task'),
        ),
        const SizedBox(height: 20), // これはテキスト間のスペースを作るためです。
        Text(
          inprogressTask!.text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget taskListView() {
    return ListView(
      shrinkWrap: true,
      children: currentTasks.map((task) {
        return ListTile(
          title: Text(task.title),
          trailing: ElevatedButton(
            child: const Text('開始する'),
            onPressed: () {
              startTask(task.pageId);
            },
          ),
        );
      }).toList(),
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
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  inprogressTask != null
                      ? inprogressTaskColumn()
                      : taskListView(),
                ],
              ),
            ),
            if (isApiExecuting)
              Opacity(
                opacity: 0.5, // 透明度を設定
                child: Container(
                  color: Colors.black, // 背景色を設定
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

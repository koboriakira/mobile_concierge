import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<void> fetchImprogressTask() async {
    var response = await getNotionApi('task/inprogress');
    var improgressTask = response['data'];

    setState(() {
      existsTask = improgressTask != null;
    });

    if (existsTask) {
      setState(() {
        pageId = improgressTask['id'];
        taskTitle = improgressTask['title'];
        memoText = improgressTask['text'];
      });
      return;
    }

    fetchCurrentTasks();
  }

  Future<void> completeTask() async {
    var response = await postNotionApi('task/$pageId/complete/');
    var completedTask = response['data'];
    // print(completedTask)
    setState(() {
      existsTask = false;
    });
    fetchCurrentTasks();
  }

  Future<void> startTask(String taskPageId) async {
    var response = await postNotionApi('task/$taskPageId/start/');
    var startedTask = response['data'];
    // print(startedTask);
    setState(() {
      existsTask = true;
      pageId = startedTask['id'];
      taskTitle = startedTask['title'];
      memoText = startedTask['text'];
    });
  }

  Future<void> fetchCurrentTasks() async {
    var response = await getNotionApi('tasks/current');
    var currentTasksData = response['data'];

    setState(() {
      pageId = "";
      taskTitle = "タスクなし";
      memoText = "";
      currentTasks = currentTasksData.sublist(0, 3);
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

  Future<dynamic> getNotionApi(String path) async {
    setState(() {
      isApiExecuting = true;
    });
    var response = await http.get(
      Uri.parse('$notionApiUrl/$path/'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
    setState(() {
      isApiExecuting = false;
    });
    return jsonDecode(response.body);
  }

  Future<dynamic> postNotionApi(String path) async {
    setState(() {
      isApiExecuting = true;
    });
    var response = await http.post(
      Uri.parse('$notionApiUrl/$path'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
    setState(() {
      isApiExecuting = false;
    });
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();
    fetchImprogressTask();
    Timer.periodic(
        const Duration(seconds: duration), (Timer t) => fetchImprogressTask());
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

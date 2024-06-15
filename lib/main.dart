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

  Future<void> fetchImprogressTask() async {
    var response = await http.get(Uri.parse('$notionApiUrl/task/inprogress/'),
        headers: <String, String>{
          'access-token': notionSecret,
        });
    var responseBody = jsonDecode(response.body);
    var improgressTask = responseBody['data'];

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
    var response = await http.post(
      Uri.parse('$notionApiUrl/task/$pageId/complete/'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
    var responseBody = jsonDecode(response.body);
    var completedTask = responseBody['data'];
    // print(completedTask)

    setState(() {
      existsTask = false;
    });
    fetchCurrentTasks();
  }

  Future<void> startTask(String taskPageId) async {
    var response = await http.post(
      Uri.parse('$notionApiUrl/task/$taskPageId/start/'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
    var responseBody = jsonDecode(response.body);
    var startedTask = responseBody['data'];
    // print(startedTask);
    setState(() {
      existsTask = true;
      pageId = startedTask['id'];
      taskTitle = startedTask['title'];
      memoText = startedTask['text'];
    });
  }

  Future<void> fetchCurrentTasks() async {
    var currentTasksResponse = await http.get(
      Uri.parse('$notionApiUrl/tasks/current'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
    var currentTasksBody = jsonDecode(currentTasksResponse.body);
    var currentTasksData = currentTasksBody['data'];

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
              existsTask ? inprogressTaskColumn() : taskListView(),
            ],
          ),
        ),
      ),
    );
  }
}

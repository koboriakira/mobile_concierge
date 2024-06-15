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

  Future<void> fetchImprogressTask() async {
    var response = await http.get(Uri.parse('$notionApiUrl/task/inprogress/'),
        headers: <String, String>{
          'access-token': notionSecret,
        });
    var responseBody = jsonDecode(response.body);
    var data = responseBody['data'];
    var taskId = data != null ? data['id'] : "";
    var title = data != null ? data['title'] : "タスクなし";
    var text = data != null ? data['text'] : "";
    setState(() {
      existsTask = data != null;
      pageId = taskId;
      taskTitle = title;
      memoText = text;
    });
  }

  Future<void> callAnotherApi() async {
    var response = await http.post(
      Uri.parse('$notionApiUrl/task/$pageId/complete'),
      headers: <String, String>{
        'access-token': notionSecret,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchImprogressTask();
    Timer.periodic(
        const Duration(seconds: duration), (Timer t) => fetchImprogressTask());
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
                onPressed: callAnotherApi,
                child: const Text('Call Another API'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

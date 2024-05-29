import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const notionApiUrl =
    "https://6yhkmd3lcl.execute-api.ap-northeast-1.amazonaws.com/v1";
// const notionApiUrl = "http://localhost:10119";
const notionSecret = "dummy";

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
  String statusCode = 'Loading...';
  String memoText = "";

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 60), (Timer t) async {
      var response = await http.get(Uri.parse('$notionApiUrl/task/inprogress/'),
          headers: <String, String>{
            'access-token': notionSecret,
          });
      var responseBody = jsonDecode(response.body);
      var data = responseBody['data'];
      var taskId = data != null ? data['id'] : "";
      print(pageId);
      var title = data != null ? data['title'] : "タスクなし";
      var text = data != null ? data['text'] : "";
      setState(() {
        pageId = taskId;
        statusCode = title;
        memoText = text;
      });
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data from API'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                pageId,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 20),
              Text(
                statusCode,
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

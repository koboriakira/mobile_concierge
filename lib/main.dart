import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String statusCode = 'Loading...';
  String memoText = "";

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 60), (Timer t) async {
      var response = await http.get(
          // Uri.parse('http://localhost:10119/task/inprogress/'),
          Uri.parse(
              'https://6yhkmd3lcl.execute-api.ap-northeast-1.amazonaws.com/v1/task/inprogress/'),
          headers: <String, String>{
            'access-token': notionSecret,
          });
      var responseBody = jsonDecode(response.body);
      var data = responseBody['data'];
      // dataがnullでなければ、data.titleを取得する
      var title = data != null ? data['title'] : "タスクなし";
      var text = data != null ? data['text'] : "";
      setState(() {
        statusCode = title;
        memoText = text;
      });
    });
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
                statusCode,
                style: TextStyle(fontSize: 60),
              ),
              SizedBox(height: 20), // これはテキスト間のスペースを作るためです。
              Text(
                memoText,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

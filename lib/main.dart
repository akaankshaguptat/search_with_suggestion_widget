import 'package:flutter/material.dart';
import 'package:search/search_bar_with_suggestion.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> suggestionList = [
    'cat',
    'caa',
    'cab',
    'dog',
    'bird',
    'fish',
    'noo'
  ];
  String hintName = 'horse';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xffaca3a3),
        body: SafeArea(
          child: Search(
            suggestionList: suggestionList,
            hint: hintName,
          ),
        ),
      ),
    );
  }
}

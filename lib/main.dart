import 'package:flutter/material.dart';
import 'package:test_project/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Test Features'),
    );
  }
}

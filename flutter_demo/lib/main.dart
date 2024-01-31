import 'package:flutter/material.dart';
import 'package:flutter_demo/home_vmodel.dart';
import 'package:flutter_demo/kline_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }

  State createState() => _ExampleState();
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State createState() => _ExampleState();
}

class _ExampleState extends State<MyHomePage> {
  var vmodel = HomePageViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF131e30),
        appBar: AppBar(
          title: const Text('HomePage'),
        ),
        body: KlineView(
          dataList: vmodel.dataList,
        ));
  }
}

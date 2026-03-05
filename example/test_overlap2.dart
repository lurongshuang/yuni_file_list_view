import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TestPage(),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverMainAxisGroup(
            slivers: [
              SliverPinnedHeader(
                child: Container(
                  height: 50,
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  child: const Text("Group 1", style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ),
              SliverList(delegate: SliverChildBuilderDelegate((c, i) => ListTile(title: Text('1 - Item $i')), childCount: 20)),
            ],
          ),
          SliverMainAxisGroup(
            slivers: [
              SliverPinnedHeader(
                child: Container(
                  height: 50,
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  child: const Text("Group 2", style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ),
              SliverList(delegate: SliverChildBuilderDelegate((c, i) => ListTile(title: Text('2 - Item $i')), childCount: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

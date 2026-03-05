import 'package:flutter/material.dart';

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
              SliverPersistentHeader(
                pinned: true,
                delegate: MyHeader(color: Colors.red, title: "Group 1"),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (c, i) => ListTile(title: Text('1 - Item $i')),
                      childCount: 20)),
            ],
          ),
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: MyHeader(color: Colors.blue, title: "Group 2"),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (c, i) => ListTile(title: Text('2 - Item $i')),
                      childCount: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

class MyHeader extends SliverPersistentHeaderDelegate {
  final Color color;
  final String title;

  MyHeader({required this.color, required this.title});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(fontSize: 24, color: Colors.white)),
    );
  }

  @override
  double get maxExtent => 50;
  @override
  double get minExtent => 50;
  @override
  bool shouldRebuild(covariant MyHeader oldDelegate) => false;
}

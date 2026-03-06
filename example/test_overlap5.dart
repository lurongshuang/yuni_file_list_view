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
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Z-Index Test'),
            ),
          ),
          ...List.generate(3, (gi) {
            return SliverMainAxisGroup(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                      color: gi == 0
                          ? Colors.red
                          : (gi == 1 ? Colors.blue : Colors.green),
                      title: 'Group $gi'),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (c, i) => ListTile(title: Text('Group $gi - Item $i')),
                        childCount: 20)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Color color;
  final String title;
  const _StickyHeaderDelegate({required this.color, required this.title});

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
  bool shouldRebuild(covariant _StickyHeaderDelegate old) => false;
}

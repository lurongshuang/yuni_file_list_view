import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: List.generate(1000, (index) {
             return SliverStickyHeader(
               header: Container(
                 height: 50.0,
                 color: Colors.lightBlue,
                 padding: EdgeInsets.symmetric(horizontal: 16.0),
                 alignment: Alignment.centerLeft,
                 child: Text('Header #$index',
                   style: const TextStyle(color: Colors.white),
                 ),
               ),
               sliver: SliverList(
                 delegate: SliverChildBuilderDelegate(
                   (context, i) => ListTile(
                     leading: CircleAvatar(child: Text('0')),
                     title: Text('List tile #$i'),
                   ),
                   childCount: 4,
                 ),
               ),
             );
          }),
        ),
      ),
    );
  }
}

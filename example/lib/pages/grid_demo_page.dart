import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../data/demo_data.dart';

class GridDemoPage extends StatefulWidget {
  const GridDemoPage({super.key});

  @override
  State<GridDemoPage> createState() => _GridDemoPageState();
}

class _GridDemoPageState extends State<GridDemoPage> {
  bool _autoColumn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宫格列表'),
        actions: [
          Row(
            children: [
              Text(_autoColumn ? '自适应宽(90px)' : '固定3列', style: const TextStyle(fontSize: 12)),
              Switch(
                value: _autoColumn,
                onChanged: (v) => setState(() => _autoColumn = v),
              ),
            ],
          )
        ],
      ),
      body: YFileGridView<YFileItem>(
        items: DemoData.gridItems,
        config: YFileGridConfig(
          crossAxisCount: _autoColumn ? 0 : 3, // 0 表示自动计算
          minItemWidth: 90,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        onTap: (item, i) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击：${item.name}'), duration: const Duration(seconds: 1)),
          );
        },
      ),
    );
  }
}

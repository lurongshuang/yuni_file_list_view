import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../widgets/y_file_grid_item.dart';
import '../data/demo_data.dart';

class GroupedDemoPage extends StatelessWidget {
  const GroupedDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('粘性分组列表')),
      body: YFileGroupedListView<YFileItem>(
        groups: DemoData.groupedItems,
        config: YFileGroupedConfig(
          gridConfig: const YFileGridConfig(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
        ),
        headerBuilder: (context, group, index) => Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          color: Colors.grey.shade100,
          child: Text(group.groupTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        itemBuilder: (context, group, item, gi, index) => YFileGridItem(
          item: item,
          onTap: () {},
        ),
      ),
    );
  }
}

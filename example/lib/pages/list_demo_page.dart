import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../data/demo_data.dart';

class ListDemoPage extends StatefulWidget {
  const ListDemoPage({super.key});

  @override
  State<ListDemoPage> createState() => _ListDemoPageState();
}

class _ListDemoPageState extends State<ListDemoPage> {
  final Set<String> selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('纵向列表 (已选 ${selectedIds.length})'),
        actions: [
          TextButton(
            onPressed: () => setState(() => selectedIds.clear()),
            child: const Text('清空', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: YFileListView<YFileItem>(
        items: DemoData.listItems,
        config: const YFileListConfig(
          showCheckbox: true,
          thumbnailSize: 56,
          showDivider: true,
        ),
        selectedIds: selectedIds,
        onSelect: (item, selected) {
          setState(() {
            if (selected) {
              selectedIds.add(item.id);
            } else {
              selectedIds.remove(item.id);
            }
          });
        },
        onTap: (item, i) {
          // 单击时也可以切换选中状态
          setState(() {
            if (selectedIds.contains(item.id)) {
              selectedIds.remove(item.id);
            } else {
              selectedIds.add(item.id);
            }
          });
        },
      ),
    );
  }
}

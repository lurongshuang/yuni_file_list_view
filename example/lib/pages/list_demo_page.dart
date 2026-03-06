import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../widgets/y_file_list_item.dart';
import '../models/y_file_list_ui_config.dart';
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
        config: const YFileListConfig(),
        itemBuilder: (context, item, index) {
          final isSelected = selectedIds.contains(item.id);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YFileListItem(
                item: item,
                config: const YFileListUIConfig(showCheckbox: true, thumbnailSize: 56),
                selected: isSelected,
                onTap: () {
                  setState(() {
                    if (selectedIds.contains(item.id)) {
                      selectedIds.remove(item.id);
                    } else {
                      selectedIds.add(item.id);
                    }
                  });
                },
                onCheckChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedIds.add(item.id);
                    } else {
                      selectedIds.remove(item.id);
                    }
                  });
                },
              ),
              const Divider(height: 1, indent: 72, endIndent: 0, thickness: 0.5),
            ],
          );
        },
      ),
    );
  }
}

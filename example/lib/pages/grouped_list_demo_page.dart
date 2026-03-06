import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../widgets/y_file_list_item.dart';
import '../models/y_file_list_ui_config.dart';
import '../data/demo_data.dart';

class GroupedListDemoPage extends StatelessWidget {
  const GroupedListDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('粘性分组列表 (纵向样式)')),
      body: YFileGroupedListView<YFileItem>(
        groups: DemoData.groupedItems,
        config: const YFileGroupedConfig(
          mode: YFileGroupedMode.list,
          pinnedHeader: true, // 核心属性：Header 粘性吸顶
        ),
        headerBuilder: (context, group, index) {
          return Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: Colors.grey.shade100,
            child: Text(
              group.groupTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          );
        },
        itemBuilder: (context, group, item, gi, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YFileListItem(
                item: item,
                config: const YFileListUIConfig(showDivider: true),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('查看文件：${item.name}'),
                        duration: const Duration(seconds: 1)),
                  );
                },
              ),
              const Divider(
                  height: 1, indent: 72, endIndent: 0, thickness: 0.5),
            ],
          );
        },
      ),
    );
  }
}

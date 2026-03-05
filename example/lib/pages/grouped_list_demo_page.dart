import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../data/demo_data.dart';

class GroupedListDemoPage extends StatelessWidget {
  const GroupedListDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('粘性分组列表 (纵向样式)')),
      body: YFileGroupedListView<YFileItem>(
        groups: DemoData.groupedItems,
        config: YFileGroupedConfig(
          mode: YFileGroupedMode.list,
          listConfig: const YFileListConfig(
             showDivider: true,
             dividerIndent: 72,
          ),
          headerHeight: 46,
          pinnedHeader: true, // 核心属性：Header 粘性吸顶
          headerBackgroundColor: Colors.grey.shade100,
        ),
        onTap: (item, i) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('查看文件：${item.name}'), duration: const Duration(seconds: 1)),
          );
        },
      ),
    );
  }
}

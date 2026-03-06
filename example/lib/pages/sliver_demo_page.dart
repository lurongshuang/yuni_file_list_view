import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../widgets/y_file_list_item.dart';
import '../widgets/y_file_grid_item.dart';
import '../models/y_file_list_ui_config.dart';
import '../data/demo_data.dart';

class SliverDemoPage extends StatelessWidget {
  const SliverDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Sliver 混合滚动'),
              background: Image.network(
                'https://picsum.photos/seed/header/800/400',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '1. 宫格样式分组 (Grid Mode)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // 展开返回的包裹分组的 MultiSliver 列表
          ...buildSliverYFileGroupedListView<YFileItem>(
            groups: DemoData.groupedItems.take(2).toList(),
            config: YFileGroupedConfig(
              pinnedHeader: true,
              gridConfig: const YFileGridConfig(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
            ),
            headerBuilder: (context, group, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              color: Colors.white,
              child: Text(group.groupTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            itemBuilder: (context, group, item, gi, index) => YFileGridItem(item: item),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Text(
                '2. 纵向明细样式分组 (List Mode)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...buildSliverYFileGroupedListView<YFileItem>(
            groups: DemoData.groupedItems.skip(2).toList(),
            config: const YFileGroupedConfig(
              mode: YFileGroupedMode.list,
              pinnedHeader: true,
            ),
            headerBuilder: (context, group, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              color: Colors.grey.shade50,
              child: Text(group.groupTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            itemBuilder: (context, group, item, gi, index) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                YFileListItem(
                  item: item,
                  config: const YFileListUIConfig(showDivider: true),
                ),
                const Divider(height: 1, indent: 72, endIndent: 0, thickness: 0.5),
              ],
            ),
          ),
          // 底部留白
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

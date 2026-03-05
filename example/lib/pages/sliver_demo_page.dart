import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
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
            config: YFileGroupedConfig(
              mode: YFileGroupedMode.list,
              pinnedHeader: true,
              listConfig: const YFileListConfig(showDivider: true),
              headerBackgroundColor: Colors.grey.shade50,
            ),
          ),
          // 底部留白
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

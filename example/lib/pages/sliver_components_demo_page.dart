import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../widgets/y_file_grid_item.dart';
import '../data/demo_data.dart';

class SliverComponentsDemoPage extends StatelessWidget {
  const SliverComponentsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliver 原子组件演示'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Sliver 组件演示'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade400, Colors.blue.shade800],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.layers, size: 48, color: Colors.white54),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '1. SliverYFileGridView 独立使用',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '在 CustomScrollView 中直接使用 SliverYFileGridView，支持自适应列数计算',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomScrollView(
                    slivers: [
                      SliverYFileGridView<YFileItem>(
                        items: DemoData.gridItems,
                        availableWidth: constraints.maxWidth,
                        config: const YFileGridConfig(
                          crossAxisCount: 0,
                          minItemWidth: 80,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          padding: EdgeInsets.all(4),
                        ),
                        itemBuilder: (context, item, index) {
                          return YFileGridItem(item: item);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '2. SliverYFileListView 独立使用',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '在 CustomScrollView 中直接使用 SliverYFileListView，支持自定义分割线',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
          SliverYFileListView<YFileItem>(
            items: DemoData.listItems.take(5).toList(),
            config: const YFileListConfig(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemExtent: 64,
            ),
            separatorBuilder: (context, index) {
              return Container(
                height: 1,
                margin: const EdgeInsets.only(left: 64),
                color: Colors.grey.shade300,
              );
            },
            itemBuilder: (context, item, index) {
              return SizedBox(
                height: 64,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.insert_drive_file, color: Colors.blue.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${((item.fileSize ?? 0) / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '3. SliverYFileGridView 固定列数',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '固定 4 列，自定义间距和宽高比',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomScrollView(
                    slivers: [
                      SliverYFileGridView<YFileItem>(
                        items: DemoData.gridItems,
                        availableWidth: constraints.maxWidth,
                        config: const YFileGridConfig(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.75,
                          padding: EdgeInsets.all(8),
                        ),
                        itemBuilder: (context, item, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.primaries[index % Colors.primaries.length].shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 32,
                                  color: Colors.primaries[index % Colors.primaries.length],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '4. 自动列数限制 (minColumns / maxColumns)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '自动计算列数，但限制最少 2 列，最多 6 列',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomScrollView(
                    slivers: [
                      SliverYFileGridView<YFileItem>(
                        items: DemoData.gridItems,
                        availableWidth: constraints.maxWidth,
                        config: const YFileGridConfig(
                          crossAxisCount: 0,
                          minItemWidth: 60,
                          minColumns: 2,
                          maxColumns: 6,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          padding: EdgeInsets.all(4),
                        ),
                        itemBuilder: (context, item, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '5. 混合使用多个 Sliver 组件',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '在一个 CustomScrollView 中组合使用多个 SliverYFileGridView',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '图片',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SliverYFileGridView<YFileItem>(
                        items: DemoData.gridItems.take(4).toList(),
                        availableWidth: constraints.maxWidth,
                        config: const YFileGridConfig(
                          crossAxisCount: 0,
                          minItemWidth: 80,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          padding: EdgeInsets.all(4),
                        ),
                        itemBuilder: (context, item, index) {
                          return Container(
                            color: Colors.blue.shade50,
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.blue),
                            ),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '文档',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SliverYFileGridView<YFileItem>(
                        items: DemoData.gridItems.skip(4).take(4).toList(),
                        availableWidth: constraints.maxWidth,
                        config: const YFileGridConfig(
                          crossAxisCount: 0,
                          minItemWidth: 80,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          padding: EdgeInsets.all(4),
                        ),
                        itemBuilder: (context, item, index) {
                          return Container(
                            color: Colors.green.shade50,
                            child: const Center(
                              child: Icon(Icons.description, color: Colors.green),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

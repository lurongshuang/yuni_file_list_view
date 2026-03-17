import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../widgets/y_file_list_item.dart';
import '../widgets/y_file_grid_item.dart';
import '../data/demo_data.dart';

class MultiDimensionDemoPage extends StatefulWidget {
  const MultiDimensionDemoPage({super.key});

  @override
  State<MultiDimensionDemoPage> createState() => _MultiDimensionDemoPageState();
}

class _MultiDimensionDemoPageState extends State<MultiDimensionDemoPage> {
  YFileGroupedMode _mode = YFileGroupedMode.grid;
  int _itemsPerGroup = 4;
  int _groupCount = 10;
  List<YFileGroup<YFileItem>> _groups = [];

  @override
  void initState() {
    super.initState();
    _generateData();
  }

  void _generateData() {
    final List<YFileGroup<YFileItem>> newGroups = [];
    final allItems = DemoData.gridItems;

    for (int i = 0; i < _groupCount; i++) {
      final startIndex = (i * _itemsPerGroup) % allItems.length;
      final count = _itemsPerGroup;
      final items = <YFileItem>[];
      for (int j = 0; j < count; j++) {
        items.add(allItems[(startIndex + j) % allItems.length]);
      }

      newGroups.add(YFileGroup(
        groupId: 'group_$i',
        groupTitle: '分组 $i (${items.length} 个项目)',
        items: items,
      ));
    }
    setState(() {
      _groups = newGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildControlPanel(),
          SliverYFileGroupedList<YFileItem>(
            groups: _groups,
            config: YFileGroupedConfig(
              mode: _mode,
              pinnedHeader: true,
              groupHeaderHeight: 50,
              gridConfig: const YFileGridConfig(
                padding: EdgeInsets.all(12),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                minItemWidth: 100,
              ),
              listConfig: const YFileListConfig(
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            headerBuilder: (context, group, index) {
              return _buildPremiumHeader(group.groupTitle);
            },
            itemBuilder: (context, group, item, gi, index) {
              if (_mode == YFileGroupedMode.grid) {
                return YFileGridItem(item: item);
              } else {
                return YFileListItem(item: item);
              }
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          '多维度 premium 演示',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 50, bottom: 16),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('调试控制台',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('展示模式: '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('宫格'),
                  selected: _mode == YFileGroupedMode.grid,
                  onSelected: (val) =>
                      setState(() => _mode = YFileGroupedMode.grid),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('列表'),
                  selected: _mode == YFileGroupedMode.list,
                  onSelected: (val) =>
                      setState(() => _mode = YFileGroupedMode.list),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('每组项目数: $_itemsPerGroup'),
                Expanded(
                  child: Slider(
                    value: _itemsPerGroup.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    onChanged: (val) {
                      setState(() => _itemsPerGroup = val.toInt());
                      _generateData();
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('分组总数: $_groupCount'),
                Expanded(
                  child: Slider(
                    value: _groupCount.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    onChanged: (val) {
                      setState(() => _groupCount = val.toInt());
                      _generateData();
                    },
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _generateData,
              icon: const Icon(Icons.refresh),
              label: const Text('强制刷新数据源'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(String title) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

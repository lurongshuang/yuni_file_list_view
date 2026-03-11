import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../data/demo_data.dart';

/// YRulerScrollbar 组件演示页面
///
/// 演示三种用法：
/// 1. 最简用法（仅 Thumb，无节点）
/// 2. 带年份刻度节点（可点击跳转）
/// 3. 完整版：带主/辅节点、拖拽显示日期提示（自定义 hintBuilder）
class ScrollbarDemoPage extends StatefulWidget {
  const ScrollbarDemoPage({super.key});

  @override
  State<ScrollbarDemoPage> createState() => _ScrollbarDemoPageState();
}

class _ScrollbarDemoPageState extends State<ScrollbarDemoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YRulerScrollbar 演示'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '简单模式'),
            Tab(text: '节点刻度'),
            Tab(text: '完整演示'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _SimpleScrollbarDemo(),
            _NodeScrollbarDemo(),
            _FullScrollbarDemo(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1: 最简用法（纯 Thumb）
// ─────────────────────────────────────────────────────────────────────────────

class _SimpleScrollbarDemo extends StatefulWidget {
  const _SimpleScrollbarDemo();

  @override
  State<_SimpleScrollbarDemo> createState() => __SimpleScrollbarDemoState();
}

class __SimpleScrollbarDemoState extends State<_SimpleScrollbarDemo> {
  final ScrollController _ctrl = ScrollController();
  late final List<YFileItem> _items;

  @override
  void initState() {
    super.initState();
    // 模拟从接口获取真实的普通长列表数据
    _items = DemoData.listItems;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YRulerScrollbar(
      controller: _ctrl,
      style: YRulerScrollbarStyle(
          thumbColor: Colors.indigo.withValues(alpha: 0.5),
          thumbDraggingColor: Colors.indigo,
          thumbWidth: 5,
          thumbMinHeight: 32,
          showTrack: true,
          trackColor: Colors.transparent,
          trackBorderColor: Colors.transparent),
      showHintOnDrag: false,
      child: ListView.builder(
        controller: _ctrl,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        itemCount: _items.length,
        itemExtent: 80,
        // 指定固定高度，避免快滑卡顿
        itemBuilder: (_, i) {
          final item = _items[i];
          return Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
            ),
            child: ListTile(
              leading: leadingIcon(item),
              title:
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '大小: ${item.fileSize ?? 0} B \n修改时间: ${item.modifiedAt?.toString().substring(0, 16) ?? ''}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget leadingIcon(YFileItem item) {
    if (item.type == YFileType.image && item.thumbnailUrl != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.indigo.withValues(alpha: 0.1),
        ),
        child: const Icon(Icons.image, color: Colors.indigo),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.indigo.withValues(alpha: 0.12),
      child:
          const Icon(Icons.insert_drive_file, color: Colors.indigo, size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2: 带年份节点刻度，可点击精准跳转
// ─────────────────────────────────────────────────────────────────────────────

class _NodeScrollbarDemo extends StatefulWidget {
  const _NodeScrollbarDemo();

  @override
  State<_NodeScrollbarDemo> createState() => __NodeScrollbarDemoState();
}

class __NodeScrollbarDemoState extends State<_NodeScrollbarDemo> {
  final ScrollController _ctrl = ScrollController();
  static const double _itemExtent = 56.0;

  // 模拟业务数据：原本为二级列表的数据，现在需要在平铺列表中展示，但复用该分组实体做节点
  late final List<YFileGroup<YFileItem>> _yearNodes;
  late final List<YFileItem> _flatItems;

  @override
  void initState() {
    super.initState();
    // 从数据中心按年获取分组数据
    _yearNodes = DemoData.getGroupsByDimension('year');
    // 展平为一维列表用于 ListView.builder 渲染
    _flatItems = _yearNodes.expand((g) => g.items).toList();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YRulerScrollbar(
      controller: _ctrl,
      // 真实业务中直接把原有的 Group 列表传入当成刻度节点！
      nodes: _yearNodes,
      extentRatioBuilder: (node, index) {
        // 由于是平铺列表，我们需要累加计算该年份第一条数据的绝对 Index，算出在大列表中的总进度！
        int absoluteIndex = 0;
        for (int i = 0; i < index; i++) {
          absoluteIndex += _yearNodes[i].count;
        }
        return absoluteIndex / _flatItems.length;
      },
      style: YRulerScrollbarStyle(
        thumbColor: Colors.teal.withValues(alpha: 0.5),
        thumbDraggingColor: Colors.teal,
        thumbWidth: 4,
        thumbMinHeight: 28,
        showTrack: true,
        trackColor: Colors.grey.withValues(alpha: 0.06),
        trackBorderColor: Colors.grey.withValues(alpha: 0.15),
        tickColor: Colors.teal.withValues(alpha: 0.5),
        majorTickLength: 16,
        tickStrokeWidth: 1.5,
        labelStyle: TextStyle(
          fontSize: 11,
          color: Colors.teal.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: ListView.builder(
        controller: _ctrl,
        itemCount: _flatItems.length,
        itemExtent: _itemExtent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (_, i) {
          final item = _flatItems[i];
          final date = item.modifiedAt;
          final yearStr = date != null ? '${date.year}' : '';

          return ListTile(
            leading: Icon(
                item.type == YFileType.video
                    ? Icons.video_camera_back_outlined
                    : Icons.image_outlined,
                color: Colors.teal.withValues(alpha: 0.7)),
            title:
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('文件大小: ${item.fileSize ?? 0} B'),
            trailing: Text(yearStr,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3: 完整演示（主+辅节点、自定义拖拽提示）
// ─────────────────────────────────────────────────────────────────────────────

class _FullScrollbarDemo extends StatefulWidget {
  const _FullScrollbarDemo();

  @override
  State<_FullScrollbarDemo> createState() => __FullScrollbarDemoState();
}

class __FullScrollbarDemoState extends State<_FullScrollbarDemo> {
  final ScrollController _ctrl = ScrollController();

  // 获取演示环境的真实二级列表数据 (如按月分组的照片列表)
  late final List<YFileGroup<YFileItem>> _months;
  late final int _totalItems;

  @override
  void initState() {
    super.initState();
    _months =
        DemoData.getGroupsByDimension('month', items: DemoData.gridItems2);
    _totalItems = _months.fold<int>(0, (sum, g) => sum + g.count);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YRulerScrollbar(
      controller: _ctrl,
      // 直接把真实的业务模型列表 _months 当做 nodes 传给组件
      // 因为 YFileGroup 已经在核心代码里实现了 YRulerScrollbarNode 接口
      nodes: _months,
      extentRatioBuilder: (node, index) {
        // 由于需要计算该组从头开始的绝对位置索引，方便的话也可以在业务构建时给 Group 带上 index 属性，
        // 或者如本例：直接累加之前组的个数除以总数。这完全由业务方自由决定！
        int absoluteIndex = 0;
        for (int i = 0; i < index; i++) {
          absoluteIndex += _months[i].count;
        }
        return absoluteIndex / _totalItems;
      },
      showHintOnDrag: true,
      hintBuilder: (context, node, offset) {
        if (node == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(-2, 4),
              )
            ],
          ),
          child: Text(
            node.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        );
      },
      nodeLabelBuilder: (context, node, index) {
        if (!node.isMajor) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.08),
          ),
          child: Text(
            node.label.substring(0, 4), // 我们仅用年份演示自定义效果
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        );
      },
      style: YRulerScrollbarStyle(
        thumbColor: Colors.deepPurple.withValues(alpha: 0.45),
        thumbDraggingColor: Colors.deepPurple,
        thumbWidth: 4,
        thumbMinHeight: 24,
        showTrack: true,
        trackColor: Colors.grey.withValues(alpha: 0.06),
        trackBorderColor: Colors.grey.withValues(alpha: 0.15),
        tickColor: Colors.deepPurple.withValues(alpha: 0.4),
        majorTickLength: 16,
        minorTickLength: 8,
        tickStrokeWidth: 1.0,
        labelStyle: TextStyle(
          fontSize: 10,
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: CustomScrollView(
        controller: _ctrl,
        slivers: [
          SliverYFileGroupedList<YFileItem>(
            groups: _months,
            config: const YFileGroupedConfig(
              mode: YFileGroupedMode.list,
              pinnedHeader: true,
              groupHeaderHeight: 44,
            ),
            headerBuilder: (context, group, groupIndex) {
              return Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                color: Colors.grey.shade50,
                child: Text(
                  group.groupTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              );
            },
            itemBuilder: (context, group, item, groupIndex, itemIndex) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                      item.type == YFileType.video
                          ? Icons.video_file_outlined
                          : Icons.photo_outlined,
                      color: Colors.deepPurple.withValues(alpha: 0.6),
                      size: 22),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('文件大小: ${item.fileSize ?? 0} B',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

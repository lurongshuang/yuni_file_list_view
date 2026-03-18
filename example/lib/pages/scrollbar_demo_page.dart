import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: '节点分离'),
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
            _DivergedNodeScrollbarDemo(),
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

  bool _thumbVisibility = false;
  double _fadeInMs = 100;
  double _fadeOutMs = 300;
  double _timeToFadeMs = 600;
  double _hitTestWidth = 20.0;
  double _trackWidth = 5.0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('始终显示滑块 (thumbVisibility)'),
          subtitle: const Text('开启后滑块不再自动淡出'),
          value: _thumbVisibility,
          onChanged: (v) => setState(() => _thumbVisibility = v),
        ),
        if (!_thumbVisibility) ...[
          _buildSlider('淡入时长 (ms)', _fadeInMs, 0, 1000,
              (v) => setState(() => _fadeInMs = v)),
          _buildSlider('淡出时长 (ms)', _fadeOutMs, 0, 2000,
              (v) => setState(() => _fadeOutMs = v)),
          _buildSlider('隐藏延迟 (ms)', _timeToFadeMs, 0, 3000,
              (v) => setState(() => _timeToFadeMs = v)),
        ],
        _buildSlider('热区宽度 (dp)', _hitTestWidth, 0, 100,
            (v) => setState(() => _hitTestWidth = v)),
        _buildSlider('轨道宽度 (dp)', _trackWidth, 0, 100,
            (v) => setState(() => _trackWidth = v)),
        Expanded(
          child: YRulerScrollbar(
            controller: _ctrl,
            thumbVisibility: _thumbVisibility,
            fadeInDuration: Duration(milliseconds: _fadeInMs.toInt()),
            fadeOutDuration: Duration(milliseconds: _fadeOutMs.toInt()),
            timeToFade: Duration(milliseconds: _timeToFadeMs.toInt()),
            style: YRulerScrollbarStyle(
                thumbColor: Colors.indigo.withValues(alpha: 0.5),
                thumbDraggingColor: Colors.indigo,
                thumbWidth: 5,
                thumbMinHeight: 32,
                showTrack: true,
                trackColor: Colors.black.withValues(alpha: 0.1),
                trackBorderColor: Colors.transparent,
                hitTestWidth: _hitTestWidth,
                trackWidth: _trackWidth,
                hitTestBackgroundColor: Colors.red.withValues(alpha: 0.1)),
            showHintOnDrag: true,
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
                    border: Border(
                        bottom: BorderSide(color: Colors.black12, width: 0.5)),
                  ),
                  child: ListTile(
                    leading: leadingIcon(item),
                    title: Text(item.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '大小: ${item.fileSize ?? 0} B \n修改时间: ${item.modifiedAt?.toString().substring(0, 16) ?? ''}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ),
      ],
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

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Text('${value.toInt()}ms', style: const TextStyle(fontSize: 12)),
        ],
      ),
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
      scrollOffsetBuilder: (node, index) {
        int absoluteIndex = 0;
        for (int i = 0; i < index; i++) {
          absoluteIndex += _yearNodes[i].count;
        }
        return absoluteIndex * _itemExtent;
      },
      style: YRulerScrollbarStyle(
        thumbColor: Colors.teal.withValues(alpha: 0.5),
        thumbDraggingColor: Colors.teal,
        thumbWidth: 4,
        thumbMinHeight: 28,
        showTrack: true,
        trackWidth: 20,
        hitTestWidth: 20,
        hitTestBackgroundColor: Colors.red.withValues(alpha: 0.2),
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

  late final List<YFileGroup<YFileItem>> _months;

  @override
  void initState() {
    super.initState();
    _months =
        DemoData.getGroupsByDimension('month', items: DemoData.gridItems2);
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
      scrollOffsetBuilder: (node, index) {
        int absoluteIndex = 0;
        for (int i = 0; i < index; i++) {
          absoluteIndex += _months[i].count;
        }
        // 列表模式下高度 = 之前组的 items * 72 + 之前组的 headers * 44
        return (absoluteIndex * 72) + (index * 44);
      },
      onHintChanged: (node) {
        // 🔥 交互升级：当提示文本切换时切换触发触感反馈
        if (node != null) {
          HapticFeedback.lightImpact();
          debugPrint('Scrollbar node changed to: ${node.label}');
        }
      },
      onInteraction: (state, offset) {
        // 演示：拦截交互周期并传递坐标
        debugPrint('Scrollbar Interaction: $state at $offset');
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
            node.label, // 我们仅用年份演示自定义效果
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        );
      },
      // 🔥 新增：演示自定义 Thumb 滑块的 Widget！
      thumbBuilder: (context, thumbHeight, isDragging) {
        return Container(
          width: 20, // 这个宽度会被 style.thumbWidth 覆盖，建议使用 style 配置
          height: thumbHeight,
          decoration: BoxDecoration(
            color: isDragging
                ? Colors.deepPurple
                : Colors.deepPurple.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDragging
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : null,
            border: Border.all(
              color: isDragging
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          // 可以在滑块里加个小图标
          child: isDragging && thumbHeight > 30
              ? const Center(
                  child: Icon(Icons.unfold_more_rounded,
                      size: 14, color: Colors.white),
                )
              : null,
        );
      },
      style: YRulerScrollbarStyle(
        // 当使用了 thumbBuilder 时，这里的颜色配置将失效，但宽度配置依然有效
        thumbWidth: 16, // 我们把宽度设大一点，以便容纳图标
        thumbMinHeight: 40,
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

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4: 节点分离演示（月级尺子 + 天级提示）
// ─────────────────────────────────────────────────────────────────────────────

class _DivergedNodeScrollbarDemo extends StatefulWidget {
  const _DivergedNodeScrollbarDemo();

  @override
  State<_DivergedNodeScrollbarDemo> createState() =>
      __DivergedNodeScrollbarDemoState();
}

class __DivergedNodeScrollbarDemoState
    extends State<_DivergedNodeScrollbarDemo> {
  final ScrollController _ctrl = ScrollController();

  late final List<YFileGroup<YFileItem>> _months;
  late final List<YFileGroup<YFileItem>> _days;

  @override
  void initState() {
    super.initState();
    _months =
        DemoData.getGroupsByDimension('month', items: DemoData.gridItems2);
    _days = DemoData.getGroupsByDimension('day', items: DemoData.gridItems2);
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
      // 尺子显示月级
      nodes: _months,
      scrollOffsetBuilder: (node, index) {
        // 月份尺子的绝对偏移量计算：
        // 关键点：这里的列表是按 "天" (days) 渲染的，不是按月！
        // 列表里的 item 是 days 分组，所以 Header 数量等于之前的 days 组数，
        // Item 数量等于之前所有的 item 总数。
        // 所以我们必须从 _days 列表里累加，直到当前的 month
        int absoluteItems = 0;
        int absoluteDayHeaders = 0;

        for (final dayGroup in _days) {
          // 如果当前天级分组的年份和月份等于目标月份
          // （在真实的业务模型中，应该用 DateTime 比较或者预先算好映射关系）
          // 这里通过简单的字符串前缀匹配 (例如 '2023-10' 匹配 '2023-10-15')
          if (dayGroup.groupTitle.startsWith(node.label)) {
            break;
          }
          absoluteItems += dayGroup.count;
          absoluteDayHeaders += 1;
        }

        // 列表模式下高度 = 之前组的 items * 72 + 之前组的天级 headers * 40
        return (absoluteItems * 72) + (absoluteDayHeaders * 40);
      },
      // 提示显示天级
      hintNodes: _days,
      hintScrollOffsetBuilder: (node, index) {
        int absoluteIndex = 0;
        for (int i = 0; i < index; i++) {
          absoluteIndex += _days[i].count;
        }
        return (absoluteIndex * 72) + (index * 40);
      },
      showHintOnDrag: true,
      style: YRulerScrollbarStyle(
        thumbColor: Colors.orange.withValues(alpha: 0.45),
        thumbDraggingColor: Colors.orange,
        thumbWidth: 4,
        showTrack: true,
        trackColor: Colors.grey.withValues(alpha: 0.06),
        labelStyle: const TextStyle(
          fontSize: 10,
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: CustomScrollView(
        controller: _ctrl,
        slivers: [
          SliverYFileGroupedList<YFileItem>(
            groups: _days,
            config: const YFileGroupedConfig(
              mode: YFileGroupedMode.list,
              pinnedHeader: true,
              groupHeaderHeight: 40,
            ),
            headerBuilder: (context, group, groupIndex) {
              return Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                color: Colors.orange.shade50,
                child: Text(
                  group.groupTitle,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              );
            },
            itemBuilder: (context, group, item, groupIndex, itemIndex) {
              return SizedBox(
                height: 72, // 确保这里的实际高度与计算的高度 (72) 完全一致
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text('ID: ${item.id}'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

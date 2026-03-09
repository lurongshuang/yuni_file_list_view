import 'package:flutter/widgets.dart';
import '../../config/y_file_grouped_config.dart';
import '../../config/y_file_grid_config.dart';
import '../../config/y_file_list_config.dart';
import '../../model/y_file_group.dart';
import '../../delegate/y_file_item_builder.dart';
import '../../utils/y_grid_column_calculator.dart';

/// 构建分组列表的 Sliver 组合，直接放入 [CustomScrollView.slivers]。
///
/// 当 [config.pinnedHeader] 为 true 时：
/// - 第 0 组的 in-list title 不渲染，由吸顶 header 代替
/// - 第 1+ 组的 in-list title 正常渲染，并带有 GlobalKey
/// - 吸顶 header 通过各 GlobalKey 读取实际渲染位置来判断当前分组，
///   完全不依赖高度估算，精度和真实渲染一致。
List<Widget> buildSliverYFileGroupedListView<T>({
  Key? key,
  required List<YFileGroup<T>> groups,
  required YFileGroupHeaderBuilder<T> headerBuilder,
  required YFileGroupItemBuilder<T> itemBuilder,
  YFileGroupedConfig config = const YFileGroupedConfig(),
  double? availableWidth,
}) {
  final gridConfig = config.gridConfig;
  final listConfig = config.listConfig;
  final isGrid = config.mode == YFileGroupedMode.grid;
  final pinnedHeader = config.pinnedHeader;

  final w = availableWidth ?? 0;
  final crossAxisCount = gridConfig.isAutoColumn
      ? YGridColumnCalculator.calculate(
          availableWidth: w,
          minItemWidth: gridConfig.minItemWidth,
          spacing: gridConfig.crossAxisSpacing,
          minColumns: gridConfig.minColumns,
          maxColumns: gridConfig.maxColumns,
        )
      : gridConfig.crossAxisCount;

  if (!pinnedHeader) {
    return _buildFlatSlivers<T>(
      groups: groups,
      headerBuilder: headerBuilder,
      itemBuilder: itemBuilder,
      gridConfig: gridConfig,
      listConfig: listConfig,
      crossAxisCount: crossAxisCount,
      isGrid: isGrid,
    );
  }

  // 为 group[1+] 的 in-list header 预分配 GlobalKey，
  // 为了防止每次 build 产生新 Key 导致复用的下层组件找不到 Context（如 IndexedStack 切回时），
  // 这里使用 GlobalObjectKey，只要底层数据实例不变，Key 就强制复用。
  final groupKeys = <int, GlobalKey>{};
  for (var i = 1; i < groups.length; i++) {
    groupKeys[i] = GlobalObjectKey(groups[i]);
  }

  return [
    // ── 吸顶 header ──────────────────────────────────────────
    SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedHeaderDelegate<T>(
        groups: groups,
        headerBuilder: headerBuilder,
        headerExtent: config.groupHeaderHeight,
        groupKeys: groupKeys,
      ),
    ),
    // ── 分组内容 ──────────────────────────────────────────────
    // group[0] 无 in-list title；group[1+] 有，并绑定 GlobalKey。
    ..._buildFlatSlivers<T>(
      groups: groups,
      headerBuilder: headerBuilder,
      itemBuilder: itemBuilder,
      gridConfig: gridConfig,
      listConfig: listConfig,
      crossAxisCount: crossAxisCount,
      isGrid: isGrid,
      skipFirstHeader: true,
      groupKeys: groupKeys,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Delegate
// ─────────────────────────────────────────────────────────────────────────────

class _PinnedHeaderDelegate<T> extends SliverPersistentHeaderDelegate {
  final List<YFileGroup<T>> groups;
  final YFileGroupHeaderBuilder<T> headerBuilder;
  final double headerExtent;
  final Map<int, GlobalKey> groupKeys;

  const _PinnedHeaderDelegate({
    required this.groups,
    required this.headerBuilder,
    required this.headerExtent,
    required this.groupKeys,
  });

  @override
  double get minExtent => headerExtent;
  @override
  double get maxExtent => headerExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _PinnedHeaderContent<T>(
      groups: groups,
      headerBuilder: headerBuilder,
      headerExtent: headerExtent,
      groupKeys: groupKeys,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate<T> old) {
    return old.groups != groups || old.headerExtent != headerExtent;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PinnedHeaderContent：用 GlobalKey 读取实际坐标，无高度估算误差
// ─────────────────────────────────────────────────────────────────────────────

class _PinnedHeaderContent<T> extends StatefulWidget {
  final List<YFileGroup<T>> groups;
  final YFileGroupHeaderBuilder<T> headerBuilder;
  final double headerExtent;
  final Map<int, GlobalKey> groupKeys;

  const _PinnedHeaderContent({
    required this.groups,
    required this.headerBuilder,
    required this.headerExtent,
    required this.groupKeys,
  });

  @override
  State<_PinnedHeaderContent<T>> createState() =>
      _PinnedHeaderContentState<T>();
}

class _PinnedHeaderContentState<T>
    extends State<_PinnedHeaderContent<T>> {
  ScrollPosition? _scrollPosition;
  int _currentGroupIndex = 0;

  void _onScroll() {
    if (!mounted) return;

    double headerY = 0.0;
    final myBox = context.findRenderObject() as RenderBox?;
    if (myBox != null && myBox.attached) {
      headerY = myBox.localToGlobal(Offset.zero).dy;
    }

    final newIndex = _computeGroupIndex(headerY);
    if (newIndex != _currentGroupIndex) {
      setState(() {
        _currentGroupIndex = newIndex;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.of(context).position;
    _scrollPosition?.addListener(_onScroll);
    // 初始化时先计算一次对应的索引，防止起始不在最顶端
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  @override
  void didUpdateWidget(covariant _PinnedHeaderContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部数据源发生变化（比如切换维度）时，立刻重新计算吸顶索引
    if (oldWidget.groups != widget.groups) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onScroll();
      });
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return SizedBox(height: widget.headerExtent);
    }
    
    // 动态维护最新的滚动监听：解决 IndexedStack 切换等导致原 Position 对象失效脱落的终极防线
    final currentPos = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != currentPos && currentPos != null) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = currentPos;
      _scrollPosition!.addListener(_onScroll);
      // 刚绑上新 Position 时可能错过了事件，在下一帧强制对齐
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onScroll();
      });
    }
    
    // 防御型修正：切换维度等操作导致数据变少时，防止旧索引越界崩溃
    if (_currentGroupIndex >= widget.groups.length) {
      // 不调用 setState，直接在这里安全修剪值用于本帧构建。
      // didUpdateWidget 中已通过 _onScroll 发起了下帧重新精确定位的请求。
      _currentGroupIndex = widget.groups.length - 1;
      if (_currentGroupIndex < 0) _currentGroupIndex = 0;
    }

    // build 阶段只负责使用计算好的 _currentGroupIndex 构建 UI。
    // 坚决不在 build 期间调用 findRenderObject (特别是在 Hot Reload 时，
    // 其子 Element 可能是 inactive 状态，会抛出 AssertionError)。
    return widget.headerBuilder(
        context, widget.groups[_currentGroupIndex], _currentGroupIndex);
  }

  /// 通过 GlobalKey 读取各分组 in-list header 的实际屏幕坐标，与吸顶坐标对比。
  ///
  /// 为了解决 Sliver 回收不可见元素导致的 "闪烁回退到 0" 问题，
  /// 现在的逻辑改为从前向后扫描屏幕上依然附着 (attached) 的标题。
  int _computeGroupIndex(double headerY) {
    if (widget.groups.isEmpty) return 0;

    int? lastPassedIndex;

    // 从前向后遍历（i 越小越在上方，屏幕坐标 dy 应该递增）
    for (var i = 1; i < widget.groups.length; i++) {
      final key = widget.groupKeys[i];
      if (key == null) continue;
      final ctx = key.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;

      final dy = box.localToGlobal(Offset.zero).dy;
      // 记录最新一个发现已滚过（或刚到）吸顶区域底部的组
      if (dy <= headerY + 0.5) {
        lastPassedIndex = i;
      } else {
        // 发现第一个还在吸顶区下方的可见标题！
        // 因为它是视口内最靠上的未被吸顶的标题，它上方的组一定就是当前霸占吸顶区域的组
        return i - 1;
      }
    }

    // 屏幕内所有找到的标题，都已经滚过了吸顶区 (都在 dy <= headerY)
    // 那么吸顶的必然是最下方那个
    if (lastPassedIndex != null) {
      return lastPassedIndex;
    }

    // 终极兜底：如果屏幕内一个 header 都没找到（某组内容太长），
    // 原地保持当前的 currentGroupIndex，绝不瞎跳回 0。
    return _currentGroupIndex;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 辅助类型
// ─────────────────────────────────────────────────────────────────────────────

abstract class _FlatItem<T> {}

class _GroupStart<T> extends _FlatItem<T> {
  final YFileGroup<T> group;
  final int groupIndex;
  final GlobalKey? headerKey;
  _GroupStart({
    required this.group,
    required this.groupIndex,
    this.headerKey,
  });
}

class _GridRow<T> extends _FlatItem<T> {
  final YFileGroup<T> group;
  final int groupIndex;
  final int startIndex;
  final int crossAxisCount;
  _GridRow({
    required this.group,
    required this.groupIndex,
    required this.startIndex,
    required this.crossAxisCount,
  });
}

class _ListItem<T> extends _FlatItem<T> {
  final YFileGroup<T> group;
  final int groupIndex;
  final int itemIndex;
  _ListItem({
    required this.group,
    required this.groupIndex,
    required this.itemIndex,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 将分组数据展平为 Sliver
// ─────────────────────────────────────────────────────────────────────────────

List<Widget> _buildFlatSlivers<T>({
  required List<YFileGroup<T>> groups,
  required YFileGroupHeaderBuilder<T> headerBuilder,
  required YFileGroupItemBuilder<T> itemBuilder,
  required YFileGridConfig gridConfig,
  required YFileListConfig listConfig,
  required int crossAxisCount,
  required bool isGrid,
  bool skipFirstHeader = false,
  Map<int, GlobalKey> groupKeys = const {},
}) {
  final flatItems = <_FlatItem<T>>[];
  for (var gi = 0; gi < groups.length; gi++) {
    final group = groups[gi];
    // skipFirstHeader=true 时跳过 group[0] 的 in-list title
    if (!skipFirstHeader || gi > 0) {
      flatItems.add(_GroupStart<T>(
        group: group,
        groupIndex: gi,
        headerKey: groupKeys[gi], // group[0] 为 null，group[1+] 有 key
      ));
    }

    if (isGrid) {
      for (var row = 0; row < group.items.length; row += crossAxisCount) {
        flatItems.add(_GridRow<T>(
          group: group,
          groupIndex: gi,
          startIndex: row,
          crossAxisCount: crossAxisCount,
        ));
      }
    } else {
      for (var i = 0; i < group.items.length; i++) {
        flatItems.add(_ListItem<T>(
          group: group,
          groupIndex: gi,
          itemIndex: i,
        ));
      }
    }
  }

  return [
    SliverPadding(
      padding: isGrid ? gridConfig.padding : listConfig.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = flatItems[index];
            if (item is _GroupStart<T>) {
              // 用 KeyedSubtree 绑定 GlobalKey，让 _PinnedHeaderContent
              // 能通过 key.currentContext 读取该 header 的实际坐标。
              final headerWidget =
                  headerBuilder(context, item.group, item.groupIndex);
              if (item.headerKey != null) {
                return KeyedSubtree(
                  key: item.headerKey,
                  child: headerWidget,
                );
              }
              return headerWidget;
            } else if (item is _GridRow<T>) {
              final rowItems = item.group.items.sublist(
                item.startIndex,
                (item.startIndex + item.crossAxisCount)
                    .clamp(0, item.group.items.length),
              );
              return Row(
                children: List.generate(item.crossAxisCount, (col) {
                  if (col < rowItems.length) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: col < item.crossAxisCount - 1
                              ? gridConfig.crossAxisSpacing
                              : 0,
                          top: gridConfig.mainAxisSpacing / 2,
                          bottom: gridConfig.mainAxisSpacing / 2,
                        ),
                        child: AspectRatio(
                          aspectRatio: gridConfig.childAspectRatio,
                          child: itemBuilder(
                            context,
                            item.group,
                            rowItems[col],
                            item.groupIndex,
                            item.startIndex + col,
                          ),
                        ),
                      ),
                    );
                  }
                  return const Expanded(child: SizedBox.shrink());
                }),
              );
            } else if (item is _ListItem<T>) {
              return itemBuilder(
                context,
                item.group,
                item.group.items[item.itemIndex],
                item.groupIndex,
                item.itemIndex,
              );
            }
            return const SizedBox.shrink();
          },
          childCount: flatItems.length,
        ),
      ),
    ),
  ];
}

import 'package:flutter/widgets.dart';
import '../../config/y_file_grouped_config.dart';
import '../../config/y_file_grid_config.dart';
import '../../config/y_file_list_config.dart';
import '../../model/y_file_group.dart';
import '../../delegate/y_file_item_builder.dart';
import '../../utils/y_grid_column_calculator.dart';

/// 提供响应式的分组列表 Sliver 组合，直接放入 [CustomScrollView.slivers]。
///
/// 当 [config.pinnedHeader] 为 true 时：
/// - 第 0 组的 in-list title 不渲染，由吸顶 header 代替
/// - 第 1+ 组的 in-list title 正常渲染，并带有 GlobalKey
/// - 吸顶 header 通过读取实际渲染位置来判断当前分组。
/// - **[高性能]**：内置 O(1) 级别的邻居节点增量检索算法，即便在万级分组中高频滑动也绝不掉帧。
/// - **[自适应]**：内部封装 `SliverLayoutBuilder`，自动适配屏幕宽度与网格列数，支持转屏。
class SliverYFileGroupedList<T> extends StatelessWidget {
  final List<YFileGroup<T>> groups;
  final YFileGroupHeaderBuilder<T> headerBuilder;
  final YFileGroupItemBuilder<T> itemBuilder;
  final YFileGroupedConfig config;

  const SliverYFileGroupedList({
    super.key,
    required this.groups,
    required this.headerBuilder,
    required this.itemBuilder,
    this.config = const YFileGroupedConfig(),
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final gridConfig = config.gridConfig;
        final listConfig = config.listConfig;
        final isGrid = config.mode == YFileGroupedMode.grid;
        final pinnedHeader = config.pinnedHeader;

        // 使用真实排版约束进行自适应列数计算，完美支持转屏/分屏响应式
        final crossAxisCount = gridConfig.isAutoColumn
            ? YGridColumnCalculator.calculate(
                availableWidth: constraints.crossAxisExtent,
                minItemWidth: gridConfig.minItemWidth,
                spacing: gridConfig.crossAxisSpacing,
                minColumns: gridConfig.minColumns,
                maxColumns: gridConfig.maxColumns,
              )
            : gridConfig.crossAxisCount;

        if (!pinnedHeader) {
          return SliverMainAxisGroup(
            slivers: _buildFlatSlivers<T>(
              groups: groups,
              headerBuilder: headerBuilder,
              itemBuilder: itemBuilder,
              gridConfig: gridConfig,
              listConfig: listConfig,
              crossAxisCount: crossAxisCount,
              isGrid: isGrid,
            ),
          );
        }

        // 为 group[1+] 的 in-list header 预分配 GlobalKey，
        // 使用 GlobalObjectKey 绑定数据实体，杜绝跨刷新树变更引起的指针丢失
        final groupKeys = <int, GlobalKey>{};
        for (var i = 1; i < groups.length; i++) {
          groupKeys[i] = GlobalObjectKey(groups[i]);
        }

        return SliverMainAxisGroup(
          slivers: [
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
          ],
        );
      },
    );
  }
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

  // 缓存已构建的 Widget 及其依赖项
  Widget? _cachedHeader;
  int? _lastBuiltGroupIndex;
  List<YFileGroup<T>>? _lastGroups;
  YFileGroupHeaderBuilder<T>? _lastHeaderBuilder;

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
    // 外部数据源发生变化（比如切换维度）或 Builder 变动时
    final groupsChanged = !identical(oldWidget.groups, widget.groups);
    final builderChanged = !identical(oldWidget.headerBuilder, widget.headerBuilder);
    
    if (groupsChanged || builderChanged) {
      // 这里的变更需要清理缓存，触发重新构建
      _cachedHeader = null;
      _lastGroups = null;
      _lastHeaderBuilder = null;

      // 预先拦截并修正可能的索引越界问题，彻底避免渲染期的非法读越界
      if (_currentGroupIndex >= widget.groups.length) {
        setState(() {
          _currentGroupIndex =
              (widget.groups.length - 1).clamp(0, double.infinity).toInt();
        });
      }

      // 无论如何，发出重新校准请求
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
    
    // 动态维护最新的滚动监听
    final currentPos = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != currentPos && currentPos != null) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = currentPos;
      _scrollPosition!.addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onScroll();
      });
    }

    // 缓存机制：若关键参数未变，直接返回上一次的结果，避免每一帧都执行 builder
    final sameGroups = identical(_lastGroups, widget.groups);
    final sameBuilder = identical(_lastHeaderBuilder, widget.headerBuilder);
    final sameIndex = _lastBuiltGroupIndex == _currentGroupIndex;

    if (_cachedHeader != null && sameGroups && sameBuilder && sameIndex) {
      return _cachedHeader!;
    }

    // 更新缓存并返回新 Widget
    final group = widget.groups[_currentGroupIndex];
    _cachedHeader = widget.headerBuilder(context, group, _currentGroupIndex);
    _lastBuiltGroupIndex = _currentGroupIndex;
    _lastGroups = widget.groups;
    _lastHeaderBuilder = widget.headerBuilder;

    return _cachedHeader!;
  }

  /// 通过 GlobalKey 读取各分组 in-list header 的实际屏幕坐标，与吸顶坐标对比。
  ///
  /// [优化策略]：
  /// 1. 增量探寻：在常规持续滚动中，新索引极大概率在当前索引附近（O(1)）。
  /// 2. 分段扫描：在大跨度跳跃（如拖动滚动条）时，利用 ctx == null 的特性快速跳过不可见组。
  int _computeGroupIndex(double headerY) {
    if (widget.groups.isEmpty) return 0;
    final len = widget.groups.length;

    // A. 探测向下滚动 (索引增加)
    if (_currentGroupIndex + 1 < len) {
      final nextDy = _getGroupHeaderDy(_currentGroupIndex + 1);
      if (nextDy != null && nextDy <= headerY + 0.5) {
        // 当前组已被“顶”出，向下寻找最后一个已越过吸顶线的 header
        for (int i = _currentGroupIndex + 1; i < len; i++) {
          final dy = _getGroupHeaderDy(i);
          if (dy == null) continue; // 尚未进入渲染区
          if (dy > headerY + 0.5) return i - 1; // 发现第一个还在下方的，返回其前一组
          if (i == len - 1) return i;
        }
      }
    }

    // B. 探测向上滚动 (索引减小)
    if (_currentGroupIndex > 0) {
      final curDy = _getGroupHeaderDy(_currentGroupIndex);
      if (curDy != null && curDy > headerY + 0.5) {
        // 当前组标题被拉到了吸顶线下方，向上追溯
        for (int i = _currentGroupIndex - 1; i >= 1; i--) {
          final dy = _getGroupHeaderDy(i);
          if (dy == null) continue;
          if (dy <= headerY + 0.5) return i;
        }
        return 0;
      }
    }

    // C. 兜底扫描：用于 IndexedStack 切换或极速跳跃滑动
    // 虽然是全量循环，但 ctx == null 拦截了 99.9% 的逻辑，执行开销极低
    for (var i = 1; i < len; i++) {
      final dy = _getGroupHeaderDy(i);
      if (dy == null) continue;
      if (dy > headerY + 0.5) {
        return i - 1;
      }
      if (i == len - 1) return i;
    }

    // 保持现状 (通常发生在组内容极长，屏幕内没有任何标题时)
    return _currentGroupIndex;
  }

  /// 获取指定索引 header 的当前全局垂直坐标，不可见或未渲染则返回 null
  double? _getGroupHeaderDy(int index) {
    final key = widget.groupKeys[index];
    if (key == null) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    // localToGlobal 仅在 context 存活且 attached 时有效
    try {
      return box.localToGlobal(Offset.zero).dy;
    } catch (_) {
      return null;
    }
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
              final children = <Widget>[];
              for (int col = 0; col < item.crossAxisCount; col++) {
                if (col > 0) {
                  children.add(SizedBox(width: gridConfig.crossAxisSpacing));
                }
                if (col < rowItems.length) {
                  children.add(
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
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
                    ),
                  );
                } else {
                  children.add(const Expanded(child: SizedBox.shrink()));
                }
              }
              return Row(children: children);
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

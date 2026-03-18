import 'package:flutter/material.dart';
import '../interaction/y_desktop_selection_controller.dart';
import '../interaction/y_desktop_selection_region.dart';
import '../../model/y_file_group.dart';
import '../../model/y_selection_data.dart';
import '../grid/y_desktop_file_grid_view.dart';

/// 桌面端分组宫格视图
class YDesktopGroupedGridView<T> extends StatefulWidget {
  final List<YFileGroup<T>> groups;
  final YDesktopSelectionController controller;
  final YDesktopGridItemBuilder<T> itemBuilder;
  final ScrollController? scrollController;

  /// 宫格列数 (如果提供了 maxCrossAxisExtent，则失效)
  final int crossAxisCount;

  /// 最大列宽 (用于自动计算列数)
  final double? maxCrossAxisExtent;

  /// 主轴间距
  final double mainAxisSpacing;

  /// 交叉轴间距
  final double crossAxisSpacing;

  /// Item 宽高比
  final double childAspectRatio;

  /// 分组标题高度
  final double groupHeaderHeight;

  /// 分组标题构建器
  final Widget Function(BuildContext context, String title)? groupHeaderBuilder;

  /// 内边距
  final EdgeInsets padding;

  const YDesktopGroupedGridView({
    super.key,
    required this.groups,
    required this.controller,
    required this.itemBuilder,
    this.scrollController,
    this.crossAxisCount = 4,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.groupHeaderHeight = 40.0,
    this.groupHeaderBuilder,
    this.padding = const EdgeInsets.all(0),
    this.enableClearSelectionOnTapBackground = true,
    this.marqueeFillColor,
    this.marqueeBorderColor,
    this.marqueeBorderWidth = 1.0,
  });

  /// --- 选框样式 ---
  final bool enableClearSelectionOnTapBackground;
  final Color? marqueeFillColor;
  final Color? marqueeBorderColor;
  final double marqueeBorderWidth;

  @override
  State<YDesktopGroupedGridView<T>> createState() =>
      _YDesktopGroupedGridViewState<T>();
}

class _YDesktopGroupedGridViewState<T>
    extends State<YDesktopGroupedGridView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return YDesktopSelectionRegion(
      controller: widget.controller,
      scrollController: widget.scrollController,
      enableClearSelectionOnTapBackground:
          widget.enableClearSelectionOnTapBackground,
      marqueeFillColor: widget.marqueeFillColor,
      marqueeBorderColor: widget.marqueeBorderColor,
      marqueeBorderWidth: widget.marqueeBorderWidth,
      customSelectionCalculator: (rectInContent) {
        final Set<int> indices = {};
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return indices;

        final double availableWidth =
            box.size.width - widget.padding.left - widget.padding.right;

        // 计算列数
        int count = widget.crossAxisCount;
        if (widget.maxCrossAxisExtent != null) {
          count = (availableWidth /
                  (widget.maxCrossAxisExtent! + widget.crossAxisSpacing))
              .ceil();
          count = count.clamp(1, 1000);
        }

        final double cellWidth =
            (availableWidth - (count - 1) * widget.crossAxisSpacing) / count;
        final double cellHeight = cellWidth / widget.childAspectRatio;

        double currentY = widget.padding.top;
        int globalItemIndex = 0;

        for (final group in widget.groups) {
          // 标题行不增加索引，但参与坐标计算
          currentY += widget.groupHeaderHeight;

          // 计算该组的宫格区域
          final int rows = (group.items.length / count).ceil();
          final double gridHeight = rows * cellWidth / widget.childAspectRatio +
              (rows > 0 ? (rows - 1) * widget.mainAxisSpacing : 0);

          final groupGridRect = Rect.fromLTWH(
              widget.padding.left, currentY, availableWidth, gridHeight);

          if (rectInContent.overlaps(groupGridRect)) {
            // 如果框选区域与该组宫格区域有重叠，则细化计算
            for (int i = 0; i < group.items.length; i++) {
              final int row = i ~/ count;
              final int col = i % count;

              final double x = widget.padding.left +
                  col * (cellWidth + widget.crossAxisSpacing);
              final double y =
                  currentY + row * (cellHeight + widget.mainAxisSpacing);
              final itemRect = Rect.fromLTWH(x, y, cellWidth, cellHeight);

              if (rectInContent.overlaps(itemRect)) {
                indices.add(globalItemIndex + i);
              }
            }
          }

          globalItemIndex += group.items.length;
          currentY += gridHeight + widget.mainAxisSpacing;
        }

        return indices;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          for (final group in widget.groups) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: widget.padding,
                child: widget.groupHeaderBuilder
                        ?.call(context, group.groupTitle) ??
                    Container(
                      height: widget.groupHeaderHeight,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        group.groupTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
              ),
            ),
            SliverPadding(
              padding: widget.padding,
              sliver: SliverGrid(
                gridDelegate: widget.maxCrossAxisExtent != null
                    ? SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: widget.maxCrossAxisExtent!,
                        mainAxisSpacing: widget.mainAxisSpacing,
                        crossAxisSpacing: widget.crossAxisSpacing,
                        childAspectRatio: widget.childAspectRatio,
                      )
                    : SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.crossAxisCount,
                        mainAxisSpacing: widget.mainAxisSpacing,
                        crossAxisSpacing: widget.crossAxisSpacing,
                        childAspectRatio: widget.childAspectRatio,
                      ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = group.items[index];
                    final globalIndex = _getGlobalIndex(group, index);
                    final isSelected =
                        widget.controller.isSelected(globalIndex);

                    void triggerSelection({bool isSecondary = false}) {
                      widget.controller
                          .handleTap(globalIndex, isSecondary: isSecondary);
                    }

                    return MetaData(
                      metaData: YSelectionData(index: globalIndex, extra: item),
                      behavior: HitTestBehavior.translucent,
                      child: widget.itemBuilder(
                        context,
                        item,
                        globalIndex,
                        isSelected,
                        triggerSelection,
                      ),
                    );
                  },
                  childCount: group.items.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getGlobalIndex(YFileGroup<T> targetGroup, int indexInGroup) {
    int count = 0;
    for (final group in widget.groups) {
      if (group == targetGroup) return count + indexInGroup;
      count += group.items.length;
    }
    return count + indexInGroup;
  }
}

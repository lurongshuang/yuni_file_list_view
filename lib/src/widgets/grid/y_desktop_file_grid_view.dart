import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../interaction/y_desktop_selection_controller.dart';
import '../interaction/y_desktop_selection_region.dart';
import '../../model/y_selection_data.dart';

/// 桌面端文件宫格项构建器
typedef YDesktopGridItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  bool isSelected,
  void Function(bool isSecondary) onPointerDown,
);

/// 桌面端文件宫格视图
class YDesktopFileGridView<T> extends StatefulWidget {
  final List<T> items;
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

  /// 内边距
  final EdgeInsets padding;

  const YDesktopFileGridView({
    super.key,
    required this.items,
    required this.controller,
    required this.itemBuilder,
    this.scrollController,
    this.crossAxisCount = 4,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<YDesktopFileGridView<T>> createState() => _YDesktopFileGridViewState<T>();
}

class _YDesktopFileGridViewState<T> extends State<YDesktopFileGridView<T>> {
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
      customSelectionCalculator: (rectInContent) {
        final Set<int> indices = {};
        
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return indices;

        final double availableWidth = box.size.width - widget.padding.left - widget.padding.right;
        
        // 计算列数
        int count = widget.crossAxisCount;
        if (widget.maxCrossAxisExtent != null) {
          count = (availableWidth / (widget.maxCrossAxisExtent! + widget.crossAxisSpacing)).ceil();
          count = count.clamp(1, 1000); 
        }

        final double cellWidth = (availableWidth - (count - 1) * widget.crossAxisSpacing) / count;
        final double cellHeight = cellWidth / widget.childAspectRatio;

        final double top = rectInContent.top - widget.padding.top;
        final double bottom = rectInContent.bottom - widget.padding.top;
        
        int startRow = (top / (cellHeight + widget.mainAxisSpacing)).floor();
        int endRow = (bottom / (cellHeight + widget.mainAxisSpacing)).floor();
        
        startRow = startRow.clamp(0, (widget.items.length / count).ceil());
        endRow = endRow.clamp(0, (widget.items.length / count).ceil());

        for (int row = startRow; row <= endRow; row++) {
          for (int col = 0; col < count; col++) {
            final index = row * count + col;
            if (index >= widget.items.length) break;

            final x = widget.padding.left + col * (cellWidth + widget.crossAxisSpacing);
            final y = widget.padding.top + row * (cellHeight + widget.mainAxisSpacing);
            final itemRect = Rect.fromLTWH(x, y, cellWidth, cellHeight);

            if (rectInContent.overlaps(itemRect)) {
              indices.add(index);
            }
          }
        }
        return indices;
      },
      child: GridView.builder(
        controller: widget.scrollController,
        padding: widget.padding,
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
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = widget.controller.isSelected(index);
          
          void handlePointerDown(bool isSecondary) {
            widget.controller.handleTap(index, isSecondary: isSecondary);
          }

          return MetaData(
            metaData: YSelectionData(index: index, extra: item),
            behavior: HitTestBehavior.translucent,
            child: Listener(
              onPointerDown: (event) {
                final isSecondary = event.buttons == kSecondaryMouseButton;
                handlePointerDown(isSecondary);
              },
              child: GestureDetector(
                onTap: () {}, // 捕获点击，防止事件冒泡到 Region 触发清空
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.transparent,
                  child: widget.itemBuilder(
                    context, 
                    item, 
                    index, 
                    isSelected,
                    handlePointerDown,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

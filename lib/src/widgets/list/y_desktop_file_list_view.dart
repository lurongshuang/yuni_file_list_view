import 'package:flutter/material.dart';
import '../interaction/y_desktop_selection_controller.dart';
import '../interaction/y_desktop_selection_region.dart';
import '../../config/y_desktop_column.dart';
import 'y_desktop_file_header.dart';
import 'y_desktop_file_item.dart';

/// 桌面端文件列表视图
///
/// 这是一个高度集成的桌面端列表组件，支持：
/// - 多列显示
/// - 鼠标框选
/// - 修饰键多选 (Shift, Cmd/Ctrl)
/// - 边缘自动滚动
class YDesktopFileListView<T> extends StatefulWidget {
  final List<T> items;
  final List<YDesktopColumn<T>> columns;
  final YDesktopSelectionController controller;
  final ScrollController? scrollController;
  final double headerHeight;
  final double itemHeight;
  final bool showHeader;
  final VoidCallback? onSelectionChanged;
  final Function(T item)? onItemDoubleTap;
  
  /// 自定义项构建器
  /// 
  /// 如果不提供，将默认使用 [YDesktopFileItem]
  final Widget Function(
    BuildContext context, 
    T item, 
    int index, 
    bool isSelected,
    void Function(bool isSecondary) onPointerDown,
  )? itemBuilder;

  const YDesktopFileListView({
    super.key,
    required this.items,
    required this.columns,
    required this.controller,
    this.itemBuilder,
    this.scrollController,
    this.headerHeight = 36.0,
    this.itemHeight = 32.0,
    this.showHeader = true,
    this.onSelectionChanged,
    this.onItemDoubleTap,
  });

  @override
  State<YDesktopFileListView<T>> createState() => _YDesktopFileListViewState<T>();
}

class _YDesktopFileListViewState<T> extends State<YDesktopFileListView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleSelectionChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleSelectionChange);
    super.dispose();
  }

  void _handleSelectionChange() {
    if (mounted) {
      setState(() {});
      widget.onSelectionChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showHeader)
          YDesktopFileHeader<T>(
            columns: widget.columns,
            height: widget.headerHeight,
          ),
        Expanded(
          child: YDesktopSelectionRegion(
            controller: widget.controller,
            scrollController: widget.scrollController,
            customSelectionCalculator: (rectInContent) {
              final Set<int> indices = {};
              // 对于纵向列表，核心是高度计算
              final double top = rectInContent.top;
              final double bottom = rectInContent.bottom;
              
              // 起始索引：floor(top / itemHeight)
              int start = (top / widget.itemHeight).floor();
              // 结束索引：floor(bottom / itemHeight)
              int end = (bottom / widget.itemHeight).floor();
              
              // 限制范围
              start = start.clamp(0, widget.items.length - 1);
              end = end.clamp(0, widget.items.length - 1);
              
              for (int i = start; i <= end; i++) {
                indices.add(i);
              }
              return indices;
            },
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: widget.items.length,
              itemExtent: widget.itemHeight,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.controller.isSelected(index);
                
                void handlePointerDown(bool isSecondary) {
                  widget.controller.handleTap(index, isSecondary: isSecondary);
                }

                if (widget.itemBuilder != null) {
                  return widget.itemBuilder!(
                    context, 
                    item, 
                    index, 
                    isSelected, 
                    handlePointerDown,
                  );
                }

                return YDesktopFileItem<T>(
                  item: item,
                  index: index,
                  columns: widget.columns,
                  height: widget.itemHeight,
                  selected: isSelected,
                  onPointerDown: handlePointerDown,
                  onDoubleTap: () => widget.onItemDoubleTap?.call(item),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

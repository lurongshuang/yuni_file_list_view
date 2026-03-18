import 'package:flutter/material.dart';
import '../interaction/y_desktop_selection_controller.dart';
import '../interaction/y_desktop_selection_region.dart';
import '../../model/y_selection_data.dart';
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
  final ScrollPhysics? physics;
  final double headerHeight;
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
    void Function({bool isSecondary}) triggerSelection,
  )? itemBuilder;

  const YDesktopFileListView({
    super.key,
    required this.items,
    required this.columns,
    required this.controller,
    this.itemBuilder,
    this.scrollController,
    this.physics,
    this.headerHeight = 36.0,
    this.showHeader = true,
    this.onSelectionChanged,
    this.onItemDoubleTap,
    this.enableClearSelectionOnTapBackground = true,
    this.marqueeFillColor,
    this.marqueeBorderColor,
    this.marqueeBorderWidth = 1.0,
    this.headerDividerColor,
    this.headerDividerWidth = 0.5,
    this.itemSelectedColor,
    this.itemBorderRadius,
  });

  /// --- 选框样式 ---
  final bool enableClearSelectionOnTapBackground;
  final Color? marqueeFillColor;
  final Color? marqueeBorderColor;
  final double marqueeBorderWidth;

  /// --- 表头样式 ---
  final Color? headerDividerColor;
  final double headerDividerWidth;

  /// --- 默认项样式 ---
  final Color? itemSelectedColor;
  final BorderRadius? itemBorderRadius;

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
            dividerColor: widget.headerDividerColor,
            dividerWidth: widget.headerDividerWidth,
          ),
        Expanded(
          child: YDesktopSelectionRegion(
            controller: widget.controller,
            scrollController: widget.scrollController,
            enableClearSelectionOnTapBackground: widget.enableClearSelectionOnTapBackground,
            marqueeFillColor: widget.marqueeFillColor,
            marqueeBorderColor: widget.marqueeBorderColor,
            marqueeBorderWidth: widget.marqueeBorderWidth,
            child: ListView.builder(
              controller: widget.scrollController,
              physics: widget.physics,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.controller.isSelected(index);
                
                void triggerSelection({bool isSecondary = false}) {
                  widget.controller.handleTap(index, isSecondary: isSecondary);
                }

                if (widget.itemBuilder != null) {
                  return MetaData(
                    metaData: YSelectionData(index: index, extra: item),
                    behavior: HitTestBehavior.translucent,
                    child: widget.itemBuilder!(
                      context, 
                      item, 
                      index, 
                      isSelected, 
                      triggerSelection,
                    ),
                  );
                }

                return YDesktopFileItem<T>(
                  item: item,
                  index: index,
                  columns: widget.columns,
                  selected: isSelected,
                  selectedColor: widget.itemSelectedColor,
                  borderRadius: widget.itemBorderRadius,
                  onPointerDown: (isSecondary) => triggerSelection(isSecondary: isSecondary),
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

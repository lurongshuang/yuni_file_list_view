import 'package:flutter/material.dart';
import '../interaction/y_desktop_selection_controller.dart';
import '../interaction/y_desktop_selection_region.dart';
import '../../model/y_file_group.dart';
import '../list/y_desktop_file_item.dart';
import '../../model/y_selection_data.dart';
import '../../config/y_desktop_column.dart';

/// 桌面端分组列表视图
class YDesktopGroupedListView<T> extends StatefulWidget {
  final List<YFileGroup<T>> groups;
  final List<YDesktopColumn<T>> columns;
  final YDesktopSelectionController controller;
  final ScrollController? scrollController;
  final double itemHeight;
  final double groupHeaderHeight;
  final Widget Function(BuildContext context, String title)? groupHeaderBuilder;

  /// 自定义项构建器
  final Widget Function(
    BuildContext context, 
    T item, 
    int index, 
    bool isSelected,
    void Function(bool isSecondary) onPointerDown,
  )? itemBuilder;

  const YDesktopGroupedListView({
    super.key,
    required this.groups,
    required this.columns,
    required this.controller,
    this.itemBuilder,
    this.scrollController,
    this.itemHeight = 32.0,
    this.groupHeaderHeight = 40.0,
    this.groupHeaderBuilder,
  });

  @override
  State<YDesktopGroupedListView<T>> createState() => _YDesktopGroupedListViewState<T>();
}

class _YDesktopGroupedListViewState<T> extends State<YDesktopGroupedListView<T>> {
  late List<_GroupedItem<T>> _flattenedItems;

  @override
  void initState() {
    super.initState();
    _flatten();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(YDesktopGroupedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groups != widget.groups) {
      _flatten();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _flatten() {
    _flattenedItems = [];
    for (final group in widget.groups) {
      _flattenedItems.add(_GroupedItem.header(group.groupTitle));
      for (final item in group.items) {
        _flattenedItems.add(_GroupedItem.item(item));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return YDesktopSelectionRegion(
      controller: widget.controller,
      scrollController: widget.scrollController,
      customSelectionCalculator: (rectInContent) {
        final Set<int> indices = {};
        double currentY = 0;
        int itemIndex = 0;

        for (final entry in _flattenedItems) {
          final double h = entry.isHeader ? widget.groupHeaderHeight : widget.itemHeight;
          final itemRect = Rect.fromLTWH(0, currentY, 10000, h); // 假设宽度无限大覆盖全行

          if (rectInContent.overlaps(itemRect) && !entry.isHeader) {
            indices.add(itemIndex);
          }

          if (!entry.isHeader) {
            itemIndex++;
          }
          currentY += h;
        }
        return indices;
      },
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: _flattenedItems.length,
        itemBuilder: (context, index) {
          final entry = _flattenedItems[index];
          if (entry.isHeader) {
            return widget.groupHeaderBuilder?.call(context, entry.headerTitle!) ??
                Container(
                  height: widget.groupHeaderHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                  child: Text(
                    entry.headerTitle!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                );
          }

          final itemIndex = _getItemIndex(index);
          final isSelected = widget.controller.isSelected(itemIndex);
          final item = entry.data as T;

          void handlePointerDown(bool isSecondary) {
            widget.controller.handleTap(itemIndex, isSecondary: isSecondary);
          }

          if (widget.itemBuilder != null) {
            return MetaData(
              metaData: YSelectionData(index: itemIndex, extra: item),
              behavior: HitTestBehavior.translucent,
              child: widget.itemBuilder!(
                context,
                item,
                itemIndex,
                isSelected,
                handlePointerDown,
              ),
            );
          }

          return YDesktopFileItem<T>(
            item: item,
            index: itemIndex,
            columns: widget.columns,
            height: widget.itemHeight,
            selected: isSelected,
            onPointerDown: handlePointerDown,
          );
        },
      ),
    );
  }

  int _getItemIndex(int flattenedIndex) {
    int count = 0;
    for (int i = 0; i < flattenedIndex; i++) {
      if (!_flattenedItems[i].isHeader) count++;
    }
    return count;
  }
}

class _GroupedItem<T> {
  final bool isHeader;
  final String? headerTitle;
  final T? data;

  _GroupedItem.header(this.headerTitle) : isHeader = true, data = null;
  _GroupedItem.item(this.data) : isHeader = false, headerTitle = null;
}

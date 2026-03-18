import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../config/y_desktop_column.dart';
import '../../model/y_selection_data.dart';

/// 桌面端文件列表项
class YDesktopFileItem<T> extends StatelessWidget {
  final T item;
  final int index;
  final List<YDesktopColumn<T>> columns;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Function(bool isSecondary)? onPointerDown;
  final double? height;
  final EdgeInsets padding;
  final Color? selectedColor;
  final BorderRadius? borderRadius;

  const YDesktopFileItem({
    super.key,
    required this.item,
    required this.index,
    required this.columns,
    this.selected = false,
    this.onTap,
    this.onDoubleTap,
    this.onPointerDown,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.selectedColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MetaData(
      metaData: YSelectionData(index: index, extra: item),
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onTap: onTap ?? () {},
        onDoubleTap: onDoubleTap,
        onSecondaryTap: () => onPointerDown?.call(true),
        onTertiaryTapDown: (_) => onPointerDown?.call(true), // 某些桌面环境右击处理
        behavior: HitTestBehavior.opaque,
        child: Listener(
          onPointerDown: (event) {
            final isSecondary = event.buttons == kSecondaryMouseButton;
            onPointerDown?.call(isSecondary);
          },
          child: Container(
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: selected 
                  ? (selectedColor ?? theme.primaryColor.withValues(alpha: 0.2)) 
                  : Colors.transparent,
              borderRadius: borderRadius ?? BorderRadius.circular(4),
            ),
            child: Row(
              children: columns.map((col) {
                Widget cell = Container(
                  alignment: Alignment.centerLeft,
                  child: col.itemBuilder(context, item),
                );

                if (col.width != null) {
                  cell = SizedBox(width: col.width, child: cell);
                } else if (col.flex != null) {
                  cell = Expanded(flex: col.flex!, child: cell);
                } else if (col.isExpand) {
                  cell = Expanded(child: cell);
                }

                return cell;
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

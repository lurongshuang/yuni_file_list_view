import 'package:flutter/material.dart';
import '../../config/y_desktop_column.dart';

/// 桌面端文件列表表头
class YDesktopFileHeader<T> extends StatelessWidget {
  final List<YDesktopColumn<T>> columns;
  final double height;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final Color? dividerColor;
  final double dividerWidth;

  const YDesktopFileHeader({
    super.key,
    required this.columns,
    this.height = 36.0,
    this.backgroundColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.dividerColor,
    this.dividerWidth = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = textStyle ?? theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.hintColor,
    );

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: dividerColor ?? theme.dividerColor.withValues(alpha: 0.1),
            width: dividerWidth,
          ),
        ),
      ),
      child: Row(
        children: columns.map((col) {
          Widget cell = Container(
            alignment: Alignment.centerLeft,
            child: Text(
              col.label,
              style: effectiveTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    );
  }
}

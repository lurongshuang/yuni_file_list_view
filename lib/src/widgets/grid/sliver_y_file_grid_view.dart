import 'package:flutter/widgets.dart';
import '../../config/y_file_grid_config.dart';
import '../../model/y_file_item.dart';
import '../../delegate/y_file_item_builder.dart';
import '../../utils/y_grid_column_calculator.dart';
import 'y_file_grid_item.dart';

/// 构建宫格列表的 Sliver 组件
/// 直接返回原生 [SliverPadding] 封装的 [SliverGrid]
SliverPadding buildSliverYFileGridView<T extends YFileItem>({
  Key? key,
  required List<T> items,
  YFileGridConfig config = const YFileGridConfig(),
  YFileGridItemBuilder<T>? itemBuilder,
  YFileItemTapCallback<T>? onTap,
  YFileItemLongPressCallback<T>? onLongPress,
  Set<String>? selectedIds,
  double? availableWidth,
}) {
  final w = availableWidth ?? 0;
  final crossAxisCount = config.isAutoColumn
      ? YGridColumnCalculator.calculate(
          availableWidth: w,
          minItemWidth: config.minItemWidth,
          spacing: config.crossAxisSpacing,
          minColumns: config.minColumns,
          maxColumns: config.maxColumns,
        )
      : config.crossAxisCount;

  return SliverPadding(
    key: key,
    padding: config.padding,
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: config.crossAxisSpacing,
        mainAxisSpacing: config.mainAxisSpacing,
        childAspectRatio: config.childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final isSelected = selectedIds?.contains(item.id) ?? false;

          if (itemBuilder != null) {
            return itemBuilder(context, item, index);
          }

          return YFileGridItem<T>(
            item: item,
            selected: isSelected,
            onTap: onTap != null ? () => onTap(item, index) : null,
            onLongPress: onLongPress != null ? () => onLongPress(item, index) : null,
          );
        },
        childCount: items.length,
      ),
    ),
  );
}

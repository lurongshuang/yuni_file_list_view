import 'package:flutter/widgets.dart';
import '../../config/y_file_grid_config.dart';
import '../../delegate/y_file_item_builder.dart';
import '../../utils/y_grid_column_calculator.dart';

/// 构建宫格列表的 Sliver 组件
/// 直接返回原生 [SliverPadding] 封装的 [SliverGrid]
SliverPadding buildSliverYFileGridView<T>({
  Key? key,
  required List<T> items,
  required YFileGridItemBuilder<T> itemBuilder,
  YFileGridConfig config = const YFileGridConfig(),
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
          return itemBuilder(context, item, index);
        },
        childCount: items.length,
      ),
    ),
  );
}

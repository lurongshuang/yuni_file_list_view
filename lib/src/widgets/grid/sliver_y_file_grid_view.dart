import 'package:flutter/widgets.dart';
import '../../config/y_file_grid_config.dart';
import '../../delegate/y_file_item_builder.dart';
import '../../utils/y_grid_column_calculator.dart';

class SliverYFileGridView<T> extends StatelessWidget {
  final List<T> items;
  final YFileGridItemBuilder<T> itemBuilder;
  final YFileGridConfig config;
  final double? availableWidth;

  const SliverYFileGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.config = const YFileGridConfig(),
    this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
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
}

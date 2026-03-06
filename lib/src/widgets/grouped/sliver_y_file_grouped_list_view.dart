import 'package:flutter/widgets.dart';
import '../../config/y_file_grouped_config.dart';
import '../../model/y_file_group.dart';
import '../../delegate/y_file_item_builder.dart';
import '../../utils/y_grid_column_calculator.dart';

List<Widget> buildSliverYFileGroupedListView<T>({
  Key? key,
  required List<YFileGroup<T>> groups,
  required YFileGroupHeaderBuilder<T> headerBuilder,
  required YFileGroupItemBuilder<T> itemBuilder,
  YFileGroupedConfig config = const YFileGroupedConfig(),
  double? availableWidth,
}) {
  final gridConfig = config.gridConfig;
  final listConfig = config.listConfig;
  final isGrid = config.mode == YFileGroupedMode.grid;

  final w = availableWidth ?? 0;
  final crossAxisCount = gridConfig.isAutoColumn
      ? YGridColumnCalculator.calculate(
          availableWidth: w,
          minItemWidth: gridConfig.minItemWidth,
          spacing: gridConfig.crossAxisSpacing,
          minColumns: gridConfig.minColumns,
          maxColumns: gridConfig.maxColumns,
        )
      : gridConfig.crossAxisCount;

  // 这里的核心思想是：不论用户传进来了多少个组(可能是 1000 个带日期的组)，
  // 如果为每个组创建一个 SliverGrid 或 SliverList，在 Flutter 中将会初始化海量的 RenderSliver，严重卡顿。
  // 因此我们必须在逻辑上“拉平”成一维结构，并全部塞入一个单一的懒加载 SliverList 中。

  final List<_FlatEntity<T>> flatData = [];

  for (var gi = 0; gi < groups.length; gi++) {
    final group = groups[gi];
    final items = group.items;
    
    // 1. 塞入 Header 实体
    flatData.add(_FlatHeaderEntity<T>(groupIndex: gi, group: group));

    // 2. 塞入内容实体
    if (isGrid) {
      // 宫格模式：将每 crossAxisCount 个 item 划分为一行 Row 塞入
      for (var i = 0; i < items.length; i += crossAxisCount) {
        final rowItems = <T>[];
        final rawItemIndices = <int>[];
        for (var j = 0; j < crossAxisCount; j++) {
          if (i + j < items.length) {
            rowItems.add(items[i + j]);
            rawItemIndices.add(i + j);
          }
        }
        flatData.add(_FlatGridRowEntity<T>(
          groupIndex: gi,
          group: group,
          rowItems: rowItems,
          rawItemIndices: rawItemIndices,
        ));
      }
    } else {
      // 列表模式：每个 item 单独一个实体
      for (var i = 0; i < items.length; i++) {
        flatData.add(_FlatListItemEntity<T>(
          groupIndex: gi,
          group: group,
          item: items[i],
          rawItemIndex: i,
        ));
      }
    }
  }

  return [
    SliverPadding(
      padding: isGrid ? gridConfig.padding : listConfig.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entity = flatData[index];

            if (entity is _FlatHeaderEntity<T>) {
              return headerBuilder(context, entity.group, entity.groupIndex);
            } 
            
            else if (entity is _FlatGridRowEntity<T>) {
              // 渲染宫格的一行
              return Row(
                children: List.generate(crossAxisCount, (colIndex) {
                  if (colIndex < entity.rowItems.length) {
                    final itemWidget = itemBuilder(
                      context,
                      entity.group,
                      entity.rowItems[colIndex],
                      entity.groupIndex,
                      entity.rawItemIndices[colIndex],
                    );
                    
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: colIndex < crossAxisCount - 1 ? gridConfig.crossAxisSpacing : 0,
                          top: gridConfig.mainAxisSpacing / 2,
                          bottom: gridConfig.mainAxisSpacing / 2,
                        ),
                        // 通过 AspectRatio 强行约定 Grid 的宽高比约束
                        child: AspectRatio(
                          aspectRatio: gridConfig.childAspectRatio,
                          child: itemWidget,
                        ),
                      ),
                    );
                  } else {
                    return const Expanded(child: SizedBox.shrink()); // 占位填充空余列
                  }
                }),
              );
            } 
            
            else if (entity is _FlatListItemEntity<T>) {
              // 渲染普通列表的一行
              return itemBuilder(
                context,
                entity.group,
                entity.item,
                entity.groupIndex,
                entity.rawItemIndex,
              );
            }
            return const SizedBox.shrink();
          },
          childCount: flatData.length,
        ),
      ),
    )
  ];
}

abstract class _FlatEntity<T> {}

class _FlatHeaderEntity<T> extends _FlatEntity<T> {
  final int groupIndex;
  final YFileGroup<T> group;
  _FlatHeaderEntity({required this.groupIndex, required this.group});
}

class _FlatGridRowEntity<T> extends _FlatEntity<T> {
  final int groupIndex;
  final YFileGroup<T> group;
  final List<T> rowItems;
  final List<int> rawItemIndices;
  _FlatGridRowEntity({required this.groupIndex, required this.group, required this.rowItems, required this.rawItemIndices});
}

class _FlatListItemEntity<T> extends _FlatEntity<T> {
  final int groupIndex;
  final int rawItemIndex;
  final YFileGroup<T> group;
  final T item;
  _FlatListItemEntity({required this.groupIndex, required this.rawItemIndex, required this.group, required this.item});
}

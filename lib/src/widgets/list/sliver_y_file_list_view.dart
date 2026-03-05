import 'package:flutter/material.dart';
import '../../config/y_file_list_config.dart';
import '../../model/y_file_item.dart';
import '../../delegate/y_file_item_builder.dart';
import 'y_file_list_item.dart';

/// 构建纵向列表的 Sliver 组件
/// 直接返回原生 [SliverPadding] 封装的 [SliverList]
SliverPadding buildSliverYFileListView<T extends YFileItem>({
  Key? key,
  required List<T> items,
  YFileListConfig config = const YFileListConfig(),
  YFileListItemBuilder<T>? itemBuilder,
  YFileListSeparatorBuilder? separatorBuilder,
  YFileItemTapCallback<T>? onTap,
  YFileItemLongPressCallback<T>? onLongPress,
  YFileItemSelectCallback<T>? onSelect,
  Set<String>? selectedIds,
}) {
  return SliverPadding(
    key: key,
    padding: config.padding,
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // 奇数索引 = 分割线，偶数索引 = item
          final itemIndex = index ~/ 2;
          if (index.isOdd) {
            if (separatorBuilder != null) {
              return separatorBuilder(context, itemIndex);
            }
            if (!config.showDivider) return const SizedBox.shrink();
            return Divider(
              height: 1,
              thickness: 0.5,
              indent: config.dividerIndent,
              endIndent: 0,
            );
          }
          
          final item = items[itemIndex];
          if (itemBuilder != null) {
            return itemBuilder(context, item, itemIndex);
          }
          final isSelected = selectedIds?.contains(item.id) ?? false;
          return YFileListItem<T>(
            item: item,
            config: config,
            selected: isSelected,
            onTap: onTap != null ? () => onTap(item, itemIndex) : null,
            onLongPress: onLongPress != null ? () => onLongPress(item, itemIndex) : null,
            onCheckChanged: onSelect != null
                ? (val) => onSelect(item, val ?? false)
                : null,
          );
        },
        childCount: items.isEmpty ? 0 : items.length * 2 - 1,
      ),
    ),
  );
}

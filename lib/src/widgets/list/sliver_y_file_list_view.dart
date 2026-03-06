import 'package:flutter/material.dart';
import '../../config/y_file_list_config.dart';
import '../../delegate/y_file_item_builder.dart';


/// 构建纵向列表的 Sliver 组件
/// 直接返回原生 [SliverPadding] 封装的 [SliverList]
SliverPadding buildSliverYFileListView<T>({
  Key? key,
  required List<T> items,
  required YFileListItemBuilder<T> itemBuilder,
  YFileListConfig config = const YFileListConfig(),
  YFileListSeparatorBuilder? separatorBuilder,
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
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          
          final item = items[itemIndex];
          return itemBuilder(context, item, itemIndex);
        },
        childCount: items.isEmpty ? 0 : items.length * 2 - 1,
      ),
    ),
  );
}

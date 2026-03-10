import 'package:flutter/material.dart';
import '../../config/y_file_list_config.dart';
import '../../delegate/y_file_item_builder.dart';

class SliverYFileListView<T> extends StatelessWidget {
  final List<T> items;
  final YFileListItemBuilder<T> itemBuilder;
  final YFileListConfig config;
  final YFileListSeparatorBuilder? separatorBuilder;

  const SliverYFileListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.config = const YFileListConfig(),
    this.separatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: config.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final itemIndex = index ~/ 2;
            if (index.isOdd) {
              final sepBuilder = separatorBuilder;
              if (sepBuilder != null) {
                return sepBuilder(context, itemIndex);
              }
              return const SizedBox.shrink();
            }

            final item = items[itemIndex];
            return itemBuilder(context, item, itemIndex);
          },
          childCount: items.isEmpty ? 0 : items.length * 2 - 1,
        ),
      ),
    );
  }
}

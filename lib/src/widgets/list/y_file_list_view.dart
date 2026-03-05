import 'package:flutter/widgets.dart';
import '../../config/y_file_list_config.dart';
import '../../model/y_file_item.dart';
import '../../delegate/y_file_item_builder.dart';
import 'sliver_y_file_list_view.dart';

/// 纵向文件列表（可独立滚动）
///
/// 内部使用 [CustomScrollView] + [SliverYFileListView] 实现。
/// 需与其他 Sliver 组合时请直接使用 [SliverYFileListView]。
///
/// ```dart
/// YFileListView<MyFile>(
///   items: myFiles,
///   config: YFileListConfig(showCheckbox: true),
///   onTap: (file, i) => print(file.name),
/// )
/// ```
class YFileListView<T extends YFileItem> extends StatelessWidget {
  final List<T> items;
  final YFileListConfig config;
  final YFileListItemBuilder<T>? itemBuilder;
  final YFileListSeparatorBuilder? separatorBuilder;
  final YFileItemTapCallback<T>? onTap;
  final YFileItemLongPressCallback<T>? onLongPress;
  final YFileItemSelectCallback<T>? onSelect;
  final Set<String>? selectedIds;
  final ScrollController? controller;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const YFileListView({
    super.key,
    required this.items,
    this.config = const YFileListConfig(),
    this.itemBuilder,
    this.separatorBuilder,
    this.onTap,
    this.onLongPress,
    this.onSelect,
    this.selectedIds,
    this.controller,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      reverse: reverse,
      physics: physics,
      shrinkWrap: shrinkWrap,
      slivers: [
        buildSliverYFileListView<T>(
          items: items,
          config: config,
          itemBuilder: itemBuilder,
          separatorBuilder: separatorBuilder,
          onTap: onTap,
          onLongPress: onLongPress,
          onSelect: onSelect,
          selectedIds: selectedIds,
        ),
      ],
    );
  }
}

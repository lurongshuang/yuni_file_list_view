import 'package:flutter/material.dart';

/// 桌面端文件列表列配置
class YDesktopColumn<T> {
  final String label;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double? width;
  final int? flex;
  final bool isExpand;

  const YDesktopColumn({
    required this.label,
    required this.itemBuilder,
    this.width,
    this.flex,
    this.isExpand = false,
  }) : assert(width != null || flex != null || isExpand == true);
}

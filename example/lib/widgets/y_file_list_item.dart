import 'package:flutter/material.dart';
import '../models/y_file_item.dart';
import '../models/y_file_list_ui_config.dart';

/// 纵向列表单元格默认实现
///
/// 布局：左侧缩略图（或类型色块）+ 右侧文件名/副标题 + 可选右侧 Checkbox
class YFileListItem<T extends YFileItem> extends StatelessWidget {
  final T item;
  final YFileListUIConfig config;

  /// 是否选中（多选模式）
  final bool selected;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// checkbox 选中变化回调（多选模式）
  final ValueChanged<bool?>? onCheckChanged;

  /// 副标题文本；为 null 时自动拼接日期 + 文件大小
  final String? subtitle;

  const YFileListItem({
    super.key,
    required this.item,
    this.config = const YFileListUIConfig(),
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.onCheckChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedSubtitle = subtitle ?? _buildSubtitle();

    Widget content = Padding(
      padding: config.itemPadding,
      child: Row(
        children: [
          // ── 左侧缩略图 ──
          _buildThumbnail(),
          const SizedBox(width: 12),
          // ── 文件信息 ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (resolvedSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    resolvedSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── 右侧 Checkbox（多选模式）──
          if (config.showCheckbox) ...[
            const SizedBox(width: 8),
            Checkbox(
              value: selected,
              onChanged: onCheckChanged,
              shape: const CircleBorder(),
            ),
          ],
        ],
      ),
    );

    if (config.itemHeight != null) {
      content = SizedBox(height: config.itemHeight, child: content);
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: content,
    );
  }

  Widget _buildThumbnail() {
    final size = config.thumbnailSize;
    final radius = BorderRadius.circular(config.thumbnailBorderRadius);

    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      final isNetwork = item.thumbnailUrl!.startsWith('http://') ||
          item.thumbnailUrl!.startsWith('https://');
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: isNetwork
              ? Image.network(item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildColorBlock(size, radius))
              : Image.asset(item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildColorBlock(size, radius)),
        ),
      );
    }
    return _buildColorBlock(size, radius);
  }

  Widget _buildColorBlock(double size, BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: _colorForType(item.type),
        alignment: Alignment.center,
        child: Text(
          _labelForType(item.type),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (item.modifiedAt != null) {
      final d = item.modifiedAt!;
      parts.add(
          '${d.year}年${d.month}月${d.day}日 ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}');
    }
    if (item.fileSize != null) {
      parts.add(_formatBytes(item.fileSize!));
    }
    return parts.join(' · ');
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Color _colorForType(YFileType type) {
    switch (type) {
      case YFileType.image:
        return const Color(0xFF4A90D9);
      case YFileType.video:
        return const Color(0xFF7B5EA7);
      case YFileType.audio:
        return const Color(0xFF7B5EA7);
      case YFileType.document:
        return const Color(0xFFE05A4E);
      case YFileType.folder:
        return const Color(0xFFF5A623);
      case YFileType.other:
        return const Color(0xFF8E8E93);
    }
  }

  static String _labelForType(YFileType type) {
    switch (type) {
      case YFileType.image:
        return 'IMG';
      case YFileType.video:
        return 'VID';
      case YFileType.audio:
        return 'MP3';
      case YFileType.document:
        return 'PDF';
      case YFileType.folder:
        return 'DIR';
      case YFileType.other:
        return 'FILE';
    }
  }
}

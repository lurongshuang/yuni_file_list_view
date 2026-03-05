import 'package:flutter/material.dart';
import '../../model/y_file_item.dart';

/// 宫格列表单元格默认实现
///
/// 展示文件缩略图（网络/本地），若无缩略图则显示文件类型色块。
/// 通过 [YFileGridView.itemBuilder] 可完全替换此默认实现。
class YFileGridItem<T extends YFileItem> extends StatelessWidget {
  final T item;

  /// 是否选中（显示右下角对勾）
  final bool selected;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  const YFileGridItem({
    super.key,
    required this.item,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 主内容：缩略图 or 类型色块 ──
          _buildContent(),
          // ── 选中蒙层 + 角标 ──
          if (selected) _buildSelectedOverlay(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      return _buildThumbnail(item.thumbnailUrl!);
    }
    return _buildTypePlaceholder();
  }

  Widget _buildThumbnail(String url) {
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildTypePlaceholder(),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildTypePlaceholder(),
    );
  }

  Widget _buildTypePlaceholder() {
    final color = _colorForType(item.type);
    final label = _labelForType(item.type);
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSelectedOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
      ),
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.all(6),
      child: Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.blue),
      ),
    );
  }

  static Color _colorForType(YFileType type) {
    switch (type) {
      case YFileType.image:
        return const Color(0xFF4A90D9);
      case YFileType.video:
        return const Color(0xFF7B5EA7);
      case YFileType.audio:
        return const Color(0xFF7B5EA7); // MP3 紫色（与设计图一致）
      case YFileType.document:
        return const Color(0xFFE05A4E); // PDF 红色（与设计图一致）
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

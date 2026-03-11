import 'package:yuni_file_list_view/yuni_file_list_view.dart';

/// 文件类型枚举
enum YFileType {
  /// 图片（jpg/png/gif/webp 等）
  image,

  /// 视频（mp4/mov/avi 等）
  video,

  /// 音频（mp3/flac/aac 等）
  audio,

  /// 文档（pdf/doc/ppt 等）
  document,

  /// 文件夹
  folder,

  /// 其他未识别类型
  other,
}

/// 文件数据模型基类
///
/// 业务方可继承此类，添加自定义字段，同时兼容所有列表组件。
///
/// ```dart
/// class MyFile extends YFileItem {
///   final String uploaderId;
///   const MyFile({required super.id, required super.name, required this.uploaderId, ...});
/// }
/// ```
class YFileItem implements YRulerScrollbarNode {
  /// 文件唯一标识
  final String id;

  /// 文件名（含扩展名）
  final String name;

  /// 文件本地路径或远程 URL（可选）
  final String? path;

  /// 文件大小（字节），为 null 时不显示
  final int? fileSize;

  /// 最后修改时间
  final DateTime? modifiedAt;

  /// 文件类型，用于宫格色块等默认渲染
  final YFileType type;

  /// 缩略图 URL 或本地路径；为 null 时宫格/列表显示文件类型色块
  final String? thumbnailUrl;

  /// 业务自定义扩展数据（不参与组件内部逻辑）
  final Object? extra;

  const YFileItem({
    required this.id,
    required this.name,
    this.path,
    this.fileSize,
    this.modifiedAt,
    this.type = YFileType.other,
    this.thumbnailUrl,
    this.extra,
  });

  @override
  String get label => name;

  @override
  bool get isMajor => false;

  /// 从当前实例创建一个字段覆写的副本
  YFileItem copyWith({
    String? id,
    String? name,
    String? path,
    int? fileSize,
    DateTime? modifiedAt,
    YFileType? type,
    String? thumbnailUrl,
    Object? extra,
  }) {
    return YFileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      fileSize: fileSize ?? this.fileSize,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      type: type ?? this.type,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      extra: extra ?? this.extra,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YFileItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'YFileItem(id: $id, name: $name, type: $type)';
}

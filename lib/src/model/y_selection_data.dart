/// 选择项元数据
///
/// 用于在 [YDragSelectRegion] 或 [YDesktopSelectionRegion] 中通过 HitTest 或遍历 RenderTree 识别子项目。
class YSelectionData {
  final int index;
  final Object? extra;

  const YSelectionData({required this.index, this.extra});
}

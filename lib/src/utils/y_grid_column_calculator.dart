/// 宫格动态列数计算工具
///
/// 根据可用宽度、单格最小宽度和间距，自动推算最优列数。
/// 为纯函数工具，无副作用，便于单元测试。
class YGridColumnCalculator {
  YGridColumnCalculator._();

  /// 计算列数
  ///
  /// - [availableWidth]：可用总宽度（通常来自 LayoutBuilder）
  /// - [minItemWidth]：每格最小宽度（px）
  /// - [spacing]：列间距
  /// - [minColumns]：最少列数（默认 2）
  /// - [maxColumns]：最多列数（默认 10）
  ///
  /// 计算逻辑：`columns = floor((availableWidth + spacing) / (minItemWidth + spacing))`
  /// 最终结果 clamp 在 [minColumns, maxColumns] 范围内。
  static int calculate({
    required double availableWidth,
    required double minItemWidth,
    required double spacing,
    int minColumns = 2,
    int maxColumns = 10,
  }) {
    assert(minItemWidth > 0, 'minItemWidth must be > 0');
    assert(minColumns >= 1, 'minColumns must be >= 1');
    assert(maxColumns >= minColumns, 'maxColumns must be >= minColumns');

    if (availableWidth <= 0) return minColumns;

    final columns = ((availableWidth + spacing) / (minItemWidth + spacing)).floor();
    return columns.clamp(minColumns, maxColumns);
  }
}

// 此文件为组件库测试占位，原 plugin 测试文件已清理。
// 组件库单元测试请在此目录下参考 test/ 中示例编写。
import 'package:flutter_test/flutter_test.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';

void main() {
  group('YGridColumnCalculator', () {
    test('固定列数：不启用自动计算', () {
      const config = YFileGridConfig(crossAxisCount: 3);
      expect(config.isAutoColumn, false);
    });

    test('自动列数：crossAxisCount=0 时启用', () {
      const config = YFileGridConfig(crossAxisCount: 0);
      expect(config.isAutoColumn, true);
    });

    test('calculate: 宽度 300px、每格 90px、间距 2 => 3列', () {
      final count = YGridColumnCalculator.calculate(
        availableWidth: 300,
        minItemWidth: 90,
        spacing: 2,
      );
      expect(count, 3);
    });

    test('calculate: 宽度 600px、每格 90px、间距 2 => 6列', () {
      final count = YGridColumnCalculator.calculate(
        availableWidth: 600,
        minItemWidth: 90,
        spacing: 2,
      );
      expect(count, 6);
    });

    test('calculate: 超出 maxColumns 时 clamp 到 maxColumns', () {
      final count = YGridColumnCalculator.calculate(
        availableWidth: 2000,
        minItemWidth: 90,
        spacing: 2,
        maxColumns: 8,
      );
      expect(count, 8);
    });
  });

}

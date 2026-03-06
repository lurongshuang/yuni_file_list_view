import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';

/// 模拟数据中心
class DemoData {
  static final List<YFileItem> gridItems = List.generate(1120, (i) {
    final types = [YFileType.image, YFileType.video];
    final type = types[i % types.length];
    // 分散在过去三年的不同月份
    final date = DateTime(2023 + (i ~/ 40), 1 + (i % 12), 1 + (i % 28));
    return YFileItem(
      id: 'photo_$i',
      name: 'IMG_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_$i.jpg',
      type: type,
      modifiedAt: date,
      thumbnailUrl: 'https://picsum.photos/seed/photo$i/300/300',
    );
  });

  static List<YFileGroup<YFileItem>> getGroupsByDimension(String dimension) {
    final Map<String, List<YFileItem>> map = {};
    
    for (var item in gridItems) {
      final date = item.modifiedAt ?? DateTime.now();
      String key;
      if (dimension == 'year') {
        key = '${date.year}年';
      } else if (dimension == 'month') {
        key = '${date.year}年${date.month}月';
      } else {
        key = '${date.year}年${date.month}月${date.day}日';
      }
      
      if (!map.containsKey(key)) map[key] = [];
      map[key]!.add(item);
    }

    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a)); // 倒序排
    return keys.map((k) => YFileGroup(
      groupId: k,
      groupTitle: k,
      items: map[k]!,
    )).toList();
  }

  static final List<YFileItem> listItems = List.generate(40, (i) {
    final types = YFileType.values;
    final type = types[i % types.length];
    return YFileItem(
      id: 'list_$i',
      name: '项目文档_v${i + 1}${type == YFileType.document ? '.pdf' : ''}',
      type: type,
      fileSize: (500 + i * 88) * 1024,
      modifiedAt: DateTime(2025, 4, 15, 9, i % 60),
      thumbnailUrl: type == YFileType.image ? 'https://picsum.photos/seed/list$i/100/100' : null,
    );
  });

  static final List<YFileGroup<YFileItem>> groupedItems = [
    YFileGroup(
      groupId: 'g1',
      groupTitle: '2025年5月 海南三亚',
      items: List.generate(12, (i) => YFileItem(
        id: 'g1_$i',
        name: '三亚_$i.jpg',
        type: YFileType.image,
        thumbnailUrl: 'https://picsum.photos/seed/sanya$i/200/200',
      )),
    ),
    YFileGroup(
      groupId: 'g2',
      groupTitle: '2025年4月 云南大理',
      items: List.generate(8, (i) => YFileItem(
        id: 'g2_$i',
        name: '大理_$i.jpg',
        type: YFileType.image,
        thumbnailUrl: 'https://picsum.photos/seed/dali$i/200/200',
      )),
    ),
    YFileGroup(
      groupId: 'g3',
      groupTitle: '2025年3月 四川成都',
      items: List.generate(24, (i) => YFileItem(
        id: 'g3_$i',
        name: '成都_$i.jpg',
        type: YFileType.image,
        thumbnailUrl: 'https://picsum.photos/seed/chengdu$i/200/200',
      )),
    ),
    YFileGroup(
      groupId: 'g4',
      groupTitle: '2025年2月 西藏拉萨',
      items: List.generate(5, (i) => YFileItem(
        id: 'g4_$i',
        name: '拉萨_$i.mp4',
        type: YFileType.video,
      )),
    ),
    YFileGroup(
      groupId: 'g5',
      groupTitle: '2025年1月 黑龙江哈尔滨',
      items: List.generate(30, (i) => YFileItem(
        id: 'g5_$i',
        name: '哈尔滨_$i.jpg',
        type: YFileType.image,
        thumbnailUrl: 'https://picsum.photos/seed/haerbin$i/200/200',
      )),
    ),
  ];
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 桌面端选择控制器
///
/// 负责管理多选状态，并处理 Shift / Cmd (Ctrl) 等修饰键逻辑。
class YDesktopSelectionController extends ChangeNotifier {
  final Set<int> _selectedIndices = {};
  int? _lastClickedIndex;

  /// 选中状态变更回调，方便外部同步状态（如同步到 List<String> IDs）
  void Function(Set<int> selectedIndices)? onSelectionChanged;

  /// 当前选中的所有索引
  Set<int> get selectedIndices => _selectedIndices;

  @override
  void notifyListeners() {
    super.notifyListeners();
    onSelectionChanged?.call(_selectedIndices);
  }

  /// 是否选中
  bool isSelected(int index) => _selectedIndices.contains(index);

  /// 处理点击事件
  /// [isSecondary] 是否为右键点击（通常右键如果点击在未选中项上，会选中该项并取消其他选中；如果点击在已选中项上，保持现状）
  void handleTap(int index, {bool isSecondary = false}) {
    final bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final bool isMetaPressed = HardwareKeyboard.instance.isMetaPressed || 
                              HardwareKeyboard.instance.isControlPressed;

    if (isSecondary) {
      if (!_selectedIndices.contains(index)) {
        _selectedIndices.clear();
        _selectedIndices.add(index);
        _lastClickedIndex = index;
      }
    } else if (isShiftPressed && _lastClickedIndex != null) {
      // Shift 连选
      _selectRange(_lastClickedIndex!, index);
    } else if (isMetaPressed) {
      // Cmd/Ctrl 切换选中
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _lastClickedIndex = index;
    } else {
      // 普通单选
      _selectedIndices.clear();
      _selectedIndices.add(index);
      _lastClickedIndex = index;
    }
    notifyListeners();
  }

  /// 范围选择
  void _selectRange(int from, int to) {
    if (!HardwareKeyboard.instance.isMetaPressed && !HardwareKeyboard.instance.isControlPressed) {
        _selectedIndices.clear();
    }
    final int start = from < to ? from : to;
    final int end = from < to ? to : from;
    for (int i = start; i <= end; i++) {
      _selectedIndices.add(i);
    }
  }

  /// 批量更新选中状态（用于框选）
  /// [indices] 当前框选选中的索引集合
  /// [isMerge] 是否与现有选中合并（通常框选开始时会根据修饰键决定是否清除旧的）
  void updateSelection(Set<int> indices, {bool isMerge = false}) {
    if (!isMerge) {
      _selectedIndices.clear();
    }
    _selectedIndices.addAll(indices);
    notifyListeners();
  }

  /// 清除所有选中
  void clearSelection() {
    if (_selectedIndices.isNotEmpty) {
      _selectedIndices.clear();
      _lastClickedIndex = null;
      notifyListeners();
    }
  }

  /// 选中所有
  void selectAll(int count) {
    _selectedIndices.clear();
    for (int i = 0; i < count; i++) {
      _selectedIndices.add(i);
    }
    notifyListeners();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'map_initialized_model.g.dart';

@riverpod
class MapInitializedModel extends _$MapInitializedModel {
  @override
  bool build() => true;

  void changeInit() {
    state = false;
  }
}

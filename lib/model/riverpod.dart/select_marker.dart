import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_marker.g.dart';

// 簡易検索処理
@riverpod
class SelectMarker extends _$SelectMarker {

  @override
  bool build() => false;

  Future<void> selectMarker() async {
    state = true;
  }
}

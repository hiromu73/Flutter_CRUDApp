import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'textpredictions.g.dart';

@riverpod
class TextPredictions extends _$TextPredictions {
  @override
  List<String>? build() => [];

  void noneList() {
    state = [];
  }

  void changeList(value) {
    state?.add(value);
  }
}

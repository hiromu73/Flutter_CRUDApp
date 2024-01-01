import 'package:google_place/google_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'textpredictions.g.dart';

@riverpod
class TextPredictions extends _$TextPredictions {
  @override
  List<AutocompletePrediction>? build() => [];

  void noneList() {
    state = [];
  }

  void changeList(value) {
    state?.add(value);
  }
}

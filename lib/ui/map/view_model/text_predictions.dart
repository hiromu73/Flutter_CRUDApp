import 'package:google_place/google_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'text_predictions.g.dart';

@riverpod
class TextPredictions extends _$TextPredictions {
  @override
  AutocompleteResponse? build() => null;

  void noneList() {
    state = null;
  }

  void changeList(value) {
    print(value);
    state = value;
  }
}

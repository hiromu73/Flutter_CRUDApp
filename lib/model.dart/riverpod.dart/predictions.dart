import 'package:flutter_crudapp/api.dart';
import 'package:google_place/google_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'predictions.g.dart';

@riverpod
class Predictions extends _$Predictions {
  final _googlePlace = GooglePlace(Api.apiKey);

  @override
  List<AutocompletePrediction> build() => [];

  // 検索処理
  Future<void> autoCompleteSearch(String value) async {
    final result = await _googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      state = result.predictions!;
    }
  }
}

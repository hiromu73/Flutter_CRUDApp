import 'package:google_place/google_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'predictions.g.dart';

@riverpod
class Predictions extends _$Predictions {
  @override
  List<AutocompletePrediction>? build() => [];

  void changePredictions(List<AutocompletePrediction> predictions) {
    for (var prediction in predictions) {
      state?.add(prediction);
      print("$prediction");
    }
  }
}

      // print("Description: ${prediction.description}");
      // print("Place ID: ${prediction.placeId}");

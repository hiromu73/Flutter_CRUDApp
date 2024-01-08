import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'latitude.g.dart';

@riverpod
class Latitude extends _$Latitude {
  @override
  double build() => 0.0;

  void changeLatitude(double latitude) {
    state = latitude;
  }
}

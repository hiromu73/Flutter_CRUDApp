import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'latitude.g.dart';

@riverpod
class Latitude extends _$Latitude {
  @override
  double build() => 0.0;
}

@riverpod
Future<Position> currentPosition(CurrentPositionRef ref) async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  return position;
}

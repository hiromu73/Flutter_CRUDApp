import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// constants

// 命名規則ファイル名.g.dart
part 'latitude.g.dart';

Completer controller = Completer();

@riverpod
class latitude extends _$latitude {
  // LatLng _location = const LatLng(34.758663, 135.4971856623888);
  @override
  double build() => 0.0;

  void changePosition(double latitude) {
    state = latitude;
  }

  // 位置情報とマーカーIDを指定してマーカーを表示する関数
  Set<Marker> createMaker(LatLng latLng, String markerId) {
    return {
      Marker(
        markerId: MarkerId(markerId),
        position: latLng,
      ),
    };
  }
}

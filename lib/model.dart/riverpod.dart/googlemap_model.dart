import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// constants
import 'package:flutter_crudapp/constants/routes.dart' as routes;

// 命名規則ファイル名.g.dart
part 'googlemap_model.g.dart';

Completer controller = Completer();

@riverpod
class GooglemapModel extends _$GooglemapModel {
  LatLng _location = const LatLng(34.758663, 135.4971856623888);
  @override
  LatLng build() => const LatLng(34.758663, 135.4971856623888);

  void changePosition(LatLng latLang) {
    state = latLang;
  }
}

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
  @override
  CameraPosition build () => const CameraPosition(
    // 最初に描画される位置を指定 (現在は固定値を入れているが現在地にしたい)
    target: LatLng(35.17176088096857, 136.88817886263607),
    zoom: 14.4746,
  );
}

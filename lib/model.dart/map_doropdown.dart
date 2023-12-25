import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'map_doropdown.g.dart';

@riverpod
class MapDoropDown extends _$MapDoropDown {
  @override
  String? build() => "";

  void changeList(value) {
    state = value;
  }
}

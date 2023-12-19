import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'googlemap_model.g.dart';

@riverpod
class FirebaseModel extends _$FirebaseModel {
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> build() =>
      FirebaseFirestore.instance.collection('post').orderBy('date').snapshots();
}

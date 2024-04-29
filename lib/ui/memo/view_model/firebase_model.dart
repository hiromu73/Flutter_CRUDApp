import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_model.g.dart';

@riverpod
class FirebaseModel extends _$FirebaseModel {
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> build() =>
      FirebaseFirestore.instance
          .collection('post')
          .orderBy('date', descending: true)
          .snapshots();

  Future<bool> changeView() async {
    return true;
  }
}

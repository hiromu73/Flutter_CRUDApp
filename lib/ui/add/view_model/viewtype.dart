import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'viewtype.g.dart';

@riverpod
class ViewType extends _$ViewType {
  @override
  CollectionReference build() =>
      FirebaseFirestore.instance.collection('viewType');

  // Future<bool> changeViewType(bool viewType) async {
  //   return state.;
  // }
}

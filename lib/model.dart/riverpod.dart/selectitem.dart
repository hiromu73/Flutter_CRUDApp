import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selectitem.g.dart';

@riverpod
class SelectItems extends _$SelectItems {
  @override
  String build() => "";

  Future<void> Add(String value) async {
    state += "$value,";
  }

  Future<void> None() async {
    state = "";
  }
}

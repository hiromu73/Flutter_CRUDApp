import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_item.g.dart';

@riverpod
class SelectItems extends _$SelectItems {
  @override
  String build() => "";

  Future<void> add(String value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    state += "$value,";
  }

  Future<void> remove(String value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    state = state.replaceAll("$value,", "");
  }

  Future<void> none() async {
    await Future.delayed(const Duration(milliseconds: 100));
    state = "";
  }
}

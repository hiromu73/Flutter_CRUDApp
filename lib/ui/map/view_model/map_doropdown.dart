import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_doropdown.g.dart';

@riverpod
class MapDoropDown extends _$MapDoropDown {
  @override
  String build() => '';

  void changeList(value) {
    state = value;
  }
}

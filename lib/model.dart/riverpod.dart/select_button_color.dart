import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_button_color.g.dart';

@riverpod
class SelectButtonColor extends _$SelectButtonColor {
  @override
  Color build() => Colors.white;

  Future<void> buttonChangeSelectColor() async {
    state = Colors.blue;
    print("buttonChangeSelectColor-blue");
    print(state);
  }

  Future<void> changeButtonDefalutColor() async {
    state = Colors.white;
    print("changeButtonDefalutColor-white");
    print(state);
  }
}

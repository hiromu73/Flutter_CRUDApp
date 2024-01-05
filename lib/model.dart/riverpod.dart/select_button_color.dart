import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_button_color.g.dart';

@riverpod
class SelectButtonColor extends _$SelectButtonColor {
  @override
  Color build() => Colors.white;

  void selectButtonChangeColor() {
    state = Colors.blue;
  }

  void changeButtonDefalutColor() {
    state = Colors.white;
  }
}

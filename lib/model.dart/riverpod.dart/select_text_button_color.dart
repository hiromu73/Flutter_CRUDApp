import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'select_text_button_color.g.dart';

@riverpod
class SelectTextButtonColor extends _$SelectTextButtonColor {
  @override
  Color? build() => null;

  void changeTextButtonColor() {
    state = Colors.blue;
  }

  void defaltTextButtonColor() {
    state = null;
  }
}

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_text_button_color.g.dart';

@riverpod
class SelectTextButtonColor extends _$SelectTextButtonColor {
  @override
  Color? build() => Colors.black;

  Future<void> changeTextButtonColor() async {
    state = Colors.white;
    print("changeTextButtonColor-white");
    print(state);
  }

  Future<void> defaltTextButtonColor() async {
    state = Colors.black;
    print("defaltTextButtonColor-black");
    print(state);
  }
}

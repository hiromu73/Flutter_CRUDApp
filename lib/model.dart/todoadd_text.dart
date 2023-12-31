import 'package:flutter/material.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 命名規則ファイル名.g.dart
part 'todoadd_text.g.dart';

@riverpod
class ToDoAdd_Rext extends _$ToDoAdd_Rext {
  @override
  String build() => '';

  void textFromUp() {
    TextFormField(
        maxLength: null,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          fillColor: Colors.grey[100],
          filled: true,
          isDense: true,
          hintText: memo,
          hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
          prefixIcon: const Icon(Icons.create),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
        ),
        textAlign: TextAlign.left,
        onChanged: (String value) async {
          print(value);
          state = value;
        });
  }
}

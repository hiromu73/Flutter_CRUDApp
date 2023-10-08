import 'package:flutter/material.dart';

// ドロップダウン
class DropdownButton extends StatefulWidget {
  const DropdownButton(
      {super.key,
      required Null Function(String value) onChanged,
      required List<DropdownMenuItem<String>> items,
      required value});

  @override
  State<DropdownButton> createState() => _DropdownButtonState();
}

class _DropdownButtonState extends State<DropdownButton> {
  String isSelectedValue = ' ';
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        items: const [
          DropdownMenuItem(
            value: "スーパー",
            child: Text("スーパー"),
          ),
          DropdownMenuItem(
            value: "薬局",
            child: Text("薬局"),
          ),
          DropdownMenuItem(
            value: "レストラン",
            child: Text("レストラン"),
          ),
          DropdownMenuItem(
            value: "ファーストフード",
            child: Text("ファーストフード"),
          ),
          DropdownMenuItem(
            value: "カフェ",
            child: Text("カフェ"),
          ),
          DropdownMenuItem(
            value: "本屋",
            child: Text("本屋"),
          ),
        ],
        value: isSelectedValue,
        onChanged: (String value) {
          setState(() {
            isSelectedValue = value;
          });
        });
  }
}

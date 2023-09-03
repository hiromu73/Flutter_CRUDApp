import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 場所の検索ページ
class SerachPage extends ConsumerWidget {
  const SerachPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("場所の検索"),
      ),
      body: Container(
        color: Colors.yellow[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              onChanged: (value) {},
              decoration: InputDecoration(
                  hintText: "検索した場所を入力",
                  hintStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w100),
                  prefixIcon: IconButton(
                      color: Colors.grey[300],
                      icon: const Icon(Icons.search),
                      onPressed: () {})),
            ),
          ],
        ),
      ),
    );
  }
}

// 検索フォーム

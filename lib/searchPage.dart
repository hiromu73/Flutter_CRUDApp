import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_place/google_place.dart';

// 場所の検索ページ

class SerachPage extends ConsumerWidget {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  final apiKey = Api.apiKey;

  SerachPage({super.key});

  void initState() {
    googlePlace = GooglePlace(apiKey);
    // initState()はFutureできないのでメソッドを格納。
    initState();
  }

  // 検索処理
  void autoCompleteSearch(String value) async {
    final result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      predictions = result.predictions!;
    }
  }

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
              onChanged: (value) {
                if (value.isNotEmpty) {
                  autoCompleteSearch(value);
                } else {}
              },
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

// initState()はFutureできないのでメソッドを格納。
Future initState() async {}

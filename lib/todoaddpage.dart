import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/searchPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_place/google_place.dart';
import 'setgooglemap.dart';
import './todoapp.dart';

// Textの状態管理
final infoTextProvider = StateProvider.autoDispose((ref) => "");

// 位置の状態管理
final locationProvider = StateProvider.autoDispose((ref) => "");

// 位置マーカーの状態管理
final makerProvider = StateProvider.autoDispose((ref) => "");

// ユーザー情報の状態管理
final userProvider =
    StateProvider.autoDispose((ref) => FirebaseAuth.instance.currentUser);

// メモ内容の状態管理
final memoProvider = StateProvider.autoDispose((ref) => "");

// StreamProviderを使うことでStreamも扱うことができる
// ※ autoDisposeを付けることで自動的に値をリセットできます
final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

// 投稿ページ
class TodoAddPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider.notifier).state!;
    final messageText = ref.watch(memoProvider.notifier).state;
    final postLocation = ref.watch(locationProvider.notifier).state;
    final postMaker = ref.watch(makerProvider.notifier).state;

    final apiKey = Api.apiKey;

    // 検索結果を格納
    List<AutocompletePrediction> predictions = [];

    @override
    void initState() {
      GooglePlace googlePlace = GooglePlace(apiKey);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("投稿画面"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(const ToDoApp());
            }),
      ),
      body: Center(
        child: Container(
          color: Colors.yellow[100],
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 買い物入力
              TextFormField(
                maxLength: null,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                    hintText: "メモ内容",
                    hintStyle:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w100),
                    prefixIcon: Icon(Icons.mms_outlined),
                    border: OutlineInputBorder()),
                textAlign: TextAlign.left,
                onChanged: (String value) {
                  ref.read(memoProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  child: const Text("場所の検索"),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const SerachPage();
                    }));
                  }),
              const SizedBox(height: 8),
              Text(postLocation),
              ElevatedButton(
                  child: const Text("登録"),
                  onPressed: () async {
                    final date = DateTime.now().toLocal().toIso8601String();
                    final email = user.email;
                    await FirebaseFirestore.instance
                        .collection('post')
                        .doc()
                        .set({
                      'text': ref.watch(memoProvider.notifier).state,
                      'email': email,
                      // 位置情報
                      // 'point': ref.watch(postProvider.notifier).state,
                      'date': date,
                    });
                    Navigator.of(context).pop();
                  })
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.map),
          onPressed: () {
            // mapへ移動する
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MapSample();
            }));
          }),
    );
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'setgooglemap.dart';
import './todoapp.dart';

// メールアドレスの状態管理
final mailAdress = StateProvider.autoDispose((ref) => "");

// パスワードの状態管理
final password = StateProvider.autoDispose((ref) => "");

// Textの状態管理
final infoTextProvider = StateProvider.autoDispose((ref) => "");

// 位置の状態管理
final locationProvider = StateProvider.autoDispose((ref) => "");

// 位置マーカーの状態管理
final makerProvider = StateProvider.autoDispose((ref) => "");

// ユーザー情報の状態管理
final userProvider =
    StateProvider.autoDispose((ref) => FirebaseAuth.instance.currentUser);

// 投稿内容の状態管理
final messageProvider = StateProvider.autoDispose((ref) => "");

// StreamProviderを使うことでStreamも扱うことができる
// ※ autoDisposeを付けることで自動的に値をリセットできます
final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

// 投稿ページ
class TodoAddPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider.notifier).state!;
    final messageText = ref.watch(messageProvider.notifier).state;
    final postLocation = ref.watch(locationProvider.notifier).state;
    final postMaker = ref.watch(makerProvider.notifier).state;

    return Scaffold(
      appBar: AppBar(
        title: Text("投稿画面"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(ToDoApp());
            }),
      ),
      body: Center(
        child: Container(
          color: Colors.yellow[100],
          padding: EdgeInsets.all(32),
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
                    prefixIcon: Icon(Icons.mms_outlined),
                    border: OutlineInputBorder()),
                textAlign: TextAlign.left,
                onChanged: (String value) {
                  ref.read(messageProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  icon: Icon(Icons.pin_drop, color: Colors.red[100]),
                  label: const Text("位置情報の取得"),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MapSample();
                    }));
                    // 位置情報の取得
                    // ref.read(postProvider.notifier).state = value;
                  }),
              const SizedBox(height: 8),
              Text(postLocation),
              const SizedBox(height: 8),
              ElevatedButton(
                  child: Text("投稿"),
                  onPressed: () async {
                    final date = DateTime.now().toLocal().toIso8601String();
                    final email = user.email;
                    await FirebaseFirestore.instance
                        .collection('post')
                        .doc()
                        .set({
                      'text': ref.watch(messageProvider.notifier).state,
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
          child: Icon(Icons.map),
          onPressed: () {
            // mapへ移動する
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MapSample();
            }));
          }),
    );
  }
}

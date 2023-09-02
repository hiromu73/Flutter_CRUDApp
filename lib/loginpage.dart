import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// 投稿位置情報内容の状態管理
final postProvider = StateProvider.autoDispose((ref) => "");

// StreamProviderを使うことでStreamも扱うことができる
// ※ autoDisposeを付けることで自動的に値をリセットできます
final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //password
    final newPassword = ref.watch(password);
    final newMailAdress = ref.watch(mailAdress);
    final infoText = ref.watch(infoTextProvider);

    return Scaffold(
      body: Center(
        child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // メールアドレスの入力
                TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "メールアドレス"),
                  onChanged: (String value) {
                    ref.read(mailAdress.notifier).state = value;
                  },
                ),
                const SizedBox(height: 8),
                // パスワードの入力
                TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "パスワード"),
                  // 見えない様にする
                  obscureText: true,
                  onChanged: (String value) {
                    ref.read(password.notifier).state = value;
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      child: Text("新規登録"),
                      onPressed: () async {
                        try {
                          final UserCredential credentialUser =
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                            email: newMailAdress,
                            password: newPassword,
                          );
                          // ユーザー情報の更新
                          ref.read(userProvider.notifier).state =
                              credentialUser.user;
                          await Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                            return ToDoApp();
                          }));
                        } catch (e) {
                          ref.read(infoTextProvider.notifier).state =
                              "新規登録できません。原因は${e.toString()}";
                        }
                      }),
                ),
                Container(
                  width: double.infinity,
                  child: OutlinedButton(
                      child: Text("ログイン"),
                      onPressed: () async {
                        try {
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.signInWithEmailAndPassword(
                            email: newMailAdress,
                            password: newPassword,
                          );
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return ToDoApp();
                            }),
                          );
                        } catch (e) {
                          ref.read(infoTextProvider.notifier).state =
                              "Not Login。原因は${e.toString()}";
                        }
                      }),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(infoText),
                ),
              ],
            )),
      ),
    );
  }
}

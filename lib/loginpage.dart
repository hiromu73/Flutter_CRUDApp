import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './todoapp.dart';
import 'main.dart';

// ユーザー情報の状態管理
final userProvider =
    StateProvider.autoDispose((ref) => FirebaseAuth.instance.currentUser);

// インスタンス
const storage = FlutterSecureStorage();

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //password
    final newPassword = ref.watch(password);
    final newMailAdress = ref.watch(mailAdress);
    final infoText = ref.watch(infoTextProvider);

    return Scaffold(
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(24),
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
                // SizedBoxとContainerの違い
                // width,heightを設定しコンパイル定数として定義できる。
                // Containerはpadding, transformなど他のレイアウトの制約も設定することが出来る。
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      child: const Text("新規登録"),
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
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      child: const Text("ログイン"),
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(infoText),
                ),
              ],
            )),
      ),
    );
  }
}

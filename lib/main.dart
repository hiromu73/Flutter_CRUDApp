import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'loginpage.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter CrudApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

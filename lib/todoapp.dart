import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './todoaddpage.dart';
import './main.dart';

// StreamProviderを使うことでStreamも扱うことができる
// ※ autoDisposeを付けることで自動的に値をリセットできます
// StreamProviderを使うことでref.watchできる
final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

    // ユーザー情報の状態管理
final userProvider =
    StateProvider.autoDispose((ref) => FirebaseAuth.instance.currentUser);

// Todoの一覧を表示
class ToDoApp extends ConsumerWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから値を受け取る
    final User user = ref.watch(userProvider.notifier).state!;

    // AsyncValueは非同期的に更新されるデータを安全に取り扱うためにRiverPodに内包されている
    // QuerySnapshotはcollection内を取得する際に使用
    // DocumentSnapshotはドキュメント内を取得する際に使用
    final AsyncValue<QuerySnapshot> asyncPostsQuery =
        ref.watch(postQueryProvider);

    return Scaffold(
      appBar: AppBar(
          title: const Text("TodoList"),
          leading: IconButton(
              // ログアウトする
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return MyApp();
                }));
              },
              icon: const Icon(Icons.logout))),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Text("ログインユーザー: ${user.email}"),
          ),
          Expanded(
            // 値が取得できた時
            child: asyncPostsQuery.when(
              data: (QuerySnapshot query) {
                return ListView(
                  // ドキュメントを取得する
                  children: query.docs.map((DocumentSnapshot document) {
                    return Card(
                      child: ListTile(
                        // ここを変える
                        title: Text(document['text']),
                        subtitle: Text(document['email']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // ダイアログ(削除確認を行う)
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text("このメモを削除しますか？"),
                                    actions: [
                                      CupertinoDialogAction(
                                          isDefaultAction: true,
                                          onPressed: () async {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('post')
                                                  .doc(document.id)
                                                  .delete();
                                              Navigator.pop(context);
                                            } catch (e) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return CupertinoAlertDialog(
                                                      content: Text(
                                                          "削除できませんでした。${e.toString()}"),
                                                    );
                                                  });
                                            }
                                          },
                                          child: const Text('OK')),
                                      CupertinoDialogAction(
                                          child: const Text('NO'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (e, stackTrace) {
                return Center(
                  child: Text(e.toString()),
                );
              },
            ),
          ),
        ],
      ),
      // 投稿ページに遷移する
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TodoAddPage();
            }));
          }),
    );
  }
}

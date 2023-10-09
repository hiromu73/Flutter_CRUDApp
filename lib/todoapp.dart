import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './todoaddpage.dart';
import './main.dart';

// StreamProviderを使うことでStreamも扱うことができる
// ※ autoDisposeを付けることで自動的に値をリセットできます
// StreamProviderを使うことでref.watchできる
final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

// Todoの一覧を表示
class ToDoApp extends ConsumerWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                await Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return const MyApp();
                }));
              },
              icon: const Icon(Icons.logout))),
      body: Column(
        children: [
          Expanded(
            // 値が取得できた時
            child: asyncPostsQuery.when(
              data: (QuerySnapshot query) {
                return ListView(
                  // ドキュメントを取得する
                  children: query.docs.map((DocumentSnapshot document) {
                    return Card(
                      elevation: 2,
                      // margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: ListTile(
                        // ここに情報を追加していく。
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
                                              return Navigator.pop(context);
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
              return const TodoAddPage();
            }));
          }),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// constants
import 'package:flutter_crudapp/constants/routes.dart' as routes;

final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

// アラームの有無
final alertProvider = StreamProvider.autoDispose<List<bool>>(
  (ref) => FirebaseFirestore.instance
      .collection('post')
      .orderBy('date')
      .snapshots()
      .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => doc['alert'] as bool).toList()),
);

// Todoの一覧を表示
class ToDoApp extends ConsumerWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AsyncValueは非同期的に更新されるデータを安全に取り扱うためにRiverPodに内包されている
    final AsyncValue<QuerySnapshot> asyncPostsQuery =
        ref.watch(postQueryProvider);
    final alertData = ref.watch(alertProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("TodoList"),
      ),
      body: Column(
        children: [
          Expanded(
            child: asyncPostsQuery.when(
              data: (QuerySnapshot query) {
                return ListView(
                  children: query.docs.map((DocumentSnapshot document) {
                    return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: ListTile(
                          leading: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: const Text(deleteMemo),
                                      actions: [
                                        CupertinoDialogAction(
                                            isDefaultAction: true,
                                            onPressed: () async {
                                              try {
                                                String docId = document.id;
                                                await FirebaseFirestore.instance
                                                    .collection('post')
                                                    .doc(docId)
                                                    .delete();
                                                Navigator.pop(context);
                                              } catch (e) {
                                                return Navigator.pop(context);
                                              }
                                            },
                                            child: const Text(ok)),
                                        CupertinoDialogAction(
                                            child: const Text(no),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }),
                                      ],
                                    );
                                  });
                            },
                          ),
                          title: Text(document['text']),
                          trailing: CupertinoSwitch(
                              activeColor: Colors.amber,
                              trackColor: Colors.grey,
                              value: document['alert'],
                              onChanged: (value) async {
                                try {
                                  String docId = document.id;
                                  await FirebaseFirestore.instance
                                      .collection('post')
                                      .doc(docId)
                                      .update({
                                    'alert': value,
                                  });
                                } catch (e) {
                                  print(e);
                                }
                                // ref.read(alertProvider).state = value;
                              }),
                        ));
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => routes.toDoAddPage(context: context)),
    );
  }
}

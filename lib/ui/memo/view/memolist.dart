import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/constants/string.dart';
import 'package:memoplace/ui/memo/view_model/firebase_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoList extends HookConsumerWidget {
  const MemoList(this.viewType, {super.key});
  final bool viewType;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AsyncValueは非同期的に更新されるデータを安全に取り扱うためにRiverPodに内包されている
    final AsyncValue<QuerySnapshot> firebaseCollection =
        ref.watch(firebaseModelProvider);
    return firebaseCollection.when(
      data: (QuerySnapshot query) {
        return viewType
            ? buildViewListView(query, context)
            : buildGridView(query, context);
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
    );
  }

  Widget buildViewListView(QuerySnapshot query, BuildContext context) {
    return ListView(
      children: query.docs.map((DocumentSnapshot document) {
        return Dismissible(
          key: Key(document.id),
          background: Container(
              color: Colors.grey,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text("Delete")),
          onDismissed: (DismissDirection direction) async {
            try {
              String docId = document.id;
              await FirebaseFirestore.instance
                  .collection('post')
                  .doc(docId)
                  .delete();
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                ListTile(
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
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                              ),
                            );
                          }
                        }
                      }),
                  subtitle: Column(
                    children: [
                      document['checkName'] != null
                          ? Text("位置情報:${document['checkName']}".toString())
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      color: Colors.grey,
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
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
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
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildGridView(QuerySnapshot query, BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 0.8),
      children: query.docs.map((DocumentSnapshot document) {
        return Dismissible(
          key: Key(document.id),
          background: Container(
              color: Colors.grey,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text("Delete")),
          onDismissed: (DismissDirection direction) async {
            try {
              String docId = document.id;
              await FirebaseFirestore.instance
                  .collection('post')
                  .doc(docId)
                  .delete();
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: InkWell(
            onTap: (() => print("aaaa")), // cardがタップされた時の処理
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    child: Text(
                      document['text'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: document['checkName'] != null
                          ? Text("場所\n・${document['checkName']}")
                          : const SizedBox.shrink(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          color: Colors.grey,
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
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
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
                        CupertinoSwitch(
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
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                    ),
                                  );
                                }
                              }
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

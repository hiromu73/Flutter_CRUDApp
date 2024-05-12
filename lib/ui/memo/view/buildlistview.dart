import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/constants/string.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class BuildListView extends HookConsumerWidget {
  const BuildListView(this.query, BuildContext context, {super.key});
  final QuerySnapshot query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = 0;
    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.only(top: 50, right: 5, left: 5),
        children: query.docs.map((DocumentSnapshot document) {
          final int staggerPosition = index++;
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
                  context.pop();
                }
              }
            },
            child: AnimationConfiguration.staggeredList(
              position: staggerPosition,
              duration: const Duration(milliseconds: 1000),
              child: FlipAnimation(
                // verticalOffset: 850.0,
                child: ScaleAnimation(
                  child: Column(children: [
                    Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                document['text'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                          ),
                                        );
                                      }
                                    }
                                  }),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  document['checkName'] != null
                                      ? Text("場所\n${document['checkName']}"
                                          .toString())
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
                                                      String docId =
                                                          document.id;
                                                      await FirebaseFirestore
                                                          .instance
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
                    ),
                    const SizedBox(height: 5)
                  ]),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

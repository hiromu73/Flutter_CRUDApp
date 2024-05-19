import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/constants/string.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:memoplace/ui/login/view_model/loginuser.dart';

class BuildGridView extends HookConsumerWidget {
  const BuildGridView(this.query, BuildContext context, {super.key});
  final QuerySnapshot query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = 0;
    final userId = ref.watch(loginUserProvider);
    Color baseColor = Colors.orange.shade100;
    return AnimationLimiter(
      child: GridView(
        padding: const EdgeInsets.only(top: 50, right: 10, left: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.8),
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
                print(userId);
                await FirebaseFirestore.instance
                    .collection('post')
                    .doc(userId)
                    .collection('documents')
                    .doc(docId)
                    .delete();
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: InkWell(
              onTap: (() =>
                  print(query.docs.length)), // cardがタップされた時の処理 // 今後変えていく
              child: AnimationConfiguration.staggeredGrid(
                position: staggerPosition,
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 520),
                columnCount: 5,
                child: FlipAnimation(
                  // verticalOffset: 550,
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SingleChildScrollView(
                              child: document['checkName'] != null
                                  ? Text("場所\n${document['checkName']}")
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
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
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('post')
                                                        .doc(userId)
                                                        .collection('documents')
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
                                          .doc(userId)
                                          .collection('documents')
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/firebase_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// constants
import 'package:flutter_crudapp/constants/routes.dart' as routes;

class FirebaseCollection extends ConsumerWidget {
  const FirebaseCollection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AsyncValueは非同期的に更新されるデータを安全に取り扱うためにRiverPodに内包されている
    final AsyncValue<QuerySnapshot> firebaseCollection =
        ref.watch(firebaseModelProvider);

    return firebaseCollection.when(
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
    );
  }
}

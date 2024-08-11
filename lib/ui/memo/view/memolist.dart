import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/memo/view/buildlistview.dart';

final userCollectionProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('post')
      .doc(userId)
      .collection('documents')
      .snapshots();
});

class MemoList extends HookConsumerWidget {
  const MemoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = FirebaseAuth.instance.currentUser;
    final AsyncValue<QuerySnapshot> userCollection;

    if (user != null) {
      userCollection = ref.watch(userCollectionProvider(user.uid));
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      userCollection = ref.watch(userCollectionProvider(user!.uid));
    }

    return userCollection.when(
      data: (QuerySnapshot query) {
        return BuildListView(query, context);
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

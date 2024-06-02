import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/login/view/loginpage.dart';
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
    final userId = ref.watch(userIdProvider);
    final AsyncValue<QuerySnapshot> userCollection =
        ref.watch(userCollectionProvider(userId));
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

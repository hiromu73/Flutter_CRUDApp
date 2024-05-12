import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/memo/view/buildgridview.dart';
import 'package:memoplace/ui/memo/view/buildlistview.dart';
import 'package:memoplace/ui/memo/view_model/firebase_model.dart';

class MemoList extends HookConsumerWidget {
  const MemoList(this.viewType, {super.key});
  final bool viewType;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<QuerySnapshot> firebaseCollection =
        ref.watch(firebaseModelProvider);
    return firebaseCollection.when(
      data: (QuerySnapshot query) {
        
        return viewType
            ? BuildListView(query, context)
            : BuildGridView(query, context);
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

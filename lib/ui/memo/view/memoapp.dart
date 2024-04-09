import 'package:flutter/material.dart';
import 'package:flutter_crudapp/ui/memo/view/memolist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// constants
import 'package:flutter_crudapp/constants/routes.dart' as routes;

// 複数のfabを設定する場合
//import 'package:uuid/uuid.dart';

// var uuid = const Uuid();
// var newId = uuid.v4();

// メモの一覧を表示
class MemoApp extends ConsumerWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const Column(
        children: [
          Expanded(child: MemoList()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.background,
          // heroTag: "heroId$newId", // 複数のfabを設定する場合に識別するためuniqueなタグを設定する。
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => routes.addPage(context: context)),
    );
  }
}

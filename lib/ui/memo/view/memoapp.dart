import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/memo/view/memolist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 複数のfabを設定する場合
//import 'package:uuid/uuid.dart';

// var uuid = const Uuid();
// var newId = uuid.v4();

// メモの一覧を表示
class MemoApp extends HookConsumerWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = useState<bool>(true);
    void changeView() {
      viewType.value = !viewType.value;
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: MemoList(viewType.value)),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.background,
              heroTag: "add",
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => context.go('/addpage')),
          const SizedBox(
            width: 100,
          ),
          FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.background,
              heroTag: "change",
              child: Icon(
                Icons.apps,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => changeView()),
        ],
      ),
    );
  }
}

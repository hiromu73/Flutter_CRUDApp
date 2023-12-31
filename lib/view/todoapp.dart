import 'package:flutter/material.dart';
import 'package:flutter_crudapp/view/firebasecollection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// constants
import 'package:flutter_crudapp/constants/routes.dart' as routes;

// メモの一覧を表示
class ToDoApp extends ConsumerWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        color: Colors.yellow[50],
        child: const Column(
          children: [
            Expanded(child: FirebaseCollection()),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          heroTag: "hero1",
          child: const Icon(Icons.add),
          onPressed: () => routes.AddPage(context: context)),
    );
  }
}

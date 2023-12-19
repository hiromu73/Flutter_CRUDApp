import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/constants/string.dart';

import 'package:flutter_crudapp/model.dart/riverpod.dart/firebase_model.dart';
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
      appBar: AppBar(
        title: const Text("TodoList"),
      ),
      body: const Column(
        children: [
          Expanded(child: FirebaseCollection()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => routes.toDoAddPage(context: context)),
    );
  }
}

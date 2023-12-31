// flutter
import 'package:flutter/material.dart';
// package
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_crudapp/view/firebase_options.dart';
import 'package:flutter_crudapp/view/todoapp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: MaterialApp(home: MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter CrudApp',
      theme: ThemeData(
          primaryColor: MaterialColor(
        0xFFFFFFFF,
        <int, Color>{
          500: Color(0xFFFFFFFF),
        },
      )),
      home: const ToDoApp(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memoplace/constants/routes.dart';
import 'package:memoplace/ui/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(
    child: MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MemoPlace',
      theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            background: Colors.orange.shade100,
            primary: Colors.black,
            secondary: Colors.grey.shade200,
          )),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}

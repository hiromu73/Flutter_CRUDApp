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
  static const Color mainColor = Color(0xFFFFE0B2);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MemoPlace',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        primaryColor: mainColor,
        colorScheme: ColorScheme.light(
          background: mainColor,
          primary: Colors.black,
          secondary: Colors.grey.shade200,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        primaryColor: mainColor,
        colorScheme: ColorScheme.light(
          background: mainColor,
          primary: Colors.black,
          secondary: Colors.grey.shade200,
        ),
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}

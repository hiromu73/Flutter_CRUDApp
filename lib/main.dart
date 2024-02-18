// flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// package
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_crudapp/view/firebase_options.dart';
import 'package:flutter_crudapp/view/todoapp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:background_task/background_task.dart';

/// プラットフォームの確認
final isAndroid =
    defaultTargetPlatform == TargetPlatform.android ? true : false;
final isIOS = defaultTargetPlatform == TargetPlatform.iOS ? true : false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //パーミションの設定
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //トークン取得
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("↓トークン");
  print(fcmToken);

// フォアグラウンドでのメッセージの処理
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

// バックグラウンドでの処理
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  @pragma('vm:entry-point')
  void backgroundHandler(Location data) {
    // ここにバックグラウンドで実行したい処理を書く。
  }

// バックグラウンドで位置情報の使用を開始
  await BackgroundTask.instance.start();
  BackgroundTask.instance.setBackgroundHandler(backgroundHandler);
  BackgroundTask.instance.stream.listen((event) {
    print("↓位置情報");
    print(event.lat);
    print(event.lng);
  });
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
          primaryColor: const MaterialColor(
        0xFFFFFFFF,
        <int, Color>{
          500: Color(0xFFFFFFFF),
        },
      )),
      home: const ToDoApp(),
    );
  }
}

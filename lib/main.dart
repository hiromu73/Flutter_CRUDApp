// flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// package
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_crudapp/view/firebase_options.dart';
import 'package:flutter_crudapp/view/todoapp.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:background_task/background_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

/// プラットフォームの確認
final isAndroid =
    defaultTargetPlatform == TargetPlatform.android ? true : false;
final isIOS = defaultTargetPlatform == TargetPlatform.iOS ? true : false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // フォアグラウンドで通知が表示されるオプションの設定
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: false,
    sound: true,
  );

  //トークン取得
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print("↓トークン");
  print(fcmToken);

  // push通知のパーミションの設定
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  List<double> latitude = [];
  List<double> longiLang = [];

  FirebaseFirestore.instance.collection('post').orderBy((document) {
    // Firestoreから位置情報を取得
    latitude = document['latitude'];
    longiLang = document['longiLang'];
  });

// Andorid構成
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

// フォアグラウンドでのメッセージを受信した際の処理
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification!.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: android.smallIcon,
              // other properties...
            ),
          ));
    }
  });

  // バックグラウンド
  BackgroundTask.instance.stream.listen((event) async {
    print("↓バックグラウンド位置情報");
    // アプリ内での位置情報処理
    print('Received location: ${event.lat}, ${event.lng}');

    // バックグラウンドで位置情報の使用を開始
    await BackgroundTask.instance.start();
    // getLocationUpdates();
    // Firebaseの初期化 // オフラインでの動作を有効にする場合
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    // 距離を割り出す
    double distanceInMeters = Geolocator.distanceBetween(
      latitude[0],
      longiLang[0],
      event.lat!,
      event.lng!,
    );

    print(distanceInMeters);
    final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast1');
    // 一定距離内に近づいたらプッシュ通知を送信
    // if (distanceInMeters < 100) {
    //   await FirebaseMessaging.instance.subscribeToTopic("topic");
    // }
    Future<void> push(String token) async {
      try {
        final HttpsCallable callable = functions.httpsCallable('pushTalk');
        final HttpsCallableResult result = await callable.call({
          'title': 'Push通知テスト',
          'body': '自分から届きました',
          'token': fcmToken
        }); // 関数を呼び出し、引数を渡す

        final data = result.data;

        print('結果: ${data}'); // 結果を表示
      } catch (e) {
        print('エラー: $e'); // エラーハンドリング
      }
    }
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

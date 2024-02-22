// flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// package
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_crudapp/view/firebase_options.dart';
import 'package:flutter_crudapp/view/todoapp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:background_task/background_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// プラットフォームの確認
final isAndroid =
    defaultTargetPlatform == TargetPlatform.android ? true : false;
final isIOS = defaultTargetPlatform == TargetPlatform.iOS ? true : false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> _getCurrentLocation() async {
  try {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      // ユーザーが位置情報の利用を拒否した場合の処理
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("フォアグラウンドの位置情報=$position");
    // ここでfirestoreに保存されている位置情報を取得してチェックする？
    // 距離を割り出す
    // double distanceInMeters = Geolocator.distanceBetween(
    //   event.lat,
    //   currentLongitude,
    //   event.lat!,
    //   event.lng!,
    // );

    // Firebase Cloud Messaging（FCM）のメッセージを作成
    final fcmMessage = {
      'notification': {
        'title': '近くにいます',
        'body': 'お知らせ: 一定の距離以内にいます。',
      },
      'to': '/topics/all_devices', // トピック名
    };

    // FCM メッセージを送信
    sendFcmMessage(fcmMessage);
  } catch (e) {
    print("Error getting location: $e");
  }
}

void getLocationUpdates() {
  Geolocator.getPositionStream().listen((Position position) {
    // リアルタイムな位置情報がここに届く
    print(
        'Location Update(フォアグラウンド): ${position.latitude}, ${position.longitude}');
    // 位置情報を利用して必要な処理を実行
  });
}

void sendFcmMessage(Map<String, dynamic> message) {
  // メッセージを Firebase Cloud Messaging に送信するロジックを実装
  // この部分は Firebase Cloud Messaging の実際の API 呼び出しに依存します
  // https://firebase.flutter.dev/docs/messaging/usage
  // 例えば、FirebaseMessaging クラスを使用することが一般的です
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //トークン取得
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("↓トークン");
  print(fcmToken);
  // fXKli8UTAERMspm8buAdPm:APA91bGMDp8V0G98B_BfdzLM8F0mVx8sOl2XQn-7YZF7nyGYYAzybE9rk8Wa1KquQiyQPJ5FuJ16J3tEDuvHB9TNKMA6O44KtPadvIb9QDd4hIOi_I9vUjnLySTLAzqXdHEqvFknULEL

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

// フォアグラウンドでのメッセージの処理
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });

  _getCurrentLocation();

  BackgroundTask.instance.stream.listen((event) {
    print("↓バックグラウンド位置情報");
    // アプリ内での位置情報処理
    print('Received location: ${event.lat}, ${event.lng}');

    // 距離を割り出す
    // double distanceInMeters = Geolocator.distanceBetween(
    //   currentLongitude,
    //   currentLongitude,
    //   event.lat!,
    //   event.lng!,
    // );

    // Firebase Cloud Messaging（FCM）のメッセージを作成
    final fcmMessage = {
      'notification': {
        'title': '近くにいます',
        'body': 'お知らせ: 一定の距離以内にいます。',
      },
      'data': {
        // 任意のデータ
        'lat': event.lat.toString(),
        'lng': event.lng.toString(),
      },
      'to': '/topics/all_devices', // トピック名
    };

    // FCM メッセージを送信
    sendFcmMessage(fcmMessage);
  });
  // バックグラウンドで位置情報の使用を開始
  await BackgroundTask.instance.start();
  getLocationUpdates();
  // Firebaseの初期化 // オフラインでの動作を有効にする場合
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
//CR84FK9GRR
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

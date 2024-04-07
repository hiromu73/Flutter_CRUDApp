// flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// package
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_crudapp/ui/firebase_options.dart';
import 'package:flutter_crudapp/ui/todo/view/todoapp.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:background_task/background_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_functions/cloud_functions.dart';

// プラットフォームの確認
// final isAndroid =
//     defaultTargetPlatform == TargetPlatform.android ? true : false;
// final isIOS = defaultTargetPlatform == TargetPlatform.iOS ? true : false;

// function
Future<void> writeMessage() async {
  HttpsCallable callable =
      FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable('pushTalk');
  final resp = await callable.call();
  print("result: ${resp.data}");
}

// 現在位置を取得するメソッド
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // isLocationServiceEnabledはロケーションサービスが有効かどうかを確認
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('ロケーションサービスが無効です。');
  }

  // ユーザーがデバイスの場所を取得するための許可をすでに付与しているかどうかを確認
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    // デバイスの場所へのアクセス許可をリクエストする
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('デバイスの場所を取得するための許可がされていません。');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('デバイスの場所を取得するための許可してください');
  }

  // デバイスの現在の場所を返す。
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  return position;
}

// Andorid構成
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // バックグラウンドで位置情報の使用を開始
  print("バックグラウンドスタート");
  await BackgroundTask.instance.start();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // フォアグラウンドで通知が表示されるオプションの設定
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: false,
    sound: true,
  );

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

  // トピック作成
  FirebaseMessaging.instance.subscribeToTopic('locationsMemo');

  List<double> latitude = [];
  List<double> longiLang = [];
  List<String> name = [];

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('post');

  QuerySnapshot querySnapshot = await collectionReference.get();

  for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
    dynamic fieldValue = documentSnapshot['latitude'];
    dynamic fieldValues = documentSnapshot['longitude'];
    dynamic fieldNameValue = documentSnapshot['text'];
    dynamic fieldAlert = documentSnapshot['alert'];
    print(fieldAlert);

    if (fieldValue != null && fieldAlert == true) {
      for (int i = 0; i < fieldValue.length; i++) {
        latitude.add(double.parse(fieldValue[i].toString()));
        longiLang.add(double.parse(fieldValues[i].toString()));
        name.add(fieldNameValue);
      }
    }
  }

  //  フォアグラウンドで現在位置を取得する。
  final position = await _determinePosition();
  print("位置情報を取得");

  //  位置情報が検知されると発火する
  BackgroundTask.instance.stream.listen((event) async {
    print("位置情報をListen");
    for (int i = 0; i < latitude.length; i++) {
      print(double.parse(latitude[i].toString()));
      print(double.parse(longiLang[i].toString()));
      double distanceInMeters = Geolocator.distanceBetween(
        double.parse(latitude[i].toString()),
        double.parse(longiLang[i].toString()),
        position.latitude,
        position.longitude,
      );
      print(" $i: $distanceInMeters meters");

      if (distanceInMeters < 1000) {
        print("Distance from document $i: $distanceInMeters meters");
        await writeMessage();
      }
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  });

  // フォアグラウンドでのメッセージを受信した際の処理
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification!.android;
    print('Message data: ${message.data}');
    print('フォアグラウンドでのメッセージを受信した際の処理');
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
            ),
          ));
    }
  });

  print('バックグラウンド');
  // await BackgroundTask.instance.stop();

  runApp(const ProviderScope(
    child: MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'memoPlace',
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

// flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// package
import 'package:firebase_core/firebase_core.dart';
import 'package:memoplace/constants/routes.dart';
import 'package:memoplace/ui/firebase_options.dart';

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
Future<void> pushMessage() async {
  HttpsCallable callable =
      FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable('pushTalk');
  final fcm = FirebaseMessaging.instance;
  final token = await fcm.getToken();
  final resp = await callable
      .call({'title': '忘れてないですか？', 'body': '自分から届きました', 'token': token});
  final data = resp.data;
  print("result: $data");
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

  // if (permission == LocationPermission.deniedForever) {
  //   // return Future.error('デバイスの場所を取得するための許可してください');
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   return position;
  // }
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

  // コレクションに保存されている情報をまとめている。
  for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
    dynamic fieldValue = documentSnapshot['latitude'];
    dynamic fieldValues = documentSnapshot['longitude'];
    dynamic fieldNameValue = documentSnapshot['text'];
    dynamic fieldAlert = documentSnapshot['alert'];

    if (fieldValue != null && fieldAlert == true) {
      for (int i = 0; i < fieldValue.length; i++) {
        latitude.add(double.parse(fieldValue[i].toString()));
        longiLang.add(double.parse(fieldValues[i].toString()));
        name.add(fieldNameValue);
      }
    }
  }

  //  フォアグラウンドで現在位置を取得する。
  final permission = await Geolocator.checkPermission();
  if (permission != LocationPermission.denied) {
    print("許可");
    final position = await _determinePosition();

    //  位置情報が検知されると発火する
    BackgroundTask.instance.stream.listen((event) async {
      for (int i = 0; i < latitude.length; i++) {
        print("位置情報が検知1");
        print(double.parse(latitude[i].toString()));
        print(double.parse(longiLang[i].toString()));
        print("位置情報が検知2");
        double distanceInMeters = Geolocator.distanceBetween(
          double.parse(latitude[i].toString()),
          double.parse(longiLang[i].toString()),
          position.latitude,
          position.longitude,
        );
        if (distanceInMeters < 1000) {
          print("distanceInMeters < 1000になったのでプッシュ通知します。");
          // print(name);
          await pushMessage();
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
                // sound: ,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
                presentBanner: true,
                // sound:, // 音声ファイル設定する！
              ),
            ));
      }
    });

    // バックグラウンドで位置情報の使用を開始
    await BackgroundTask.instance.start();
    print("バックグラウンドで位置情報の使用");
  }
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
      // routerConfig: router,
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

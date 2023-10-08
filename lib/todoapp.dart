import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_crudapp/searchPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './todoaddpage.dart';
import './main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


// StreamProviderを使うことでStreamも扱うことができる
// ※ autoDisposeを付けることで自動的に値をリセットできます
// StreamProviderを使うことでref.watchできる
final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

// ユーザー情報の状態管理
final userProvider =
    StateProvider.autoDispose((ref) => FirebaseAuth.instance.currentUser);

// Todoの一覧を表示
class ToDoApp extends ConsumerWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから値を受け取る
    final User user = ref.watch(userProvider.notifier).state!;

    // AsyncValueは非同期的に更新されるデータを安全に取り扱うためにRiverPodに内包されている
    // QuerySnapshotはcollection内を取得する際に使用
    // DocumentSnapshotはドキュメント内を取得する際に使用
    final AsyncValue<QuerySnapshot> asyncPostsQuery =
        ref.watch(postQueryProvider);

    Future<void> _requestPermissions() async {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      if (Platform.isIOS || Platform.isMacOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      } else if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        androidImplementation?.requestPermission();
        // setState(() {
        //   _notificationsEnabled = granted ?? false;
        // });
      }
    }

//1回目に通知を飛ばす時間の作成
    tz.TZDateTime _nextInstanceOf8AM() {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }

// スケジュール通知
    Future<void> _scheduleDaily8AMNotification() async {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'OB-1',
          '本日の顔を撮影をしましょう',
          _nextInstanceOf8AM(),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              
                'ob-1-face-daily', 'ob-1-face-daily',
                channelDescription: 'Face photo notification'),
            iOS: DarwinNotificationDetails(
              badgeNumber: 1,
            ),
          ),
          // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // 設定した日付時刻には1回めに通知され、2回目以降は同じ時間に繰り返させる
          matchDateTimeComponents: DateTimeComponents.time);
    }

    @override
    void initState() {
      _requestPermissions();
      _scheduleDaily8AMNotification();
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text("TodoList"),
          leading: IconButton(
              // ログアウトする
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return MyApp();
                }));
              },
              icon: const Icon(Icons.logout))),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Text("ログインユーザー: ${user.email}"),
          ),
          Expanded(
            // 値が取得できた時
            child: asyncPostsQuery.when(
              data: (QuerySnapshot query) {
                return ListView(
                  // ドキュメントを取得する
                  children: query.docs.map((DocumentSnapshot document) {
                    return Card(
                      child: ListTile(
                        // ここを変える
                        title: Text(document['text']),
                        subtitle: Text(document['email']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // ダイアログ(削除確認を行う)
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text("このメモを削除しますか？"),
                                    actions: [
                                      CupertinoDialogAction(
                                          isDefaultAction: true,
                                          onPressed: () async {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('post')
                                                  .doc(document.id)
                                                  .delete();
                                              Navigator.pop(context);
                                            } catch (e) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return CupertinoAlertDialog(
                                                      content: Text(
                                                          "削除できませんでした。${e.toString()}"),
                                                    );
                                                  });
                                            }
                                          },
                                          child: const Text('OK')),
                                      CupertinoDialogAction(
                                          child: const Text('NO'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (e, stackTrace) {
                return Center(
                  child: Text(e.toString()),
                );
              },
            ),
          ),
        ],
      ),
      // 投稿ページに遷移する
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TodoAddPage();
            }));
          }),
    );
  }
}

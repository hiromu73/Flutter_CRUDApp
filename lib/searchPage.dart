import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_place/google_place.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 場所の検索ページ
class SerachPage extends StatefulWidget {
  const SerachPage({super.key});

  @override
  State<SerachPage> createState() => _SerachPage();
}

class _SerachPage extends State<SerachPage> with WidgetsBindingObserver {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  final apiKey = Api.apiKey;
  List LatLng = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(apiKey);
    WidgetsBinding.instance.addObserver(this);
    // initState()はFutureできないのでメソッドを格納。
    // initState();

    // 特定の時間にローカルプッシュするための初期化
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

//バッジの初期化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FlutterAppBadger.removeBadge();
    }
  }

  Future<void> _init() async {
    await _configureLocalTimeZone();
    await _initializeNotification();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

//iOSのメッセージ権限リクエストを初期化
  Future<void> _initializeNotification() async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      // iOSの初期化時、権限リクエストのメッセージがすぐ表示されないようにするため、全ての値をfalseで設定
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // Androidはic_notificationを使ってプッシュメッセージのアイコンを設定
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

// 新しいメッセージを登録する時、以前登録されたメッセージを全てキャンセルする
  Future<void> _cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

//プッシュメッセージを登録する前に、iOSのプッシュメッセージ権限をリクエスト
  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

// 特定時間の1分後にメッセージが表示されるようにプッシュメッセージを登録
  Future<void> _registerMessage({
    required int hour,
    required int minutes,
    required message,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'flutter_local_notifications',
      message,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          styleInformation: BigTextStyleInformation(message),
          icon: 'ic_notification',
        ),
        iOS: const DarwinNotificationDetails(
          badgeNumber: 1,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            // offset: Offset(10, 10)
                          )
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              autoCompleteSearch(value);
                            } else {
                              if (predictions.length > 0 && mounted) {
                                setState(() {
                                  predictions = [];
                                });
                              }
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              color: Colors.grey[500],
                              icon: const Icon(Icons.search),
                              onPressed: () async {
                                // Navigator.pop(context);
                                await _cancelNotification();
                                await _requestPermissions();

                                final tz.TZDateTime now =
                                    tz.TZDateTime.now(tz.local);
                                await _registerMessage(
                                  hour: now.hour,
                                  minutes: now.minute + 1,
                                  message: 'Hello, world!',
                                );
                              },
                            ),
                            hintText: "検索したい場所を入力",
                            hintStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w100),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(predictions[index].description.toString()),
                        onTap: () async {
                          List? locations = await locationFromAddress(
                              predictions[index].description.toString());
                          setState(() {
                            LatLng.add(locations.first.latitude);
                            LatLng.add(locations.first.longitude);
                          });
                          Navigator.pop(context, LatLng);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 検索処理
  void autoCompleteSearch(value) async {
    final result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}

// initState()はFutureできないのでメソッドを格納。
// Future initState() async {}

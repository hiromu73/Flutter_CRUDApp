import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/constants/routes.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'setgooglemap.dart';
import './todoapp.dart';
// constants
import 'package:flutter_crudapp/constants/routes.dart' as routes;

// Textの状態管理
final infoTextProvider = StateProvider.autoDispose(
    (ref) => FirebaseFirestore.instance.collection('post'));

// 位置の状態管理
final locationProvider = StateProvider.autoDispose((ref) => "");

// 位置マーカーの状態管理
final makerProvider = StateProvider.autoDispose((ref) => "");

// メモ内容の状態管理
final memoProvider = StateProvider.autoDispose((ref) => "");

// メモ内容の状態管理
final latitudeProvider = StateProvider.autoDispose((ref) => "");

// メモ内容の状態管理
final longitudeProvider = StateProvider.autoDispose((ref) => "");

// // StreamProviderを使うことでStreamも扱うことができる
// // ※ autoDisposeを付けることで自動的に値をリセットできます
final postQueryProvider = StreamProvider.autoDispose((ref) =>
    FirebaseFirestore.instance.collection('post').orderBy('date').snapshots());

// 投稿ページ
class TodoAddPage extends ConsumerWidget {
  const TodoAddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postLocation = ref.watch(locationProvider.notifier).state;
    final latitudeLocation = ref.watch(latitudeProvider.notifier).state;
    final longitudeLocation = ref.watch(longitudeProvider.notifier).state;

    Completer controller = Completer();
    const CameraPosition initialCameraPosition = CameraPosition(
      // 最初に描画される位置を指定
      target: LatLng(35.17176088096857, 136.88817886263607),
      zoom: 14.4746,
    );

    final apiKey = Api.apiKey;

    // 検索結果を格納
    List<AutocompletePrediction> predictions = [];

    @override
    void initState() {
      GooglePlace googlePlace = GooglePlace(apiKey);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(addPage),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(const ToDoApp());
              }),
        ),
        body: Center(
          child: Container(
            color: Colors.yellow[50],
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  maxLength: null,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                      hintText: memo,
                      hintStyle:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w100),
                      prefixIcon: Icon(Icons.create),
                      border: OutlineInputBorder()),
                  textAlign: TextAlign.left,
                  onChanged: (String value) async {
                    ref.read(memoProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                    child: const Text(positionSearch),
                    onPressed: () => routes.mapSamplePage(context: context)),
                const SizedBox(height: 8),
                Text(postLocation),
                ElevatedButton(
                    child: const Text(registration),
                    onPressed: () async {
                      if (ref.watch(memoProvider.notifier) != null) {
                        final date = DateTime.now().toLocal().toIso8601String();
                        await FirebaseFirestore.instance
                            .collection('post')
                            .doc()
                            .set({
                          'text': ref.watch(memoProvider.notifier).state,
                          // 経度緯度を表示
                          // 'latitude' : ref.watch(latitudeLocation.notifier).state,
                          // 'longitude' : ref.watch(longitudeLocation.notifier).state,
                          'date': date,
                          'alert': true,
                        });
                        Navigator.of(context).pop();
                      }
                    })
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.map),
            onPressed: () => routes.mapSamplePage(context: context)));
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:flutter_crudapp/model.dart/mapinitialized_model.dart';
import 'package:flutter_crudapp/model.dart/place.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/autocomplete_search_type.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/latitude.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/longitude.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/autocomplete_search.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/menuitemcheckbox.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/predictions.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/select_marker.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/selectitem.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/textpredictions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class MapSample extends ConsumerWidget {
  MapSample({super.key});

  // 初期位置
  CameraPosition initialLocation = const CameraPosition(
    target: LatLng(34.758663, 135.4971856623888),
    zoom: 15.0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final selectItems = ref.watch(selectItemsProvider);
    // テキスト入力結果を取得
    final selectTextItemeMakers = ref.watch(autoCompleteSearchProvider);
    // 設置するマーカーの一覧
    final selectItemeMakers = ref.watch(autoCompleteSearchTypeProvider);
    // final latitude = ref.watch(latitudeProvider);
    // final longitude = ref.watch(longitudeProvider);

    Set<Marker> markers = Set<Marker>.of(selectItemeMakers.map((item) => Marker(
          markerId: MarkerId(item.uid),
          position: LatLng(item.latitude, item.longitude),
          infoWindow: InfoWindow(title: item.name),
        )));

    final selectMarker = ref.watch(selectMarkerProvider);
    GoogleMapController mapController;

    // IDのリスト
    List<String> idList = [];
    var uuid = Uuid();
    var newId = uuid.v4();
    while (idList.any((id) => id == newId)) {
      // 被りがあるので、IDを再生成する
      newId = uuid.v4();
    }
    idList.add(newId);

    _initializeOnes(ref);
    // 画面が初期化された際にフォーカスを外す
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: Set<Marker>.of(selectItemeMakers.map((item) => Marker(
                    markerId: MarkerId(item.uid),
                    position: LatLng(item.latitude, item.longitude),
                    infoWindow: InfoWindow(title: item.name),
                  ))), //markerの設置
              mapType: MapType.normal,
              initialCameraPosition: initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: (LatLng latLang) {
                // maker追加
                // ref.read().addMarker(latLang);
                // 以下マーカーが選択された時の処理
                // 選択されていない場合
                // if (selectMarker != true) {}
              },
              zoomGesturesEnabled: true,
            ),
            // 簡易選択モーダル表示
            Align(
              alignment: const Alignment(0.8, -0.85),
              child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 50,
                    height: 40,
                    child: const Icon(
                      Icons.dehaze_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onTap: () async {
                    await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withOpacity(0.6),
                        builder: (context) {
                          return ShowModal();
                        });
                  }),
            ),
            //テキスト検索モーダル
            Align(
                alignment: const Alignment(-0.6, -0.85),
                child: SizedBox(
                  width: 200,
                  height: 40,
                  child: TextFormField(
                    autofocus: false,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    controller: TextEditingController(text: selectItems),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      iconColor: Colors.grey,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      hintText: "検索したい場所",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onTap: () async {
                      await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          enableDrag: true,
                          barrierColor: Colors.black.withOpacity(0.6),
                          builder: (context) {
                            // テキスト検索モーダル
                            return ShowTextModal();
                          });
                      // モーダルを閉じたら、テキスト検索全て無くす。
                      // .whenComplete(() async => await ref
                      //     .read(autoCompleteSearchProvider.notifier)
                      //     .noneAutoCompleteSearch());
                    },
                  ),
                )),
            // 登録ボタン
            Align(
                alignment: const Alignment(0.94, 0.8),
                child: FloatingActionButton(
                    child: const Icon(Icons.create),
                    onPressed: () => {Navigator.pop(context)}))
          ],
        ),
      ),
    );
  }
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

Future _initializeOnes(WidgetRef ref) async {
  final position = await _determinePosition();
  ref.read(latitudeProvider.notifier).changeLatitude(position.latitude);
  ref.read(longitudeProvider.notifier).changeLongitude(position.longitude);
}

class ShowTextModal extends ConsumerWidget {
  final TextEditingController textController = TextEditingController();
  ShowTextModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoCompleteSearch = ref.watch(autoCompleteSearchProvider);
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);
    final selectItemeMakers = ref.watch(autoCompleteSearchTypeProvider);
    // final selectItem = ref.watch(selectItemsProvider);
    // final preditons = ref.watch(predictionsProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          TextFormField(
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            controller: textController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              iconColor: Colors.grey,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              hintText: "検索したい場所",
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.white),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (value) async {
              if (value.isNotEmpty && ref.watch(selectItemsProvider) != "") {
                List<String> japaneseNames =
                    ref.watch(selectItemsProvider).split(',');
                List<String> englishNames = [];
                for (String japaneseName in japaneseNames) {
                  String trimmedJapaneseName = japaneseName.trim();
                  if (itemNameMap.containsKey(trimmedJapaneseName)) {
                    englishNames.add(itemNameMap[trimmedJapaneseName]!);
                  }
                }
                // タイプあり検索処理
                await ref
                    .read(autoCompleteSearchProvider.notifier)
                    .autoCompleteTypeSearch(
                        value, englishNames, latitude, longitude);
              } else if (value.isNotEmpty &&
                  ref.watch(selectItemsProvider) == "") {
                // タイプ無し検索処理
                await ref
                    .read(autoCompleteSearchProvider.notifier)
                    .autoCompleteSearch(value, latitude, longitude);
              } else {
                await ref
                    .read(autoCompleteSearchProvider.notifier)
                    .noneAutoCompleteSearch();
                // 前の結果が残る。(速さによる)(更新はされている。非同期の問題)
              }
            },
          ),
          SizedBox(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: autoCompleteSearch.length,
                itemBuilder: (context, index) {
                  return menuItem(
                      autoCompleteSearch[index], latitude, longitude, ref);
                }),
          ),
          ElevatedButton(
            onPressed: () async {
              // チェックになっている対象のデータをマップ上にマーカーを設置する。
              // チェックされたPlaceオブジェクトのリストを取得
              final checkedPlaces = ref
                  .read(autoCompleteSearchTypeProvider.notifier)
                  .getCheckedPlaces();
              // チェックされたPlaceオブジェクトからMarkerを作成し、Google Mapに追加
              for (final place in checkedPlaces) {
                print('check');
                await ref
                    .read(autoCompleteSearchTypeProvider.notifier)
                    .addMarker(place.name, place.latitude, place.longitude,
                        place.uid, place.check);
              }
              // モーダルを閉じる
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: const Text(serach),
          )
        ],
      ),
    );
  }
}

Widget menuItem(Place place, double currentLatitude, double currentLongitude,
    WidgetRef ref) {
  // 現在地からの距離を計算する
  double distanceInMeters = Geolocator.distanceBetween(
    currentLatitude,
    currentLongitude,
    place.latitude,
    place.longitude,
  );

  return InkWell(
    child: Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: ListTile(
              title: Text(place.name),
              subtitle: Text('現在地から${distanceInMeters.toStringAsFixed(0)} km'),
              trailing: Checkbox(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  value: place.check,
                  onChanged: (bool? value) async {
                    ref
                        .read(autoCompleteSearchProvider.notifier)
                        .checkChange(place.uid, value);
                  }),
            ),
          ),
        ],
      ),
    ),
    onTap: () async {
      if (place.check == false) {
        ref
            .read(autoCompleteSearchProvider.notifier)
            .checkChange(place.uid, true);
      } else {
        ref
            .read(autoCompleteSearchProvider.notifier)
            .checkChange(place.uid, false);
      }
    },
  );
}

// 簡易検索モーダル
class ShowModal extends ConsumerWidget {
  const ShowModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectItem = ref.watch(selectItemsProvider);
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      height: 250,
      child: Column(
        children: [
          Wrap(
            runSpacing: 16,
            spacing: 16,
            children: itemNameMap.keys.map((item) {
              return InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                onTap: () async {
                  if (selectItem.contains(item)) {
                    await ref.read(selectItemsProvider.notifier).remove(item);
                    if (ref.watch(selectItemsProvider).isNotEmpty) {
                      List<String> japaneseNames =
                          ref.watch(selectItemsProvider).split(',');
                      List<String> englishNames = [];
                      for (String japaneseName in japaneseNames) {
                        String trimmedJapaneseName = japaneseName.trim();
                        if (itemNameMap.containsKey(trimmedJapaneseName)) {
                          englishNames.add(itemNameMap[trimmedJapaneseName]!);
                        }
                      }
                      ref
                          .read(autoCompleteSearchTypeProvider.notifier)
                          .autoCompleteSearchType(
                              englishNames, latitude, longitude);
                    } else {
                      await ref
                          .read(autoCompleteSearchTypeProvider.notifier)
                          .noneAutoCompleteSearch();
                    }
                  } else {
                    await ref.read(selectItemsProvider.notifier).add(item);
                    List<String> japaneseNames =
                        ref.watch(selectItemsProvider).split(',');
                    List<String> englishNames = [];
                    for (String japaneseName in japaneseNames) {
                      String trimmedJapaneseName = japaneseName.trim();
                      if (itemNameMap.containsKey(trimmedJapaneseName)) {
                        englishNames.add(itemNameMap[trimmedJapaneseName]!);
                      }
                    }
                    ref
                        .read(autoCompleteSearchTypeProvider.notifier)
                        .autoCompleteSearchType(
                            englishNames, latitude, longitude);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color:
                        selectItem.contains(item) ? Colors.blue : Colors.white,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                        color: selectItem.contains(item)
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
              child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    ref.read(selectItemsProvider.notifier).none();
                    await ref
                        .read(autoCompleteSearchTypeProvider.notifier)
                        .noneAutoCompleteSearch();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

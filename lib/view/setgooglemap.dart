import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:flutter_crudapp/model.dart/googlemapcontrollernotifier.dart';
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

final googleMapControllerProvider =
    StateNotifierProvider<GoogleMapControllerNotifier, GoogleMapController?>(
  (ref) => GoogleMapControllerNotifier(),
);

class MapSample extends ConsumerWidget {
  MapSample({super.key});

  // 初期位置
  CameraPosition initialLocation = const CameraPosition(
    target: LatLng(34.758663, 135.4971856623888),
    zoom: 15.0,
  );

  final pageController = PageController(
    viewportFraction: 0.85,
  );

  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final selectItems = ref.watch(selectItemsProvider);
    // 設置するマーカーの一覧
    final selectItemeMakers = ref.watch(autoCompleteSearchTypeProvider);
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);

    Set<Marker> markers = Set<Marker>.of(selectItemeMakers.map((item) => Marker(
          markerId: MarkerId(item.uid),
          position: LatLng(item.latitude, item.longitude),
          infoWindow: InfoWindow(title: item.name),
          icon: item.check
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarker,
          onTap: () async {
            // マーカーをタップしたときの処理
            await ref
                .read(autoCompleteSearchTypeProvider.notifier)
                .toggleMarkerCheck(item.uid);
            //タップしたマーカー(shop)のindexを取得
            final index = selectItemeMakers.indexWhere((shop) => shop == item);
            pageController.jumpToPage(index);
          },
        )));

    // IDのリスト
    List<String> idList = [];
    var uuid = const Uuid();
    var newId = uuid.v4();
    while (idList.any((id) => id == newId)) {
      newId = uuid.v4();
    }
    idList.add(newId);
    _initializeOnes(ref);
    // 画面が初期化された際にフォーカスを外す
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                _mapController = controller;
                ref
                    .read(googleMapControllerProvider.notifier)
                    .setController(controller);
              },
              markers: markers,
              mapType: MapType.normal,
              initialCameraPosition: initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onTap: (LatLng latLang) {
                // // map上に新たにマーカーを追加(初回時はチェックされている状態なので緑になる。)
                // final latitude = latLang.latitude;
                // final longitude = latLang.longitude;
                // final uid =
                //     '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
                // ref
                //     .read(autoCompleteSearchTypeProvider.notifier)
                //     .onTapAddMarker(latitude, longitude, uid, true);
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
                          return const ShowModal();
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
                    },
                  ),
                )),
            Align(
                alignment: const Alignment(0.0, 0.95),
                child: CardSection(pageController: pageController)),
            Align(
              alignment: const Alignment(0.95, 0.1),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, bottom: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 登録ボタン
                    ClipOval(
                      child: Material(
                        color: Colors.blue[400], // ボタンを押す前のカラー
                        child: InkWell(
                            splashColor: Colors.blue[400], // ボタンを押した後のカラー
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.create, color: Colors.white),
                            ),
                            onTap: () => {Navigator.pop(context)}),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 現在位置ボタン
                    ClipOval(
                      child: Material(
                        color: Colors.blue[400], // ボタンを押す前のカラー
                        child: InkWell(
                          splashColor: Colors.blue[400], // ボタンを押した後のカラー
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.my_location, color: Colors.white),
                          ),
                          onTap: () async {
                            await _mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(ref.watch(latitudeProvider),
                                      ref.watch(longitudeProvider)),
                                  zoom: 15.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // // ズームインボタン // 必要か検討？
                    // ClipOval(
                    //   child: Material(
                    //     color: Colors.blue[400], // ボタンを押す前のカラー
                    //     child: InkWell(
                    //       splashColor: Colors.blue[100], // ボタンを押した後のカラー
                    //       child: const SizedBox(
                    //         width: 50,
                    //         height: 50,
                    //         child: Icon(Icons.add, color: Colors.white),
                    //       ),
                    //       onTap: () async {
                    //         await _mapController.animateCamera(
                    //           CameraUpdate.zoomIn(),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    // // ズームアウトボタン
                    // ClipOval(
                    //   child: Material(
                    //     color: Colors.blue[400], // ボタンを押す前のカラー
                    //     child: InkWell(
                    //       splashColor: Colors.blue[100], // ボタンを押した後のカラー
                    //       child: const SizedBox(
                    //         width: 50,
                    //         height: 50,
                    //         child: Icon(Icons.remove, color: Colors.white),
                    //       ),
                    //       onTap: () async {
                    //         await _mapController.animateCamera(
                    //           CameraUpdate.zoomOut(),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// マーカーの情報をcardで表示
// 今後は写真と現在位置からの距離、ルートを実装する。
class CardSection extends ConsumerWidget {
  final TextEditingController textController = TextEditingController();
  final PageController pageController;
  CardSection({Key? key, required this.pageController}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final items = ref.watch(autoCompleteSearchTypeProvider);
    final GoogleMapController? mapController =
        ref.read(googleMapControllerProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.6),
      ),
      height: 150,
      width: 380,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: PageView(
        onPageChanged: (int index) async {
          //スワイプ後のページのお店を取得
          final selectedShop = items.elementAt(index);
          //現在のズームレベルを取得
          if (mapController != null) {
            final zoomLevel = await mapController.getZoomLevel();
            //スワイプ後のお店の座標までカメラを移動
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(selectedShop.latitude, selectedShop.longitude),
                  zoom: zoomLevel,
                ),
              ),
            );
          }
        },
        controller: pageController,
        children: shopTiles(ref),
      ),
    );
  }
}

//カード1枚1枚について
List<Widget> shopTiles(WidgetRef ref) {
  final items = ref.watch(autoCompleteSearchTypeProvider);
  final shopTiles = items.map(
    (shop) {
      return Align(
        alignment: const Alignment(-3.5, 0.1),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            height: 150,
            width: 300,
            child: Center(
              child: Text(shop.name!),
            ),
          ),
        ),
      );
    },
  ).toList();
  return shopTiles;
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
                // 前の結果が残る。(速さによる)(更新はされている。非同期の問題？) 質問Zoom②
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
              // 非同期後にcontextが変わってしまう為、現在のcontextを取得しておく。
              final localContext = context;
              // チェックになっている対象のデータをマップ上にマーカーを設置する。
              // チェックされたPlaceオブジェクトのリストを取得
              final checkedPlaces = await ref
                  .read(autoCompleteSearchProvider.notifier)
                  .getCheckedPlaces();
              // チェックされたPlaceオブジェクトからMarkerを作成し、Google Mapに追加
              for (final place in checkedPlaces) {
                await ref
                    .read(autoCompleteSearchTypeProvider.notifier)
                    .addMarker(place.name!, place.latitude, place.longitude,
                        place.uid, place.check);
              }
              // 質問Zoom①
              // 非同期処理中に、「Navigator」のように、contextを渡す処理があると、非同期処理から戻ってきたときに、既に画面遷移が終わっていて、
              // 元の画面のcontextが無くなっているのでエラーになる
              // Navigator.pop(localContext);
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
              title: Text(place.name!),
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
                      await ref
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
                    await ref
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

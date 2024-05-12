import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/map/view/cardsection.dart';
import 'package:memoplace/ui/map/view/showmodal.dart';
import 'package:memoplace/ui/map/view/showtextmoal.dart';
import 'package:memoplace/ui/map/view_model/googlemap_controller_notifier.dart';
import 'package:memoplace/model/map/place.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search_type.dart';
import 'package:memoplace/ui/map/view_model/latitude.dart';
import 'package:memoplace/ui/map/view_model/longitude.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search.dart';
import 'package:memoplace/ui/map/view_model/select_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

final googleMapControllerProvider =
    StateNotifierProvider<GoogleMapControllerNotifier, GoogleMapController?>(
  (ref) => GoogleMapControllerNotifier(),
);

class SetGoogleMap extends ConsumerWidget {
  SetGoogleMap({Key? key}) : super(key: key);
  // final bool _isFirstBuild = true;
  late GoogleMapController _mapController;

  final pageController = PageController(
    viewportFraction: 0.85,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPositionFuture = ref.watch(currentPositionProvider);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final selectItems = ref.watch(selectItemsProvider);
    final selectItemeMakers = ref.watch(autoCompleteSearchTypeProvider);
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);
    print(latitude);
    print(longitude);
    print("ビルド");
    print(currentPositionFuture);
    Set<Marker> markers = Set<Marker>.of(selectItemeMakers.map((item) => Marker(
          markerId: MarkerId(item.uid),
          position: LatLng(item.latitude, item.longitude),
          infoWindow: InfoWindow(title: item.name),
          icon: item.check
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarker,
          onTap: () async {
            await ref
                .read(autoCompleteSearchTypeProvider.notifier)
                .toggleMarkerCheck(item.uid);
            final index = selectItemeMakers.indexWhere((shop) => shop == item);
            pageController.jumpToPage(index);
          },
        )));

    List<String> idList = [];
    var uuid = const Uuid();
    var newId = uuid.v4();
    while (idList.any((id) => id == newId)) {
      newId = uuid.v4();
    }
    idList.add(newId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            currentPositionFuture.maybeWhen(
              data: (data) => GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  ref
                      .read(googleMapControllerProvider.notifier)
                      .setController(controller);
                },
                markers: markers,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(data.latitude, data.longitude),
                  zoom: 15.0,
                ),
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
              orElse: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
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
                    ClipOval(
                      child: Material(
                        color: Colors.blue[400],
                        child: InkWell(
                            splashColor: Colors.blue[400],
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.create, color: Colors.white),
                            ),
                            onTap: () => context.go('/addpage')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 現在位置ボタン
                    ClipOval(
                      child: Material(
                        color: Colors.blue[400],
                        child: InkWell(
                          splashColor: Colors.blue[400],
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.my_location, color: Colors.white),
                          ),
                          onTap: () async {
                            print("現在位置 $currentPositionFuture.latitude");
                            await _mapController
                                .animateCamera(CameraUpdate.newCameraPosition(
                              currentPositionFuture.maybeWhen(
                                data: (data) => CameraPosition(
                                  target: LatLng(data.latitude, data.longitude),
                                  zoom: 15.0,
                                ),
                                orElse: () => const CameraPosition(
                                  target: LatLng(0, 0),
                                  zoom: 15.0,
                                ),
                              ),
                            ));
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

// void _checkLocationPermission(context, WidgetRef ref) {
//   _determinePosition().then((position) {
//     if (position != null) {
//       ref.read(latitudeProvider.notifier).changeLatitude(position.latitude);
//       ref.read(latitudeProvider.notifier).changeLatitude(position.longitude);
//       print("取得できた");
//     }

//     print(position);
//   });
// }

// Future<Position?> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;

// isLocationServiceEnabledはロケーションサービスが有効かどうかを確認
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return Future.error('ロケーションサービスが無効です。');
//   }

//   // ユーザーがデバイスの場所を取得するための許可をすでに付与しているかどうかを確認
//   permission = await Geolocator.checkPermission();

//   if (permission == LocationPermission.denied) {
//     // デバイスの場所へのアクセス許可をリクエストする
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return null;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     return null;
//   }

//   // デバイスの現在の場所を返す。
//   Position position = await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );
//   return position;
// }

// マーカーの情報をcardで表示
// 今後は写真と現在位置からの距離、ルートを実装する。

//カード1枚1枚について
List<Widget> shopTiles(
    List<Place> items, double currentLatitude, double currentLongitude) {
  // final items = ref.watch(autoCompleteSearchTypeProvider);

  List<double> distances = items.map((place) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      place.latitude,
      place.longitude,
    );
    return distanceInMeters;
  }).toList();

  final shopTiles = items.asMap().entries.map(
    (entry) {
      final index = entry.key;
      final place = entry.value;
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
              child: Column(children: [
                ...(place.name == null)
                    ? [
                        const SizedBox.shrink(),
                      ]
                    : [
                        Text(place.name as String),
                        Text('現在地から${distances[index].ceilToDouble()} m')
                      ]
              ]),
            ),
          ),
        ),
      );
    },
  ).toList();
  return shopTiles;
}

Future<void> setMarkder(WidgetRef ref) async {
  // チェックになっている対象のデータをマップ上にマーカーを設置する。
  // チェックされたPlaceオブジェクトのリストを取得
  final checkedPlaces =
      await ref.read(autoCompleteSearchProvider.notifier).getCheckedPlaces();
  // チェックされたPlaceオブジェクトからMarkerを作成し、Google Mapに追加
  for (final place in checkedPlaces) {
    await ref.read(autoCompleteSearchTypeProvider.notifier).addMarker(
        place.name!, place.latitude, place.longitude, place.uid, place.check);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/model.dart/mapinitialized_model.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/googlemap_model.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/textpredictions.dart';
import 'package:flutter_crudapp/view/dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';

final mapInitLatitudePosition = StateProvider.autoDispose<double>((ref) => 0.0);
final mapInitLongitudePosition =
    StateProvider.autoDispose<double>((ref) => 0.0);
final _googlePlace = GooglePlace(Api.apiKey);
final cameraPositionProvider = StateProvider<CameraPosition>((ref) {
  return const CameraPosition(
    target: LatLng(34.702809862535936, 135.49666833132505),
    zoom: 15.0,
  );
});

class MapSample extends ConsumerWidget {
  MapSample({super.key});
  final apiKey = Api.apiKey;
  final _placeController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    // 初回のみ実行かどうか
    _initializeOnes(ref);

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                // 初回にマップが作成されたときに初期位置を設定する
                controller.moveCamera(CameraUpdate.newCameraPosition(
                  ref.watch(cameraPositionProvider),
                ));
              },
              mapType: MapType.normal,
              initialCameraPosition: ref.watch(cameraPositionProvider),
              markers: ref
                  .read(googlemapModelProvider.notifier)
                  .createMaker(ref.watch(googlemapModelProvider), 'Marker1'),
              myLocationEnabled: true,
              onTap: (LatLng latLang) {
                ref
                    .read(googlemapModelProvider.notifier)
                    .changePosition(latLang);
                print(ref.watch(googlemapModelProvider));
              },
            ),
            Align(
              alignment: const Alignment(0.8, -0.85),
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 50,
                  height: 40,
                  child: const Icon(
                    Icons.dehaze_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onTap: (() => const DropdownButtonMenu()),
              ),
            ),
            Align(
                alignment: const Alignment(-0.6, -0.85),
                child: SizedBox(
                    width: 200,
                    height: 40,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      controller: _placeController,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        iconColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                        hintText: "検索したい場所",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        fillColor: Colors.black,
                        filled: true,
                      ),
                      onChanged: (value) {
                        updatePredictions(value, ref);
                      },
                    ))),
            Align(
                alignment: const Alignment(0.94, 0.8),
                child: FloatingActionButton(
                    child: const Icon(Icons.add), onPressed: () => {}))
          ],
        ),
      ),
    );
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
    // 初回のみ実行する非同期処理
    if (ref.watch(mapInitializedModelProvider)) {
      final position = await _determinePosition();
      final latitude = position.latitude;
      final longitude = position.longitude;
      final initCameraPosition = LatLng(latitude, longitude);
      final newCameraPosition =
          CameraPosition(target: initCameraPosition, zoom: 15.0);
      ref.read(cameraPositionProvider.notifier).state = newCameraPosition;
      ref.read(mapInitializedModelProvider.notifier).changeInit();
    }
  }

  void updatePredictions(String value, WidgetRef ref) async {
    if (value.isEmpty) {
      ref.read(textPredictionsProvider.notifier).noneList();
      return;
    }

    final response = await _googlePlace.autocomplete.get(value);
    if (response != null && response.predictions != null) {
      ref
          .read(textPredictionsProvider.notifier)
          .changeList(response.predictions!);
    }
  }
  // Future<CameraPosition> _initPosition(latitude, longitude) async {
  //   // 現在位置を取得するメソッドの結果を取得する。
  //   final cameraPosition = await CameraPosition(
  //     target: LatLng(latitude, longitude),
  //     zoom: 15,
  //   );
  //   return cameraPosition;
  // }
  //   final latitude = position.latitude;
  //   final longitude = position.longitude;
  //   String? isSelectMenu = "";
  //   Uri? mapURL;

  //   // googlemapと同じAPIキーを指定
  //   final googlePlace = GooglePlace(apiKey);

  //   // 検索処理 googlePlace.search.getNearBySearch() 近くの検索
  //   final response = await googlePlace.search.getNearBySearch(
  //       Location(lat: latitude, lng: longitude), 1000,
  //       language: 'ja', keyword: isSelectMenu, rankby: RankBy.Distance);

  //   final results = response!.results;
  //   final isExist = results?.isNotEmpty ?? false;

  //   if (isExist) {
  //     return;
  //   }

  //   final firstResult = results?.first;
  //   final selectLocation = firstResult?.geometry?.location;
  //   final selectLocationLatitude = selectLocation?.lat;
  //   final selectLocationLongitude = selectLocation?.lng;

  //   String urlString = '';
  //   if (Platform.isAndroid) {
  //     urlString =
  //         'https://www.google.co.jp/maps/dir/$latitude,$longitude/$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
  //   } else if (Platform.isIOS) {
  //     urlString =
  //         'comgooglemaps://?saddr=$latitude,$longitude&daddr=$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
  //   }

  //   mapURL = Uri.parse(urlString);
  // }
}

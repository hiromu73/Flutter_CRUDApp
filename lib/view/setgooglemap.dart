import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';

// GoogleMapの表示
class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapSample> {
  Position? currentPosition;
  // GoogleMapControllerのインスタンス作成
  late StreamSubscription<Position> positionStream;
  final Completer _conpleter = Completer();
  final apiKey = Api.apiKey;
  String? isSelectMenu = "";
  Uri? mapURL;
  bool? isExist;
  LatLng _location = const LatLng(34.758663, 135.4971856623888);
  final selectLocationLatitude = "";
  final selectLocationLongitude = "";

  @override
  void initState() {
    super.initState();
    // initState()はFutureできないのでメソッドを格納。
    // initialize();
  }

  static const _cameraPosition = CameraPosition(
    target: LatLng(34.758663, 135.4971856623888),
    zoom: 16,
  );

  Future<void> searchLocation(List result) async {
    final GoogleMapController controller = await _conpleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(result[0], result[1]),
    )));
  }

  // 位置情報とマーカーIDを指定してマーカーを表示する関数
  Set<Marker> _createMaker(LatLng latLng, String markerId) {
    return {
      Marker(
        markerId: MarkerId(markerId),
        position: latLng,
      ),
    };
  }

  // サークルの詳細
  final circles = <Circle>{
    Circle(
      circleId: const CircleId('CircleId1'),
      fillColor: Colors.lightBlue.withOpacity(0.1),
      radius: 100,
      strokeWidth: 1,
    )
  };

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            const Icon(Icons.search),
            DropdownButton(
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: "",
                  child: Text(""),
                ),
                DropdownMenuItem(
                  value: "スーパー",
                  child: Text("スーパー"),
                ),
                DropdownMenuItem(
                  value: "薬局",
                  child: Text("薬局"),
                ),
                DropdownMenuItem(
                  value: "レストラン",
                  child: Text("レストラン"),
                ),
                DropdownMenuItem(
                  value: "ファーストフード",
                  child: Text("ファーストフード"),
                ),
                DropdownMenuItem(
                  value: "カフェ",
                  child: Text("カフェ"),
                ),
                DropdownMenuItem(
                  value: "本屋",
                  child: Text("本屋"),
                ),
                DropdownMenuItem(
                  value: "病院",
                  child: Text("病院"),
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              onChanged: (String? value) async {
                setState(() {
                  isSelectMenu = value!;
                });
                if (isSelectMenu != "") {
                  await initialize();
                }
                if (value != "") {
                  launchUrl(mapURL!);
                }
              },
              value: isSelectMenu,
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {},
              mapType: MapType.normal,
              initialCameraPosition: _cameraPosition,
              markers: _createMaker(_location, 'Marker1'),
              myLocationEnabled: true,
              // タップした場所の緯度と軽度が返される。
              onTap: (LatLng latLang) {
                setState(() {
                  _location = latLang;
                  _createMaker(_location, 'Marker1');
                });
              },
              circles: circles,
            ),
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: FloatingActionButton.extended(
        //     onPressed: () async {
        //       await FirebaseFirestore.instance.collection('post').doc().set({
        //         'latitude': _location.latitude,
        //         'longitude': _location.longitude,
        //       });
        //       Navigator.of(context).pop();
        //     },
        //     icon: const Icon(Icons.add),
        //     label: const Text("位置情報を登録する")),
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
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future initialize() async {
    // 現在位置を取得するメソッドの結果を取得する。
    final position = await _determinePosition();
    final latitude = position.latitude;
    final longitude = position.longitude;

    // googlemapと同じAPIキーを指定
    final googlePlace = GooglePlace(apiKey);

    // 検索処理 googlePlace.search.getNearBySearch() 近くの検索
    final response = await googlePlace.search.getNearBySearch(
        Location(lat: latitude, lng: longitude), 1000,
        language: 'ja', keyword: isSelectMenu, rankby: RankBy.Distance);

    final results = response!.results;
    final isExist = results?.isNotEmpty ?? false;

    setState(() {
      _location = LatLng(latitude, longitude);
      this.isExist = isExist;
    });

    if (!isExist) {
      return;
    }

    final firstResult = results?.first;
    final selectLocation = firstResult?.geometry?.location;
    final selectLocationLatitude = selectLocation?.lat;
    final selectLocationLongitude = selectLocation?.lng;

    String urlString = '';
    if (Platform.isAndroid) {
      urlString =
          'https://www.google.co.jp/maps/dir/$latitude,$longitude/$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
    } else if (Platform.isIOS) {
      urlString =
          'comgooglemaps://?saddr=$latitude,$longitude&daddr=$selectLocationLatitude,$selectLocationLongitude&directionsmode=bicycling';
    }

    mapURL = Uri.parse(urlString);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'searchPage.dart';

// GoogleMapの表示
class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MapSample> {
  Position? currentPosition;
  // GoogleMapControllerのインスタンス作成
  late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  final Completer _conpleter = Completer();

  // 現在位置の取得
  // デバイスの現在の場所を照会するには、単に getCurrentPosition メソッド
  Future<LatLng> nowPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      // 正確性：highはAndroid(0-100m),iOS(10m)
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> searchLocation(List result) async {
    final GoogleMapController controller = await _conpleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(result[0], result[1]),
    )));
  }

  final LocationSettings locationSettings = const LocationSettings(
    // 正確性：highはAndroid(0-100m),iOS(10m)
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

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
      circleId: CircleId('CircleId1'),
      fillColor: Colors.lightBlue.withOpacity(0.1),
      radius: 100,
      strokeWidth: 1,
    )
  };
  static final _cameraPosition = CameraPosition(
    target: LatLng(34.758663, 135.4971856623888),
    zoom: 16,
  );
  LatLng _location = LatLng(34.758663, 135.4971856623888);
  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        appBar: AppBar(
          title: Text('位置情報を取得'),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SerachPage();
                })).then((value) async {
                  await searchLocation(value);
                })
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              //デフォルトのコンパスを削除
              compassEnabled: false,
              //デフォルトの現在位置移動ボタンを非表示
              myLocationButtonEnabled: true,
              // mapが作成される時にonMapCreatedでGoogleMapControllerのインスタンスを格納
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              mapType: MapType.normal,
              //  マップの初期の位置(必須)
              initialCameraPosition: _cameraPosition,
              // マーカーを表示
              markers: _createMaker(_location, 'Marker1'),
              myLocationEnabled: true,
              // タップした場所の緯度と軽度が返される。
              onTap: (LatLng latLang) {
                setState(() {
                  _location = latLang;
                  _createMaker(_location, 'Marker1');
                  // print(latLang);
                  // 34.761718725408855, 135.48417393118143
                });
              },
              // マップ上に円を表示
              circles: circles,
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => {
                  // 位置情報を取得し登録を行う。
                },
            icon: const Icon(Icons.add),
            label: Text("位置情報を登録する")),
      ),
    );
  }
}

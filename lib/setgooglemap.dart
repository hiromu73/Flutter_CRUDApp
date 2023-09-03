import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  // 現在位置の取得
  // デバイスの現在の場所を照会するには、単に getCurrentPosition メソッド
  Future<LatLng> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      // 正確性：highはAndroid(0-100m),iOS(10m)
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

// 初期位置
  // final CameraPosition _kGooglePlex = const CameraPosition(
  //   target: LatLng(35, 135),
  //   zoom: 11,
  // );

// 初期のマーカー位置
  // LatLng _location = LatLng(35, 135);

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

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return FutureBuilder<LatLng>(
      future: getCurrentLocation(),
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var _location = snapshot.data ?? LatLng(35, 135);

        final _cameraPosition = CameraPosition(
          target: _location,
          zoom: 16,
        );
        return Container(
          height: height,
          width: width,
          child: Scaffold(
            appBar: AppBar(
              title: Text('位置情報を取得'),
              actions: [
                IconButton(icon: Icon(Icons.search), onPressed: () => {},)
              ],
            ),
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  //デフォルトのコンパスを削除
                  compassEnabled: false,
                  //デフォルトの現在位置移動ボタンを非表示
                  myLocationButtonEnabled: false,
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
                      _createMaker(_location = latLang, 'NewMarker');
                      print(latLang.latitude);
                    });
                  },
                  // マップ上に円を表示
                  circles: circles,
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton(
                onPressed: () => {
                      // 位置情報を取得し登録を行う。
                    }),
          ),
        );
      },
    );
  }
}

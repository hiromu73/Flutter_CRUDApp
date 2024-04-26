import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/map/view_model/latitude.dart';
import 'package:memoplace/ui/map/view_model/longitude.dart';
import 'package:memoplace/ui/memo/view/memolist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// メモの一覧を表示
class MemoApp extends HookConsumerWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      _checkLocationPermission(context, ref);
      return null;
    });
    final viewType = useState<bool>(false);
    void changeView() {
      viewType.value = !viewType.value;
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: MemoList(viewType.value)),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.background,
              heroTag: "add",
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => context.push('/addpage')),
          const SizedBox(
            width: 100,
          ),
          FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.background,
              heroTag: "change",
              child: Icon(
                Icons.apps,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => changeView()),
        ],
      ),
    );
  }

  Future<void> _checkLocationPermission(
      BuildContext context, WidgetRef ref) async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.denied) {
      print("許可している");
      final position = await _determinePosition();
      ref.read(latitudeProvider.notifier).changeLatitude(position.latitude);
      ref.read(longitudeProvider.notifier).changeLongitude(position.longitude);
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
      // return Future.error('デバイスの場所を取得するための許可してください');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    }

    // デバイスの現在の場所を返す。
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }
}

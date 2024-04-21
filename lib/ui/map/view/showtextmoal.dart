// テキスト検索モーダル
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memoplace/constants/string.dart';
import 'package:memoplace/model/map/place.dart';
import 'package:memoplace/ui/map/view/set_googlemap.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search_type.dart';
import 'package:memoplace/ui/map/view_model/latitude.dart';
import 'package:memoplace/ui/map/view_model/longitude.dart';
import 'package:memoplace/ui/map/view_model/select_item.dart';

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
      height: MediaQuery.of(context).size.height * 0.9,
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
                  if (categoryList.containsKey(trimmedJapaneseName)) {
                    englishNames.add(categoryList[trimmedJapaneseName]!);
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
          Expanded(
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: autoCompleteSearch.length,
                itemBuilder: (context, index) {
                  return menuItem(
                      autoCompleteSearch[index], latitude, longitude, ref);
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // 非同期後にcontextが変わってしまう為、現在のcontextを取得しておく。
                  final localContext = context;

                  // チェックされたPlaceオブジェクトのリストを取得
                  final checkedPlaces = await ref
                      .read(autoCompleteSearchProvider.notifier)
                      .getCheckedPlaces();

                  // チェックされたPlaceオブジェクトからMarkerを作成し、Google Mapに追加
                  for (final place in checkedPlaces) {
                    // 既にcheckがtrueになっている要素のnameを取得し、一致指定あたら追加しない。
                    if (!ref.watch(autoCompleteSearchTypeProvider).any(
                        (element) =>
                            element.name == place.name &&
                            element.check == true)) {
                      await ref
                          .read(autoCompleteSearchTypeProvider.notifier)
                          .addMarker(place.name!, place.latitude,
                              place.longitude, place.uid, place.check);
                    }
                  }
                  if (context.mounted) {
                    Navigator.pop(localContext, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: const Text(serach),
              ),
              const SizedBox(width: 50),
              ElevatedButton(
                  onPressed: () async {
                    // マップ上のマーカーも全て消す。
                    // リスト上のtrueをfalseにする。
                    await ref
                        .read(autoCompleteSearchTypeProvider.notifier)
                        .noneAutoCompleteSearch();
                    textController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text(clear))
            ],
          )
        ],
      ),
    );
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
                subtitle: Text('現在地から${distanceInMeters.toStringAsFixed(0)} m'),
                trailing: Checkbox(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    value: place.check,
                    onChanged: (bool? value) async {
                      await ref
                          .read(autoCompleteSearchProvider.notifier)
                          .checkChange(place.uid, value);
                      // setMarkder(ref);
                    }),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        if (place.check == false) {
          await ref
              .read(autoCompleteSearchProvider.notifier)
              .checkChange(place.uid, true);
        } else {
          await ref
              .read(autoCompleteSearchProvider.notifier)
              .checkChange(place.uid, false);
        }
      },
    );
  }
}

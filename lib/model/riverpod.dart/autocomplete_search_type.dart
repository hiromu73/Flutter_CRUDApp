import 'dart:math';

import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/model/place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'autocomplete_search_type.g.dart';

// マーカーに設定する状態を管理する。
@riverpod
class AutoCompleteSearchType extends _$AutoCompleteSearchType {
  final _apiKey = Api.apiKey;
  @override
  List<Place> build() => [];

// 簡易検索処理
  Future<void> autoCompleteSearchType(List<String> typesList,
      double currentLatitude, double currentLongitude) async {
    List<Place> places = [];
    const apiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    for (String type in typesList) {
      final response = await http.get(Uri.parse(
          '$apiUrl?key=$_apiKey&location=$currentLatitude,$currentLongitude&radius=500&types=$type&language=ja'));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final results = decodedResponse['results'] as List<dynamic>;

        for (var result in results) {
          if (result is Map<String, dynamic>) {
            final geometry = result['geometry'];
            final location = geometry['location'];
            final latitude = location['lat'];
            final longitude = location['lng'];
            final name = result['name'];
            final uid =
                '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
            final place = Place(
                name: name,
                latitude: latitude,
                longitude: longitude,
                uid: uid,
                check: false);
            places.add(place);
          }
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    }
    state = places;
  }

  Future<void> addMarker(String name, double latitude, double longitude,
      String uid, bool check) async {
    // 指定された条件を満たす最初の要素のインデックスを返す。
    final existingPlaceName = state.indexWhere((place) => place.name == name);
    if (existingPlaceName == -1) {
      // 存在しない場合は新しいPlaceを追加
      final newPlace = Place(
        name: name,
        latitude: latitude,
        longitude: longitude,
        uid: uid,
        check: check,
      );
      if (state.isEmpty) {
        state = [newPlace];
      } else {
        state = [...state, newPlace];
      }
    }
  }

  Future<void> onTapAddMarker(
      double latitude, double longitude, String uid, bool check) async {
    // 既存のPlaceを検索
    final existingPlaceIndex = state.indexWhere((place) => place.uid == uid);
    if (existingPlaceIndex >= 0) {
      // 既に存在する場合は削除
      state = List<Place>.from(state)..removeAt(existingPlaceIndex);
    } else {
      // 存在しない場合は新しいPlaceを追加
      final newPlace = Place(
        latitude: latitude,
        longitude: longitude,
        uid: uid,
        check: check,
      );
      state = [...state, newPlace];
    }
  }

  // マーカーの色を更新するために状態を更新
  Future<void> toggleMarkerCheck(String uid) async {
    state = state.map((place) {
      if (place.uid == uid) {
        // チェック状態を切り替え
        return place.copyWith(check: !place.check);
      }
      return place;
    }).toList();
    state = state;
  }

  // trueをfalseに変更する。
  Future<void> checkFalseChange() async {
    state = state.map((place) {
      if (place.check == true) {
        // チェック状態を切り替え
        return place.copyWith(check: !place.check);
      }
      return place;
    }).toList();
    state = state;
  }

  // マーカーが設置されている状態を取得するメソッド
  Future<List<String?>> getSetMarkers() async {
    return state.map((place) => place.name).toList();
  }

  Future<void> noneAutoCompleteSearch() async {
    state = [];
  }
}

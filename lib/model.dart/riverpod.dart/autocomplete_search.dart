import 'dart:math';

import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/model.dart/place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'autocomplete_search.g.dart';

// テキスト入力検索処理
@riverpod
class AutoCompleteSearch extends _$AutoCompleteSearch {
  final _apiKey = Api.apiKey;
  @override
  List<Place> build() => [];

// Typeありテキスト検索
  Future<void> autoCompleteTypeSearch(String value, List<String?> types,
      double currentLatitude, double currentLongitude) async {
    const apiUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    for (String? type in types) {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?input=$value&key=$_apiKey&location=$currentLatitude,$currentLongitude&radius=5&types=$type&language=ja'),
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final predictions = decodedResponse['predictions'];

        List<Place> places = [];

        for (var prediction in predictions) {
          if (prediction['place_id'] is String) {
            final placeId = prediction['place_id'] as String;
            final placeDetails = await getPlaceDetails(placeId);
            if (placeDetails != null) {
              places.add(placeDetails);
            }
          }
        }
        state = places;
      } else {
        print('Error: ${response.statusCode}');
      }
    }
  }

// Type無しテキスト検索
  Future<void> autoCompleteSearch(
      String value, double currentLatitude, double currentLongitude) async {
    const apiUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final response = await http.get(
      Uri.parse(
          '$apiUrl?input=$value&key=$_apiKey&location=$currentLatitude,$currentLongitude&radius=50&&language=ja'),
    );
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final predictions = decodedResponse['predictions'];

      List<Place> places = [];

      for (var prediction in predictions) {
        if (prediction['place_id'] is String) {
          final placeId = prediction['place_id'] as String;
          final placeDetails = await getPlaceDetails(placeId);
          if (placeDetails != null) {
            places.add(placeDetails);
          }
        }
      }
      state = places;
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> noneAutoCompleteSearch() async {
    state = [];
  }

  Future<Place?> getPlaceDetails(String placeId) async {
    const detailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
    final detailsResponse = await http.get(
      Uri.parse('$detailsUrl?place_id=$placeId&key=$_apiKey&language=ja'),
    );

    if (detailsResponse.statusCode == 200) {
      final detailsDecodedResponse = json.decode(detailsResponse.body);
      final result = detailsDecodedResponse['result'];

      if (result is Map<String, dynamic>) {
        final geometry = result['geometry'];
        final location = geometry['location'];
        final latitude = location['lat'];
        final longitude = location['lng'];
        final name = result['name'];
        final uid =
            '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

        return Place(
            name: name,
            latitude: latitude,
            longitude: longitude,
            uid: uid,
            check: false);
      }
    }
  }

// チェックの変更
  Future<void> checkChange(String uid, bool? check) async {
    state = [
      for (final place in state)
        if (place.uid == uid) place.copyWith(check: check) else place,
    ];
  }

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

  // チェックがtrueのPlaceオブジェクトのリストを取得するメソッド
  Future<List<Place>> getCheckedPlaces() async {
    return state.where((place) => place.check).toList();
  }
}

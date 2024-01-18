import 'dart:math';

import 'package:flutter_crudapp/api.dart';
import 'package:flutter_crudapp/model.dart/place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'autocomplete_search_type.g.dart';

// 簡易検索処理
@riverpod
class AutoCompleteSearchType extends _$AutoCompleteSearchType {
  final _apiKey = Api.apiKey;
  @override
  List<Place> build() => [];

  Future<void> autoCompleteSearchType(List<String> types,
      double currentLatitude, double currentLongitude) async {
    List<Place> places = [];
    print(types);
    const apiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    final response = await http.get(
      Uri.parse(// radius=500だと5000より多く出る。50だと全くでない現在地に近いののも。時間があるときに調査する。
          '$apiUrl?key=$_apiKey&location=$currentLatitude,$currentLongitude&radius=500&types=$types&language=ja'),
    );
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
          );
          places.add(place);
        }
      }
      state = places;
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> noneAutoCompleteSearch() async {
    const apiUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    List<Place> places = [];
    final uid =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    final place = Place(
      name: "",
      latitude: 0.0,
      longitude: 0.0,
      uid: uid,
    );
    places.add(place);

    state = places;
  }
}

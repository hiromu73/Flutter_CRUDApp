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
    const apiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    for (String type in types) {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?key=$_apiKey&location=$currentLatitude,$currentLongitude&radius=5000&types=$type&language=ja'),
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
        print(places);
        state = places;
      } else {
        print('Error: ${response.statusCode}');
      }
    }
  }

  Future<void> noneAutoCompleteSearch(
      String value, double currentLatitude, double currentLongitude) async {
    const apiUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final response = await http.get(
      Uri.parse(
          // radiusで半径を調整する。
          '$apiUrl?input=$value&key=$_apiKey&location=$currentLatitude,$currentLongitude&radius=5000'),
    );
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final predictions = decodedResponse['predictions'];
      final places = predictions.map<String>((prediction) {
        if (prediction['description'] is String) {
          return prediction['description'] as String;
        } else {
          return 'Unknown Place';
        }
      }).toList();
      state = places;
    } else {
      print('Error: ${response.statusCode}');
    }
  }
}

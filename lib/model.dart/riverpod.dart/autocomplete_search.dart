import 'package:flutter_crudapp/api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'autocomplete_search.g.dart';

@riverpod
class AutoCompleteSearch extends _$AutoCompleteSearch {
  final _apiKey = Api.apiKey;
  @override
  List<String> build() => [];

  // 検索処理
  Future<void> autoCompleteSearch(
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

      print(predictions);
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

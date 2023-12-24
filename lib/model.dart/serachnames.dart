import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> serachNames(String searchTerm) async {
  final response =
      await http.get('https://example.com/api/stores?search=$searchTerm' as Uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((store) => store['name'].toString()).toList();
  } else {
    throw Exception('Failed to load store names');
  }
}

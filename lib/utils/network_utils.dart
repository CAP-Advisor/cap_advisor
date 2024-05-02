import 'package:http/http.dart' as http;

class NetworkUtils {
  static Future<void> makeGetRequest(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
    } else if (response.statusCode == 201) {
      print('Resource created');
    } else if (response.statusCode == 400) {
      print('Bad request: ${response.body}');
    } else if (response.statusCode == 401) {
      print('Unauthorized: ${response.body}');
    } else if (response.statusCode == 404) {
      print('Resource not found: ${response.body}');
    } else if (response.statusCode == 500) {
      print('Internal server error: ${response.body}');
    } else {
      print('Request failed with status code: ${response.statusCode}');
    }
  }
}

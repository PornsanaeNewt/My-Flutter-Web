import 'dart:convert';
import 'package:http/http.dart' as http;

const String googleMapsApiKey = "YOUR_GOOGLE_MAPS_API_KEY";
const String googleMapsApiUrl = "https://maps.googleapis.com/maps/api/geocode/json";

class MapApi {
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    final uri = Uri.parse('$googleMapsApiUrl?address=$address&key=$googleMapsApiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK' && json['results'].isNotEmpty) {
        final location = json['results'][0]['geometry']['location'];
        return {
          'latitude': location['lat'],
          'longitude': location['lng'],
        };
      }
    }
    return null;
  }

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    final uri = Uri.parse('$googleMapsApiUrl?latlng=$lat,$lng&key=$googleMapsApiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK' && json['results'].isNotEmpty) {
        return json['results'][0]['formatted_address'];
      }
    }
    return null;
  }
}

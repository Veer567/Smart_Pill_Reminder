import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFdaService {
  static Future<Map<String, String>?> fetchMedicineDetails(String query) async {
    final url =
        'https://api.fda.gov/drug/label.json?search=openfda.generic_name:$query&limit=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] == null || data['results'].isEmpty) {
        return null;
      }

      final result = data['results'][0];
      final name = result['openfda']?['generic_name']?[0] ?? 'Unknown';
      final usage = result['purpose']?[0] ?? 'Not available';
      final sideEffects = result['adverse_reactions']?[0] ??
          result['warnings']?[0] ??
          'Not available';

      return {
        'name': name,
        'usage': usage,
        'sideEffects': sideEffects,
      };
    } else {
      return null;
    }
  }
}

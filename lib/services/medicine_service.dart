import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineService {
  Future<String?> getRxCUI(String drugName) async {
    final url = Uri.parse('https://rxnav.nlm.nih.gov/REST/rxcui.json?name=$drugName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['idGroup']?['rxnormId']?[0];
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> getDrugInfo(String rxCui) async {
    final url = Uri.parse('https://rxnav.nlm.nih.gov/REST/rxcui/$rxCui/allProperties.json?prop=all');
    final response = await http.get(url);

    String purpose = "Not found";
    String sideEffects = "Not found";

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final props = data['propConceptGroup']['propConcept'] as List<dynamic>;

      for (var prop in props) {
        if (prop['propName'] == 'Purpose') {
          purpose = prop['propValue'];
        }
        if (prop['propName'] == 'Side Effects') {
          sideEffects = prop['propValue'];
        }
      }
    }

    return {
      'purpose': purpose,
      'sideEffects': sideEffects,
    };
  }
}

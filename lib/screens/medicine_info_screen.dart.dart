import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animations/animations.dart';
import 'add_medicine_screen.dart';

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
      final sideEffects =
          result['adverse_reactions']?[0] ??
          result['warnings']?[0] ??
          'Not available';

      return {'name': name, 'usage': usage, 'sideEffects': sideEffects};
    } else {
      return null;
    }
  }
}

class MedicineInfoScreen extends StatefulWidget {
  const MedicineInfoScreen({super.key});

  @override
  State<MedicineInfoScreen> createState() => _MedicineInfoScreenState();
}

class _MedicineInfoScreenState extends State<MedicineInfoScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, String>? medicineInfo;
  bool isLoading = false;
  bool isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchMedicineInfo(String query) async {
    setState(() {
      isLoading = true;
      isExpanded = false; // Reset to collapsed on new search
    });

    final result = await OpenFdaService.fetchMedicineDetails(query);

    setState(() {
      medicineInfo = result;
      isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data found. Please try another.")),
      );
    }
  }

  void _toggleExpand() {
    setState(() => isExpanded = !isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Info"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildSearchButton(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : medicineInfo != null
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _toggleExpand,
                            child: _buildMedicineCard(
                              "Name",
                              medicineInfo!['name']!,
                              Icons.medical_services,
                              isExpanded: true,
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            _buildMedicineCard(
                              "Uses",
                              medicineInfo!['usage']!,
                              Icons.info,
                              isExpandable: true,
                            ),
                            const SizedBox(height: 12),
                            _buildMedicineCard(
                              "Side Effects",
                              medicineInfo!['sideEffects']!,
                              Icons.warning,
                              isExpandable: true,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddMedicineScreen(
                                      existingData: {
                                        'name': medicineInfo!['name'],
                                      },
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.alarm_add),
                              label: const Text("Add Reminder"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        "Search for a medicine to see details",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Enter generic medicine name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.search, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onSubmitted: (value) => fetchMedicineInfo(value),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      onPressed: () => fetchMedicineInfo(_controller.text),
      icon: const Icon(Icons.search),
      label: const Text("Search"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    );
  }

  Widget _buildMedicineCard(
    String title,
    String content,
    IconData icon, {
    bool isExpanded = false,
    bool isExpandable = false,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.teal, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              isExpandable
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        content,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    )
                  : Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                      maxLines: isExpanded ? null : 1,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

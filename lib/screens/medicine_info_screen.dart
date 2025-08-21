import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animations/animations.dart';
import 'add_medicine_screen.dart';

class OpenFdaService {
  static Future<Map<String, dynamic>?> fetchMedicineDetails(
    String query,
  ) async {
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
      final sideEffectsData =
          result['adverse_reactions'] ??
          result['warnings'] ??
          ['Not available'];

      return {
        'name': name,
        'usage': usage,
        'sideEffects': sideEffectsData is List
            ? sideEffectsData
            : [sideEffectsData.toString()],
      };
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
  Map<String, dynamic>? medicineInfo;
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
        SnackBar(
          content: const Text("No data found. Please try another."),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void _toggleExpand() {
    setState(() => isExpanded = !isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1E847F);
    const Color primaryCoral = Color(0xFFF08080);
    const Color accentTeal = Color(0xFF26A69A);
    const Color accentCoral = Color(0xFFFFA07A);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Medicine Info"),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(primaryTeal, accentTeal),
            const SizedBox(height: 16),
            _buildSearchButton(primaryTeal),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryTeal),
                    )
                  : medicineInfo != null
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          OpenContainer(
                            transitionType: ContainerTransitionType.fadeThrough,
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                            closedBuilder: (context, openContainer) =>
                                GestureDetector(
                                  onTap: _toggleExpand,
                                  child: _buildMedicineCard(
                                    "Name",
                                    medicineInfo!['name']!,
                                    Icons.medical_services,
                                    primaryTeal,
                                    accentTeal,
                                    isExpanded: true,
                                  ),
                                ),
                            openBuilder: (context, _) => Container(),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            _buildMedicineCard(
                              "Uses",
                              medicineInfo!['usage']!,
                              Icons.info,
                              primaryTeal,
                              accentTeal,
                              isExpandable: true,
                            ),
                            const SizedBox(height: 12),
                            _buildMedicineCard(
                              "Side Effects",
                              medicineInfo!['sideEffects'],
                              Icons.warning,
                              primaryTeal,
                              accentTeal,
                              isExpandable: true,
                              isDynamicList: true,
                            ),
                            const SizedBox(height: 12),
                            _buildAddReminderButton(primaryTeal, context),
                          ],
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        "Search for a medicine to see details",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(Color primaryTeal, Color accentTeal) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Enter generic medicine name',
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search, color: primaryTeal),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryTeal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      onSubmitted: (value) => fetchMedicineInfo(value),
    );
  }

  Widget _buildSearchButton(Color primaryTeal) {
    return ElevatedButton.icon(
      onPressed: () => fetchMedicineInfo(_controller.text),
      icon: const Icon(Icons.search, size: 20),
      label: const Text("Search", style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        elevation: 3,
        shadowColor: primaryTeal.withOpacity(0.3),
      ),
    );
  }

  Widget _buildAddReminderButton(Color primaryTeal, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMedicineScreen(
              existingData: {'name': medicineInfo!['name']},
            ),
          ),
        );
      },
      icon: const Icon(Icons.alarm_add, size: 20),
      label: const Text("Add Reminder", style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        elevation: 3,
        shadowColor: primaryTeal.withOpacity(0.3),
      ),
    );
  }

  Widget _buildMedicineCard(
    String title,
    dynamic content,
    IconData icon,
    Color primaryTeal,
    Color accentTeal, {
    bool isExpanded = false,
    bool isExpandable = false,
    bool isDynamicList = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryTeal.withOpacity(0.2), width: 1),
      ),
      elevation: 8,
      shadowColor: primaryTeal.withOpacity(0.4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryTeal.withOpacity(0.1),
                accentTeal.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryTeal.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryTeal, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isDynamicList && content is List)
                        SizedBox(
                          height: 150, // Fixed height for scrollable area
                          child: ListView.builder(
                            itemCount: content.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        content[index].toString().trim(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[900],
                                          height: 1.6, // Increased line spacing
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Text(
                          content.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[900],
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                          maxLines: isExpanded || isExpandable ? null : 3,
                          overflow: isExpanded || isExpandable
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (isExpandable &&
                        (content is String &&
                            (content.length > 100 || content.contains('\n')) &&
                            !isExpanded) ||
                    (content is List && content.length > 3 && !isExpanded))
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: _toggleExpand,
                      child: Row(
                        children: [
                          Text(
                            isExpanded ? 'Show Less' : 'Show More',
                            style: TextStyle(
                              color: primaryTeal,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: primaryTeal,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

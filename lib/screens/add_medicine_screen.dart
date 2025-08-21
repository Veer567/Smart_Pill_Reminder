import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const AddMedicineScreen({super.key, this.docId, this.existingData});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Select Option';
  final List<String> _medicineTypes = ['Capsule', 'Drop', 'Tablet'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _dosesPerDayController = TextEditingController();
  List<TimeOfDay> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _doseController.text = widget.existingData!['dose'] ?? '';
      _amountController.text = widget.existingData!['amount'] ?? '';
      _selectedType = widget.existingData!['type'] ?? 'Select Option';
      _stockController.text = (widget.existingData!['stock'] ?? 0).toString();

      final dosesPerDay = widget.existingData!['dosesPerDay'] ?? 1;
      _dosesPerDayController.text = dosesPerDay.toString();
      _selectedTimes = [];

      final timesList = widget.existingData!['times'] as List<dynamic>?;
      if (timesList != null) {
        for (var timeStr in timesList) {
          final parts = (timeStr as String).split(':');
          _selectedTimes.add(
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
          );
        }
      }
    }
  }

  Future<void> _addTime(int index) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTimes.length > index
          ? _selectedTimes[index]
          : TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (_selectedTimes.length > index) {
          _selectedTimes[index] = pickedTime;
        } else {
          _selectedTimes.add(pickedTime);
        }
      });
    }
  }

  Future<void> _scheduleLocalNotification(
    String docId,
    String name,
    List<TimeOfDay> times,
    int stock,
    int dosesPerDay,
  ) async {
    await NotificationService.scheduleDailyNotification(
      docId: docId,
      name: name,
      times: times,
      stock: stock,
      dosesPerDay: dosesPerDay,
    );
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
        title: const Text("Add New Medicine"),
        centerTitle: true,
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Please fill out the details below to add or update a medicine.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryTeal.withOpacity(0.3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Basic Information",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Medicine Name",
                              hintText: "e.g. Ibuprofen",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorMaxLines: 2,
                              helperText: "Enter the name of the medicine.",
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryTeal,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a medicine name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedType == 'Select Option'
                                ? null
                                : _selectedType,
                            items: _medicineTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedType = val!;
                                if (_selectedType == 'Drop') {
                                  _doseController.clear();
                                  _stockController.clear();
                                } else if (widget.existingData != null &&
                                    widget.existingData!['type'] == 'Drop') {
                                  _doseController.text =
                                      widget.existingData!['dose'] ?? '';
                                  _stockController.text =
                                      (widget.existingData!['stock'] ?? 0)
                                          .toString();
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Type",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              helperText: "Select the medicine type.",
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryTeal,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value == 'Select Option') {
                                return 'Please select a medicine type';
                              }
                              return null;
                            },
                          ),
                          if (_selectedType != 'Drop')
                            const SizedBox(height: 16),
                          if (_selectedType != 'Drop')
                            TextFormField(
                              controller: _doseController,
                              decoration: InputDecoration(
                                labelText: "Dose",
                                hintText: "e.g. 100mg",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                helperText: "Enter the dosage (e.g., 100mg).",
                                filled: true,
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryTeal,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a dose';
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryTeal.withOpacity(0.3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Stock and Dosage",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedType != 'Drop')
                            TextFormField(
                              controller: _stockController,
                              decoration: InputDecoration(
                                labelText: "Stock",
                                hintText: "e.g. 30",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                helperText:
                                    "Enter the initial number of units.",
                                filled: true,
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryTeal,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter the initial stock';
                                }
                                if (int.tryParse(value.trim()) == null ||
                                    int.parse(value.trim()) < 0) {
                                  return 'Please enter a valid non-negative number';
                                }
                                return null;
                              },
                            ),
                          if (_selectedType != 'Drop')
                            const SizedBox(height: 16),
                          TextFormField(
                            controller: _dosesPerDayController,
                            decoration: InputDecoration(
                              labelText: "Doses Per Day",
                              hintText: "e.g. 1",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              helperText: "Enter the total doses per day.",
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryTeal,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final numDoses = int.tryParse(value) ?? 0;
                              setState(() {
                                while (_selectedTimes.length > numDoses) {
                                  _selectedTimes.removeLast();
                                }
                                while (_selectedTimes.length < numDoses) {
                                  _selectedTimes.add(TimeOfDay.now());
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the number of doses per day';
                              }
                              if (int.tryParse(value.trim()) == null ||
                                  int.parse(value.trim()) <= 0) {
                                return 'Please enter a valid positive number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryTeal.withOpacity(0.3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reminder Times",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedTimes.isEmpty)
                            Text(
                              'Please enter doses per day to set times.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ...List.generate(_selectedTimes.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Dose ${index + 1}: ${_selectedTimes[index].format(context)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[900],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _addTime(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryTeal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text("Set Time"),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedType == 'Select Option') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a valid medicine type."),
                        ),
                      );
                      return;
                    }
                    if (_selectedTimes.isEmpty && _selectedType != 'Drop') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please set at least one reminder time.",
                          ),
                        ),
                      );
                      return;
                    }

                    final service = FirestoreService();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      String docIdToUse;
                      final timesString = _selectedTimes
                          .map((t) => '${t.hour}:${t.minute}')
                          .toList();

                      if (widget.docId != null) {
                        await service.updateMedicine(
                          docId: widget.docId!,
                          name: _nameController.text.trim(),
                          type: _selectedType,
                          dose: _selectedType != 'Drop'
                              ? _doseController.text.trim()
                              : '',
                          amount: _amountController.text.trim(),
                          times: timesString,
                          stock: _selectedType != 'Drop'
                              ? (int.tryParse(_stockController.text.trim()) ??
                                    0)
                              : 0,
                          dosesPerDay:
                              int.tryParse(
                                _dosesPerDayController.text.trim(),
                              ) ??
                              1,
                        );
                        docIdToUse = widget.docId!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Medicine updated!")),
                        );
                      } else {
                        final docRef = await service.addMedicine(
                          name: _nameController.text.trim(),
                          type: _selectedType,
                          dose: _selectedType != 'Drop'
                              ? _doseController.text.trim()
                              : '',
                          amount: _amountController.text.trim(),
                          times: timesString,
                          stock: _selectedType != 'Drop'
                              ? (int.tryParse(_stockController.text.trim()) ??
                                    0)
                              : 0,
                          dosesPerDay:
                              int.tryParse(
                                _dosesPerDayController.text.trim(),
                              ) ??
                              1,
                        );
                        docIdToUse = docRef.id;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Medicine added!")),
                        );
                      }

                      if (_selectedType != 'Drop') {
                        await _scheduleLocalNotification(
                          docIdToUse,
                          _nameController.text.trim(),
                          _selectedTimes,
                          int.tryParse(_stockController.text.trim()) ?? 0,
                          int.tryParse(_dosesPerDayController.text.trim()) ?? 1,
                        );
                      }

                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.pop(context);
                    } catch (e) {
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                child: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: primaryTeal),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

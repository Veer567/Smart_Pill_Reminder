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
  TimeOfDay? _selectedTime;
  final List<String> _medicineTypes = ['Capsule', 'Drop', 'Tablet'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _doseController.text = widget.existingData!['dose'] ?? '';
      _amountController.text = widget.existingData!['amount'] ?? '';
      _selectedType = widget.existingData!['type'] ?? 'Select Option';

      final timeStr = widget.existingData!['time'];
      if (timeStr != null) {
        try {
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1].replaceAll(RegExp(r'[^\d]'), ''));
            if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
              _selectedTime = TimeOfDay(hour: hour, minute: minute);
            }
          }
        } catch (e) {
          _selectedTime = null;
        }
      }
    }
  }

  Future<void> _scheduleLocalNotification(
    String docId,
    String name,
    TimeOfDay time,
  ) async {
    try {
      await NotificationService.scheduleDailyNotification(
        docId: docId,
        title: 'Time to take your medicine!',
        body: 'It\'s time to take your $name. Don\'t forget your dose!',
        time: time,
      );
    } catch (e) {
      print('Error scheduling local notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scheduling notification: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Medicine"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Fill out the fields and hit the Save button to add it!",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "e.g. Ibuprofen",
                  border: OutlineInputBorder(),
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
                value: _selectedType == 'Select Option' ? null : _selectedType,
                items: _medicineTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedType = val!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value == 'Select Option') {
                    return 'Please select a medicine type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: "Dose",
                  hintText: "e.g. 100mg",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a dose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  hintText: "e.g. 1",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (int.tryParse(value.trim()) == null ||
                      int.parse(value.trim()) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Reminders"),
                subtitle: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : "No time selected",
                ),
                trailing: ElevatedButton(
                  child: const Text("Set Time"),
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _selectedTime != null,
                onChanged: (value) {
                  if (!value && widget.docId != null) {
                    NotificationService.cancelNotification(widget.docId!);
                  }
                  setState(() {
                    _selectedTime = value
                        ? _selectedTime ?? TimeOfDay.now()
                        : null;
                  });
                },
                title: const Text("Turn on Alarm"),
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
                    if (_selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please set a reminder time."),
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
                      final timeString =
                          '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
                      String docIdToUse;

                      if (widget.docId != null) {
                        await service.updateMedicine(
                          docId: widget.docId!,
                          name: _nameController.text.trim(),
                          type: _selectedType,
                          dose: _doseController.text.trim(),
                          amount: _amountController.text.trim(),
                          time: timeString,
                        );
                        docIdToUse = widget.docId!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Medicine updated!")),
                        );
                      } else {
                        final docRef = await service.addMedicine(
                          name: _nameController.text.trim(),
                          type: _selectedType,
                          dose: _doseController.text.trim(),
                          amount: _amountController.text.trim(),
                          time: timeString,
                        );
                        docIdToUse = docRef.id;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Medicine added!")),
                        );
                      }

                      if (_selectedTime != null) {
                        await _scheduleLocalNotification(
                          docIdToUse,
                          _nameController.text.trim(),
                          _selectedTime!,
                        );
                      }

                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.pop(context);
                    } catch (e) {
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

// StatefulWidget to manage form input and time selection
class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  // Form key to validate the form
  final _formKey = GlobalKey<FormState>();

  // Default selected type for dropdown
  String _selectedType = 'Select Option';

  // Time selected for reminders
  TimeOfDay? _selectedTime;

  // Medicine types dropdown options
  final List<String> _medicineTypes = ['Capsule', 'Drop', 'Tablet'];

  // Text controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
              // Instruction text
              const Text(
                "Fill out the fields and hit the Save button to add it!",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Name input field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "e.g. Ibuprofen",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown for medicine type
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
              ),
              const SizedBox(height: 16),

              // Dose input field
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: "Dose",
                  hintText: "e.g. 100mg",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Amount input field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  hintText: "e.g. 1",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Time picker for reminders
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
                    // Show time picker dialog
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    // Update selected time if not null
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Switch to toggle alarm (just visual in this case)
              SwitchListTile(
                value: _selectedTime != null,
                onChanged: (_) {}, // Not functional yet
                title: const Text("Turn on Alarm"),
              ),
              const SizedBox(height: 20),

              // Save button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedType == 'Select Option') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select medicine type."),
                        ),
                      );
                      return;
                    }

                    if (_selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please set reminder time."),
                        ),
                      );
                      return;
                    }

                    final firestoreService = FirestoreService();

                    try {
                      await firestoreService.addMedicine(
                        name: _nameController.text.trim(),
                        type: _selectedType,
                        dose: _doseController.text.trim(),
                        amount: _amountController.text.trim(),
                        time: _selectedTime!.format(context),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Medicine saved to Firestore!"),
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
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

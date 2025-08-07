import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String type;
  final String dose;
  final String amount;
  final String time;

  const MedicineCard({
    super.key,
    required this.name,
    required this.type,
    required this.dose,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$type • $dose • $amount unit(s)'),
        trailing: Text(time),
      ),
    );
  }
}

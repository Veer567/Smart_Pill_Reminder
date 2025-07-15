import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference medicinesCollection =
      FirebaseFirestore.instance.collection('medicines');

  Future<void> addMedicine({
    required String name,
    required String type,
    required String dose,
    required String amount,
    required String time,
  }) async {
    try {
      await medicinesCollection.add({
        'name': name,
        'type': type,
        'dose': dose,
        'amount': amount,
        'time': time,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add medicine: $e');
    }
  }
}

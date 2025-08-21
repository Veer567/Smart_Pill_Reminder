// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentReference> addMedicine({
    required String name,
    required String type,
    required String dose,
    required String amount,
    required List<String> times,

    required int stock,
    required int dosesPerDay,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .add({
            'name': name,
            'type': type,
            'dose': dose,
            'amount': amount,
            'times': times,

            'stock': stock,
            'dosesPerDay': dosesPerDay,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
      return docRef;
    } catch (e) {
      throw Exception('Failed to add medicine: ${e.toString()}');
    }
  }

  Stream<QuerySnapshot> getMedicineStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getMedicines() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();
      return querySnapshot.docs
          .map(
            (doc) => {'docId': doc.id, ...doc.data() as Map<String, dynamic>},
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch medicines: ${e.toString()}');
    }
  }

  Future<void> updateMedicine({
    required String docId,
    required String name,
    required String type,
    required String dose,
    required String amount,
    required List<String> times,

    required int stock,
    required int dosesPerDay,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .doc(docId)
          .update({
            'name': name,
            'type': type,
            'dose': dose,
            'amount': amount,
            'times': times,

            'stock': stock,
            'dosesPerDay': dosesPerDay,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update medicine: ${e.toString()}');
    }
  }

  Future<void> deleteMedicine(String docId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      await NotificationService.cancelNotification(docId);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete medicine: ${e.toString()}');
    }
  }

  Future<void> decrementStock(String docId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final medicineRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .doc(docId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(medicineRef);
        final data = snapshot.data();
        if (data != null && data.containsKey('stock')) {
          int currentStock = data['stock'];
          if (currentStock > 0) {
            transaction.update(medicineRef, {
              'stock': currentStock - 1,
              'updated_at':
                  FieldValue.serverTimestamp(), // 🔑 ensures StreamBuilder rebuild
            });
            print('Stock for $docId decremented successfully.');
          }
        }
      });
    } catch (e) {
      print('Failed to decrement stock: $e');
    }
  }
}
// This service handles Firestore operations related to medicines, including adding, updating, deleting, and fetching medicines.
// It also manages stock decrement operations and integrates with a notification service for reminders.
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
    required String time,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      return await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .add({
            'name': name,
            'type': type,
            'dose': dose,
            'amount': amount,
            'time': time,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
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
          .map((doc) => {
                'docId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
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
    required String time,
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
            'time': time,
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
}
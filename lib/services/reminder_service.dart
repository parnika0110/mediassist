import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveReminder({
    required String uid,
    required String medicineId,
    required String medicineName,
    required String slot,
    required String time,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .add({
      'medicineId': medicineId,
      'medicineName': medicineName,
      'slot': slot,
      'time': time,
      'createdAt': Timestamp.now(),
    });
  }
}
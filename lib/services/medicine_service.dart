import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveMedicine({
    required String uid,
    required String medicine,
    required String dosage,
    required String frequency,
    required String duration,
  }) async {
    final now = DateTime.now();

    int number = int.parse(
      duration.split(" ").first,
    );

    String unit =
        duration.split(" ").last.toLowerCase();

    DateTime endDate = now;

    if (unit.contains("day")) {
      endDate = now.add(
        Duration(days: number),
      );
    } else if (unit.contains("week")) {
      endDate = now.add(
        Duration(days: number * 7),
      );
    } else if (unit.contains("month")) {
      endDate = DateTime(
        now.year,
        now.month + number,
        now.day,
      );
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .add({
      'medicine': medicine,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,

      'startDate': Timestamp.fromDate(now),
      'endDate': Timestamp.fromDate(endDate),

      'createdAt': Timestamp.now(),
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> bookAppointment(Appointment appointment) async {
    await _firestore.collection('appointments').add(appointment.toMap());
  }
}

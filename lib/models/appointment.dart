import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String patientName;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String reason;
  final String doctorName;
  final String appointmentDate;
  final String appointmentTime;

  Appointment({
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.reason,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'reason': reason,
      'doctorName': doctorName,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

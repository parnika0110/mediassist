import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  // Patient Details
  final String patientId;
  final String patientName;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String reason;

  // Doctor Details
  final String doctorId;
  final String doctorName;

  // Appointment Details
  final String appointmentDate;
  final String appointmentTime;

  // Status
  final String status;
  final String doctorRemarks;

  Appointment({
    required this.patientId,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.reason,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = "Pending",
    this.doctorRemarks = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'reason': reason,

      'doctorId': doctorId,
      'doctorName': doctorName,

      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,

      'status': status,
      'doctorRemarks': doctorRemarks,

      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      reason: map['reason'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      appointmentDate: map['appointmentDate'] ?? '',
      appointmentTime: map['appointmentTime'] ?? '',
      status: map['status'] ?? 'Pending',
      doctorRemarks: map['doctorRemarks'] ?? '',
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/notification_model.dart';

import 'firestore_notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Book Appointment
  Future<void> bookAppointment(Appointment appointment) async {
    // Check whether the selected doctor already has an appointment
    // at the same date and time that is Pending or Approved.
    final existing = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: appointment.doctorId)
        .where('appointmentDate', isEqualTo: appointment.appointmentDate)
        .where('appointmentTime', isEqualTo: appointment.appointmentTime)
        .where('status', whereIn: ['Pending', 'Approved'])
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception(
        "This time slot is already booked. Please choose another time.",
      );
    }

    final data = appointment.toMap();

    data['createdAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('appointments').add(data);

    await _notificationService.addNotification(
      AppNotification(
        userId: appointment.patientId,
        title: "Appointment Booked",
        message:
            "Your appointment with Dr. ${appointment.doctorName} has been booked successfully.",
      ),
    );
  }

  // Approve Appointment
  Future<void> approveAppointment(
    String appointmentId,
    String patientId,
    String doctorName,
  ) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'Approved',
      'doctorRemarks': '',
    });

    await _notificationService.addNotification(
      AppNotification(
        userId: patientId,
        title: "Appointment Approved",
        message: "Dr. $doctorName has approved your appointment.",
      ),
    );
  }

  // Reject Appointment
  Future<void> rejectAppointment(
    String appointmentId,
    String patientId,
    String doctorName,
    String remarks,
  ) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'Rejected',
      'doctorRemarks': remarks,
    });

    await _notificationService.addNotification(
      AppNotification(
        userId: patientId,
        title: "Appointment Rejected",
        message: "Dr. $doctorName rejected your appointment.\nReason: $remarks",
      ),
    );
  }

  // Cancel Appointment
  Future<void> cancelAppointment(String appointmentId, String patientId) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'Cancelled',
      'doctorRemarks': 'Cancelled by patient',
    });

    await _notificationService.addNotification(
      AppNotification(
        userId: patientId,
        title: "Appointment Cancelled",
        message: "Your appointment has been cancelled successfully.",
      ),
    );
  }

  // Submit Doctor Rating
  // Submit Doctor Rating
  Future<void> submitRating({
    required String doctorId,
    required String patientId,
    required String appointmentId,
    required int rating,
    String review = "",
  }) async {
    final ratingRef = _firestore
        .collection('doctor_ratings')
        .doc(appointmentId);

    // Check if this appointment has already been rated
    final existingRating = await ratingRef.get();

    if (existingRating.exists) {
      throw Exception("You have already rated this appointment.");
    }

    // Save rating
    await ratingRef.set({
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'rating': rating,
      'review': review,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Calculate doctor's average rating
    final ratingsSnapshot = await _firestore
        .collection('doctor_ratings')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    double total = 0;

    for (var doc in ratingsSnapshot.docs) {
      total += (doc['rating'] as num).toDouble();
    }

    final totalRatings = ratingsSnapshot.docs.length;
    final average = totalRatings == 0 ? 0.0 : total / totalRatings;

    // Update doctor document
    await _firestore.collection('users').doc(doctorId).update({
      'rating': average,
      'totalRatings': totalRatings,
    });

    // Mark appointment as rated
    await _firestore.collection('appointments').doc(appointmentId).update({
      'isRated': true,
    });
  }

  // Get Doctors
  Stream<List<Doctor>> getDoctors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Doctor.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // Patient Profile
  // =========================
  Future<void> saveUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required int age,
    required String gender,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,

      'avatar': gender == "Male"
          ? "male"
          : gender == "Female"
              ? "female"
              : "others",

      'role': 'patient',

      'createdAt': Timestamp.now(),
    });
  }

  // =========================
  // Doctor Profile
  // =========================
  Future<void> saveDoctorProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String specialization,
    required String hospital,
    required int experience,
    required int consultationFee,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,

      'role': 'doctor',

      'specialization': specialization,
      'hospital': hospital,
      'experience': experience,
      'consultationFee': consultationFee,

      'rating': 0.0,
      'image': '',

      'createdAt': Timestamp.now(),
    });
  }
}
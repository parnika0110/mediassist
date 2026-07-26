import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../services/firestore_service.dart';
import '../widgets/doctor_card.dart';
import 'appointment_history_screen.dart';
import 'doctor_details_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class DoctorListScreen extends StatelessWidget {
  DoctorListScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
        centerTitle: true,
        actions: [
          /// Notification Bell with Badge
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: userId)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;

              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    tooltip: "Notifications",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NotificationScreen()),
                      );
                    },
                  ),

                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 99 ? "99+" : unreadCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          /// Appointment History
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Appointment History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppointmentHistoryScreen(),
                ),
              );
            },
          ),

          /// Profile
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Doctor>>(
        stream: firestoreService.getDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final doctors = snapshot.data ?? [];

          if (doctors.isEmpty) {
            return const Center(
              child: Text(
                "No doctors available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              return DoctorCard(
                doctor: doctors[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DoctorDetailsScreen(doctor: doctors[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

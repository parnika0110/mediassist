import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import 'profile_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        centerTitle: true,
        actions: [
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Pending Appointments",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointmentId = appointments[index].id;
              final data = appointments[index].data() as Map<String, dynamic>;

              final patientId = data['patientId'] ?? '';
              final doctorName = data['doctorName'] ?? '';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['patientName'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("Age: ${data['age']}"),
                      Text("Gender: ${data['gender']}"),
                      Text("Phone: ${data['phone']}"),
                      Text("Email: ${data['email']}"),
                      Text("Reason: ${data['reason']}"),
                      Text("Date: ${data['appointmentDate']}"),
                      Text("Time: ${data['appointmentTime']}"),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Approve"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                await firestoreService.approveAppointment(
                                  appointmentId,
                                  patientId,
                                  doctorName,
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Appointment Approved"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text("Reject"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                const remarks =
                                    "Appointment rejected by doctor.";

                                await firestoreService.rejectAppointment(
                                  appointmentId,
                                  patientId,
                                  doctorName,
                                  remarks,
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Appointment Rejected"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

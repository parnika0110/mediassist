import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../widgets/rating_dialog.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final patientId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment History"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: patientId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  "Firestore Error:\n\n${snapshot.error}",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Appointments Found",
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

              Color statusColor = Colors.orange;

              switch (data['status']) {
                case "Approved":
                  statusColor = Colors.green;
                  break;
                case "Rejected":
                  statusColor = Colors.red;
                  break;
                case "Cancelled":
                  statusColor = Colors.grey;
                  break;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(data['doctorName'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Patient: ${data['patientName']}"),
                            Text("Date: ${data['appointmentDate']}"),
                            Text("Time: ${data['appointmentTime']}"),
                            Text(
                              "Status: ${data['status']}",
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if ((data['doctorRemarks'] ?? "")
                                .toString()
                                .isNotEmpty)
                              Text("Remarks: ${data['doctorRemarks']}"),
                          ],
                        ),
                      ),

                      if (data['status'] == "Pending")
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel),
                              label: const Text("Cancel Appointment"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Cancel Appointment"),
                                    content: const Text(
                                      "Are you sure you want to cancel this appointment?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("No"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Yes"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await firestoreService.cancelAppointment(
                                    appointmentId,
                                    patientId,
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Appointment Cancelled"),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                      if (data['status'] == "Approved" &&
                          (data['isRated'] ?? false) == false)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.star),
                              label: const Text("Rate Doctor"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => RatingDialog(
                                    onSubmit: (rating, review) async {
                                      try {
                                        await firestoreService.submitRating(
                                          doctorId: data['doctorId'],
                                          patientId: patientId,
                                          appointmentId: appointmentId,
                                          rating: rating,
                                          review: review,
                                        );

                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Rating submitted successfully.",
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              e.toString().replaceFirst(
                                                "Exception: ",
                                                "",
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
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

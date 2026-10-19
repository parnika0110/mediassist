import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reminder_service.dart';
import 'main_navigation_screen.dart';
import '../services/notification_service.dart';
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() =>
      _ReminderScreenState();
}

class _ReminderScreenState
    extends State<ReminderScreen> {

  final ReminderService _reminderService =
      ReminderService();



  Future<void> saveReminder({
  required String medicineId,
  required String medicineName,
  required String slot,
}) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked == null) return;

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final timeString = picked.format(context);

  await _reminderService.saveReminder(
    uid: user.uid,
    medicineId: medicineId,
    medicineName: medicineName,
    slot: slot,
    time: timeString,
  );
final medicineDoc =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .doc(medicineId)
        .get();

final start =
    (medicineDoc['startDate'] as Timestamp).toDate();

final end =
    (medicineDoc['endDate'] as Timestamp).toDate();

await NotificationService.instance.scheduleMedicineCourse(
  baseId:
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
  title: "💊 Time to take $medicineName",
  body: "$slot medicine reminder",
  time: picked,
  startDate: start,
  endDate: end,
);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "$slot reminder set for $timeString",
      ),
    ),
  );
}
    
  @override
Widget build(BuildContext context) {
  final uid =
      FirebaseAuth.instance.currentUser!.uid;

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Medication Reminders",
      ),
    ),

    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('medicines')
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No medicines available",
            ),
          );
        }

        final medicines =
            snapshot.data!.docs;

        return ListView.builder(
          itemCount: medicines.length,

          itemBuilder: (context, index) {

            final medicine =
                medicines[index];

            final medicineId =
                medicine.id;

            final medicineName =
                medicine['medicine'];

            final frequency =
                medicine['frequency'];

            final parts =
                frequency.split('-');

            return Card(
              margin:
                  const EdgeInsets.all(10),

              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      medicineName,
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      "Frequency: $frequency",
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    if (parts[0] != "0")
                      ElevatedButton.icon(
                        onPressed: () =>
                            saveReminder(
                          medicineId:
                              medicineId,
                          medicineName:
                              medicineName,
                          slot:
                              "Morning",
                        ),
                        icon: const Icon(
                          Icons.wb_sunny,
                        ),
                        label: const Text(
                          "Set Morning Time",
                        ),
                      ),

                    if (parts[1] != "0")
                      ElevatedButton.icon(
                        onPressed: () =>
                            saveReminder(
                          medicineId:
                              medicineId,
                          medicineName:
                              medicineName,
                          slot:
                              "Afternoon",
                        ),
                        icon: const Icon(
                          Icons.sunny,
                        ),
                        label: const Text(
                          "Set Afternoon Time",
                        ),
                      ),

                    if (parts[2] != "0")
                      ElevatedButton.icon(
                        onPressed: () =>
                            saveReminder(
                          medicineId:
                              medicineId,
                          medicineName:
                              medicineName,
                          slot:
                              "Night",
                        ),
                        icon: const Icon(
                          Icons.nightlight,
                        ),
                        label: const Text(
                          "Set Night Time",
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

    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16),

      child: SizedBox(
        height: 55,

        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.home,
          ),

          label: const Text(
            "Finish Setup & Go Home",
          ),

          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const MainNavigationScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ),
    ),
  );
}
    }
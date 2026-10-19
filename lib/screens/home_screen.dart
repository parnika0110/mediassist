import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'doctor_list_screen.dart';
import 'doctor_screen.dart';
import 'my_medicines_screen.dart';
import 'prescription_screen.dart';
import 'reminder_screen.dart';
import 'symptom_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool loading = true;

  String userName = "";

  String nextMedicine = "No reminders";

  String nextTime = "";

  int reminderCount = 0;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    }

    if (hour < 17) {
      return "Good Afternoon";
    }

    if (hour < 21) {
      return "Good Evening";
    }

    return "Good Night";
  }

  Future<void> loadDashboard() async {

    try {

      final user = _auth.currentUser;

      if (user == null) return;

      //-----------------------------------------
      // USER NAME
      //-----------------------------------------

      final userDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

if (data != null) {
  userName =
      "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".trim();

  if (userName.isEmpty) {
    userName = "User";
  }
}      }

//-----------------------------------------
// REMINDERS
//-----------------------------------------

final reminderSnapshot = await _firestore
    .collection("users")
    .doc(user.uid)
    .collection("reminders")
    .get();

final now = DateTime.now();

Map<String, dynamic>? nextReminder;
DateTime? nextReminderTime;

reminderCount = 0;

for (final doc in reminderSnapshot.docs) {
  final data = doc.data();

  final timeString = data["time"] ?? "";

  try {
    final parts = timeString.split(" ");
    final hm = parts[0].split(":");

    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);

    if (parts[1] == "PM" && hour != 12) {
      hour += 12;
    }

    if (parts[1] == "AM" && hour == 12) {
      hour = 0;
    }

    final reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Ignore reminders that have already passed
    if (reminderDateTime.isBefore(now)) {
      continue;
    }

    // Count only upcoming reminders
    reminderCount++;

    // Find the nearest upcoming reminder
    if (nextReminderTime == null ||
        reminderDateTime.isBefore(nextReminderTime)) {
      nextReminderTime = reminderDateTime;
      nextReminder = data;
    }
  } catch (_) {}
}

if (nextReminder != null) {
  nextMedicine = nextReminder["medicineName"];
  nextTime = "${nextReminder["slot"]} • ${nextReminder["time"]}";
} else {
  nextMedicine = "You're all caught up!";
  nextTime = "No reminders remaining today.";
}

    } catch (e) {

      debugPrint(e.toString());

    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF0A0F1E),

      appBar: AppBar(
        title: const Text(
          "MediAssist",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 12),

            Text(
              getGreeting(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 5),

            loading
    ? const SizedBox(
        height: 44,
      )
    : Text(
        "$userName 👋",
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

            const SizedBox(height: 10),

            const Text(
              "Ready to take care of your health today?",
              style: TextStyle(
                color: Color(0xFFB0B8C5),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(

                gradient: const LinearGradient(

                  colors: [

                    Color(0xFF3B82F6),

                    Color(0xFF06B6D4),

                  ],

                ),

                borderRadius:
                    BorderRadius.circular(22),

              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Row(

                    children: [

                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Health Overview",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 17,
                        ),
                      ),

                    ],

                  ),

                  const SizedBox(height: 18),

                  Text(

                    loading
                        ? "Loading..."
                        : reminderCount == 0
                            ? "You're all caught up!"
                            : nextMedicine,

                    style: const TextStyle(

                      color: Colors.white,

                      fontSize: 26,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 8),

                  Text(

                    loading
                        ? ""
                        : reminderCount == 0
                            ? "No medicines scheduled today."
                            : nextTime,

                    style: const TextStyle(

                      color: Colors.white70,

                      fontSize: 15,

                    ),

                  ),

                  const SizedBox(height: 18),

                  Container(

                    padding: const EdgeInsets.symmetric(

                      horizontal: 15,

                      vertical: 12,

                    ),

                    decoration: BoxDecoration(

                      color: Colors.white24,

                      borderRadius:
                          BorderRadius.circular(15),

                    ),

                    child: Row(

                      children: [

                        const Icon(

                          Icons.notifications_active,

                          color: Colors.white,

                        ),

                        const SizedBox(width: 12),

                        Expanded(

                          child: Text(

                            loading
                                ? "Loading..."
                                : reminderCount == 0
                                    ? "No reminders remaining today 🎉"
                                    : reminderCount == 1
    ? "1 reminder scheduled today"
    : "$reminderCount reminders scheduled today",

                            style: const TextStyle(

                              color: Colors.white,

                            ),

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 30),

            const Text(

              "Quick Access",

              style: TextStyle(

                color: Colors.white,

                fontWeight: FontWeight.bold,

                fontSize: 22,

              ),

            ),

            const SizedBox(height: 18),
                        GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1,
              children: [

                _dashboardCard(
                  context,
                  "Prescription\nAnalysis",
                  Icons.description,
                  Colors.blue,
                  const PrescriptionScreen(),
                ),

                _dashboardCard(
                  context,
                  "Medication\nReminder",
                  Icons.medication,
                  Colors.green,
                  const ReminderScreen(),
                ),

                _dashboardCard(
                  context,
                  "Symptom\nAnalysis",
                  Icons.health_and_safety,
                  Colors.orange,
                  const SymptomScreen(),
                ),

                _dashboardCard(
  context,
  "Doctor\nAppointment",
  Icons.local_hospital,
  Colors.red,
  DoctorListScreen(),
),

                _dashboardCard(
                  context,
                  "My\nMedicines",
                  Icons.medication_liquid,
                  Colors.purple,
                  const MyMedicinesScreen(),
                ),

              ],
            ),

            const SizedBox(height: 25),

          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      splashColor: Colors.white24,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => screen,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white24,
              child: Icon(
                icon,
                color: Colors.white,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
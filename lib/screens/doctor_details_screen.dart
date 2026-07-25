import 'package:flutter/material.dart';
import '../models/doctor.dart';
import 'book_appointment_screen.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Details"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 60, color: Colors.blue),
            ),

            const SizedBox(height: 20),

            Text(
              doctor.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              doctor.specialization,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.blue),
                title: const Text("Hospital"),
                subtitle: Text(doctor.hospital),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.work, color: Colors.orange),
                title: const Text("Experience"),
                subtitle: Text("${doctor.experience} Years"),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text("Rating"),
                subtitle: Text("${doctor.rating} / 5.0"),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.currency_rupee, color: Colors.green),
                title: const Text("Consultation Fee"),
                subtitle: Text("₹${doctor.consultationFee}"),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text(
                  "Book Appointment",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookAppointmentScreen(doctor: doctor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

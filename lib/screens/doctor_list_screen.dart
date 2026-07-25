import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../widgets/doctor_card.dart';
import 'doctor_details_screen.dart';
import 'appointment_history_screen.dart';

class DoctorListScreen extends StatelessWidget {
  DoctorListScreen({super.key});

  final List<Doctor> doctors = [
    Doctor(
      id: "1",
      name: "Dr. Priya Sharma",
      specialization: "Cardiologist",
      hospital: "Apollo Hospital",
      experience: 12,
      rating: 4.8,
      image: "",
      consultationFee: 700,
    ),
    Doctor(
      id: "2",
      name: "Dr. Rajesh Kumar",
      specialization: "Dermatologist",
      hospital: "Fortis Hospital",
      experience: 8,
      rating: 4.6,
      image: "",
      consultationFee: 500,
    ),
    Doctor(
      id: "3",
      name: "Dr. Meena Iyer",
      specialization: "Pediatrician",
      hospital: "Manipal Hospital",
      experience: 15,
      rating: 4.9,
      image: "",
      consultationFee: 600,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Appointment History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return DoctorCard(
            doctor: doctors[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DoctorDetailsScreen(doctor: doctors[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

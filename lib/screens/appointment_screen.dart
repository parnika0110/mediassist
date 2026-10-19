import 'package:flutter/material.dart';
import 'doctor_list_screen.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        centerTitle: true,
      ),
      body: DoctorListScreen(),
    );
  }
}
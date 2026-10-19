import 'package:flutter/material.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Appointment"),
      ),
      body: const Center(
        child: Text(
          "Doctor Appointment",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
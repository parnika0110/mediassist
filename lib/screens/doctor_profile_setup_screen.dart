import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';
import 'doctor_dashboard_screen.dart';

class DoctorProfileSetupScreen extends StatefulWidget {
  const DoctorProfileSetupScreen({super.key});

  @override
  State<DoctorProfileSetupScreen> createState() =>
      _DoctorProfileSetupScreenState();
}

class _DoctorProfileSetupScreenState
    extends State<DoctorProfileSetupScreen> {

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _experienceController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  final UserService _userService = UserService();

  bool loading = false;

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF06B6D4),
          width: 2,
        ),
      ),
    );
  }

  Future<void> saveDoctorProfile() async {
    try {
      setState(() {
        loading = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await _userService.saveDoctorProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        email: user.email ?? "",
        phone: _phoneController.text.trim(),
        specialization: _specializationController.text.trim(),
        hospital: _hospitalController.text.trim(),
        experience:
            int.tryParse(_experienceController.text.trim()) ?? 0,
        consultationFee:
            int.tryParse(_consultationFeeController.text.trim()) ?? 0,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DoctorDashboardScreen(),
        ),
        (route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: fieldDecoration(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text("Doctor Profile"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            field(_nameController, "Full Name"),

            field(_phoneController, "Phone Number",
                keyboard: TextInputType.phone),

            field(_specializationController, "Specialization"),

            field(_hospitalController, "Hospital"),

            field(_experienceController, "Experience (Years)",
                keyboard: TextInputType.number),

            field(_consultationFeeController,
                "Consultation Fee (₹)",
                keyboard: TextInputType.number),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading ? null : saveDoctorProfile,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Complete Registration"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
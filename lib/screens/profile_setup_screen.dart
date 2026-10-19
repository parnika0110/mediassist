import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';
import 'main_navigation_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends State<ProfileSetupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  final UserService _userService = UserService();

  String gender = "Male";
  bool loading = false;
InputDecoration fieldDecoration(
  String label,
) {
  return InputDecoration(
    labelText: label,

    labelStyle: const TextStyle(
      color: Colors.white70,
    ),

    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.white24,
      ),
      borderRadius: BorderRadius.circular(12),
    ),

    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color(0xFF06B6D4),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
  Future<void> saveProfile() async {
    try {
      setState(() {
        loading = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await _userService.saveUserProfile(
        uid: user.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: user.email ?? "",
        phone: _phoneController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        gender: gender,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const MainNavigationScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
  controller: _firstNameController,
  style: const TextStyle(
    color: Colors.white,
  ),
  decoration: fieldDecoration("First Name"),
),
            const SizedBox(height: 15),

           TextField(
  controller: _lastNameController,
  style: const TextStyle(
    color: Colors.white,
  ),
  decoration: fieldDecoration("Last Name"),
),

            const SizedBox(height: 15),
TextField(
  controller: _ageController,
  keyboardType: TextInputType.number,
  style: const TextStyle(
    color: Colors.white,
  ),
  decoration: fieldDecoration("Age"),
),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
  value: gender,

  dropdownColor: const Color(0xFF1E1E1E),

  style: const TextStyle(
    color: Colors.white,
  ),

  decoration: fieldDecoration("Gender"),

  items: const [
    DropdownMenuItem(
      value: "Male",
      child: Text(
        "Male",
        style: TextStyle(color: Colors.white),
      ),
    ),
    DropdownMenuItem(
      value: "Female",
      child: Text(
        "Female",
        style: TextStyle(color: Colors.white),
      ),
    ),
    DropdownMenuItem(
      value: "Other",
      child: Text(
        "Other",
        style: TextStyle(color: Colors.white),
      ),
    ),
  ],

  onChanged: (value) {
    setState(() {
      gender = value!;
    });
  },
),
            const SizedBox(height: 15),

            TextField(
  controller: _phoneController,
  keyboardType: TextInputType.phone,
  style: const TextStyle(
    color: Colors.white,
  ),
  decoration: fieldDecoration("Phone Number"),
),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading ? null : saveProfile,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Complete Setup",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

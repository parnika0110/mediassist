import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'doctor_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      final doc = await _firestore.collection("users").doc(uid).get();

      if (!doc.exists) {
        throw Exception("User data not found.");
      }

      final data = doc.data()!;
      final role = data["role"];

      if (!mounted) return;

      if (role == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DoctorListScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed";

      if (e.code == "invalid-credential") {
        message = "Invalid email or password";
      } else if (e.code == "user-not-found") {
        message = "User not found";
      } else if (e.code == "wrong-password") {
        message = "Incorrect password";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.local_hospital, size: 90, color: Colors.blue),

              const SizedBox(height: 30),

              buildField(
                controller: emailController,
                label: "Email",
                keyboard: TextInputType.emailAddress,
              ),

              buildField(
                controller: passwordController,
                label: "Password",
                obscure: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

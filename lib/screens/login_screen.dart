import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'main_navigation_screen.dart';
import 'doctor_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;

  Future<void> loginUser() async {
    try {
      setState(() {
        _loading = true;
      });

      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user == null) {
        throw Exception("Login Failed");
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User record not found.");
      }

      final data = userDoc.data()!;
      final actualRole = data["role"] ?? "patient";

      if (actualRole != widget.role) {
        await _authService.logout();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "This account is registered as $actualRole.",
            ),
          ),
        );

        return;
      }

      if (!mounted) return;

      if (widget.role == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DoctorDashboardScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDoctor = widget.role == "doctor";

    return Scaffold(
backgroundColor: AppColors.background,      
body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Container(
  height: 110,
  width: 110,
  decoration: BoxDecoration(
    color: (isDoctor
            ? AppColors.doctorGreen
            : AppColors.patientBlue)
        .withOpacity(0.15),
    borderRadius: BorderRadius.circular(28),
  ),
  child: Icon(
    isDoctor
        ? Icons.medical_services_rounded
        : Icons.local_hospital_rounded,
    size: 65,
    color: isDoctor
        ? AppColors.doctorGreen
        : AppColors.patientBlue,
  ),
),

              const SizedBox(height: 15),

              const Text(
  "Welcome Back",
  style: TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
              const SizedBox(height: 10),

              Text(
  isDoctor
      ? "Doctor Portal"
      : "Patient Portal",
  style: const TextStyle(
    fontSize: 18,
    color: AppColors.secondary,
  ),
),

              const SizedBox(height: 40),

              Container(
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white10,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  ),

  child: Padding(
    padding: const EdgeInsets.all(24),

    child: Column(
      children: [
                      TextField(
  controller: _emailController,

  style: const TextStyle(
    color: Colors.white,
    fontSize: 16,
  ),

  decoration: InputDecoration(
    labelText: "Email",
    labelStyle: const TextStyle(
      color: Colors.white70,
    ),

    filled: true,
    fillColor: const Color(0xFF20293A),

    prefixIcon: const Icon(Icons.email),
    prefixIconColor: Colors.white70,

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Colors.white12,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDoctor
            ? AppColors.doctorGreen
            : AppColors.patientBlue,
        width: 2,
      ),
    ),
  ),
),

                      const SizedBox(height: 20),

                      TextField(
  controller: _passwordController,
obscureText: true,

decoration: InputDecoration(
  labelText: "Password",

  labelStyle: const TextStyle(
    color: Colors.white70,
  ),

  filled: true,
  fillColor: const Color(0xFF20293A),

  prefixIcon: const Icon(Icons.lock_outline),
  prefixIconColor: Colors.white70,

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(
      color: Colors.white12,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
      color: isDoctor
          ? AppColors.doctorGreen
          : AppColors.patientBlue,
      width: 2,
    ),
  ),
),
),

                      const SizedBox(height: 25),

                      SizedBox(
  width: double.infinity,
  height: 58,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: isDoctor
          ? AppColors.doctorGreen
          : AppColors.patientBlue,

      foregroundColor: Colors.white,

      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    onPressed: _loading ? null : loginUser,

    child: _loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                isDoctor
                    ? Icons.medical_services
                    : Icons.login,
                size: 22,
              ),

              const SizedBox(width: 10),

              Text(
                isDoctor
                    ? "Login as Doctor"
                    : "Login as Patient",

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
  ),
),

                      const SizedBox(height: 15),

                      Column(
  children: [
    const Text(
      "Don't have an account?",
      style: TextStyle(fontSize: 16),
    ),
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterScreen(
              role: widget.role,
            ),
          ),
        );
      },
      child: Text(
        isDoctor
            ? "Register as Doctor"
            : "Register as Patient",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
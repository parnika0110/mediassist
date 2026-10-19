import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.patientBlue.withOpacity(.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.patientBlue.withOpacity(.35),
                  ),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.patientBlue,
                  size: 65,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "MediAssist",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "AI Powered Smart Healthcare",
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 55),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text(
                    "Continue as Patient",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.patientBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(
        role: "patient",
      ),
    ),
  );
},
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.medical_services),
                  label: const Text(
                    "Continue as Doctor",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.doctorGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(
        role: "doctor",
      ),
    ),
  );
},
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Profile not found"),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final role = data['role'] ?? 'patient';

          String avatar = data['avatar'] ?? "others";

          String avatarPath = avatar == "male"
              ? "assets/avatars/male.png"
              : avatar == "female"
                  ? "assets/avatars/female.png"
                  : "assets/avatars/others.png";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(avatarPath),
                ),

                const SizedBox(height: 20),

                Text(
                  role == "doctor"
                      ? (data['name'] ?? "")
                      : "${data['firstName'] ?? ""} ${data['lastName'] ?? ""}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(data['email'] ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(data['phone'] ?? ""),
                  ),
                ),

                if (role == "patient") ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.cake),
                      title: Text(
                        (data['age'] ?? "").toString(),
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(data['gender'] ?? ""),
                    ),
                  ),
                ] else ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(
                        data['specialization'] ?? "",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital),
                      title: Text(
                        data['hospital'] ?? "",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.work),
                      title: Text(
                        "${data['experience'] ?? 0} Years",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: Text(
                        "₹ ${data['consultationFee'] ?? 0}",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star),
                      title: Text(
                        "${data['rating'] ?? 0}",
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
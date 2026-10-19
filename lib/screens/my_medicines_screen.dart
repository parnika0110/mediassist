import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyMedicinesScreen extends StatelessWidget {
  const MyMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medicines"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('medicines')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No medicines added yet",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          final medicines =
              snapshot.data!.docs;

          return ListView.builder(
            itemCount: medicines.length,

            itemBuilder: (context, index) {

              final medicine =
                  medicines[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: const Icon(
                    Icons.medication,
                    color: Colors.blue,
                  ),

                  title: Text(
                    medicine['medicine'],
                  ),

                  subtitle: Text(
                    "${medicine['dosage']} | ${medicine['frequency']} | ${medicine['duration']}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
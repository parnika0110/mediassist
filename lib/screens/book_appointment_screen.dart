import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/firestore_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  String gender = "Male";

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                widget.doctor.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.doctor.specialization,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Patient Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter patient name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter age";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (value) {
                  setState(() {
                    gender = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Reason for Visit",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  selectedDate == null
                      ? "Select Appointment Date"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),
                trailing: ElevatedButton(
                  onPressed: pickDate,
                  child: const Text("Choose"),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  selectedTime == null
                      ? "Select Appointment Time"
                      : selectedTime!.format(context),
                ),
                trailing: ElevatedButton(
                  onPressed: pickTime,
                  child: const Text("Choose"),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select date and time"),
                        ),
                      );
                      return;
                    }

                    if (auth.currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please login first."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Appointment appointment = Appointment(
                      patientId: auth.currentUser!.uid,
                      patientName: nameController.text.trim(),
                      age: int.parse(ageController.text.trim()),
                      gender: gender,
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      reason: reasonController.text.trim(),
                      doctorId: widget.doctor.id,
                      doctorName: widget.doctor.name,
                      appointmentDate:
                          "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      appointmentTime: selectedTime!.format(context),
                      status: "Pending",
                      doctorRemarks: "",
                    );

                    try {
                      await firestoreService.bookAppointment(appointment);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Appointment request submitted.\nWaiting for doctor's approval.",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      if (!mounted) return;

                      String message = e.toString().replaceFirst(
                        "Exception: ",
                        "",
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Confirm Appointment",
                    style: TextStyle(fontSize: 18),
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

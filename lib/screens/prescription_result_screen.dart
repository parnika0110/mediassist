import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/medicine_service.dart';
import 'reminder_screen.dart';
class PrescriptionResultScreen extends StatefulWidget {
  const PrescriptionResultScreen({super.key});

  @override
  State<PrescriptionResultScreen> createState() =>
      _PrescriptionResultScreenState();
}

class _PrescriptionResultScreenState
    extends State<PrescriptionResultScreen> {
  final MedicineService _medicineService =
      MedicineService();

  final List<Map<String, TextEditingController>>
      medicines = [];

  @override
  void initState() {
    super.initState();
    addMedicine();
  }

  void addMedicine() {
  medicines.add({
    'medicine': TextEditingController(),

    'dosageValue': TextEditingController(),
    'dosageUnit': TextEditingController(
      text: 'mg',
    ),

    'morningFreq': TextEditingController(
      text: '0',
    ),
    'afternoonFreq': TextEditingController(
      text: '0',
    ),
    'nightFreq': TextEditingController(
      text: '0',
    ),

    'durationValue':
        TextEditingController(),

    'durationUnit': TextEditingController(
      text: 'Days',
    ),
  });

  setState(() {});
}

  void removeMedicine(int index) {
    if (medicines.length == 1) return;

    medicines[index]
        .forEach((key, controller) {
      controller.dispose();
    });

    medicines.removeAt(index);

    setState(() {});
  }

  Future<void> saveMedicines() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    for (var medicineData in medicines) {
      final medicine =
          medicineData['medicine']!
              .text
              .trim();

      final dosage =
    "${medicineData['dosageValue']!.text} "
    "${medicineData['dosageUnit']!.text}";

final frequency =
    "${medicineData['morningFreq']!.text}-"
    "${medicineData['afternoonFreq']!.text}-"
    "${medicineData['nightFreq']!.text}";

final duration =
    "${medicineData['durationValue']!.text} "
    "${medicineData['durationUnit']!.text}";

      if (medicine.isEmpty ||
          dosage.isEmpty ||
          frequency.isEmpty ||
          duration.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Please fill all fields",
            ),
          ),
        );
        return;
      }

      await _medicineService.saveMedicine(
        uid: user.uid,
        medicine: medicine,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
      );
    }

    if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
  const SnackBar(
    content: Text(
      "Medicines Saved Successfully",
    ),
  ),
);

await Future.delayed(
  const Duration(seconds: 1),
);

if (!mounted) return;

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const ReminderScreen(),
  ),
);
}

  Widget buildMedicineCard(
  int index,
  Map<String, TextEditingController>
      medicineData,
) {
  return Card(
    margin: const EdgeInsets.only(
      bottom: 20,
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [

          Row(
            children: [

              Text(
                "Medicine ${index + 1}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: () =>
                    removeMedicine(index),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          TextField(
            controller:
                medicineData['medicine'],
            decoration:
                const InputDecoration(
              labelText:
                  "Medicine Name",
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                flex: 2,
                child: TextField(
                  controller:
                      medicineData[
                          'dosageValue'],
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Dosage",
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                          isExpanded: true,
                  value: medicineData[
                          'dosageUnit']!
                      .text,

                  items: const [
                    DropdownMenuItem(
                        value: 'mg',
                        child: Text(
                            'mg')),
                    DropdownMenuItem(
                        value: 'g',
                        child: Text(
                            'g')),
                    DropdownMenuItem(
                        value: 'ml',
                        child: Text(
                            'ml')),
                    DropdownMenuItem(
                        value:
                            'tablet',
                        child: Text(
                            'tablet')),
                    DropdownMenuItem(
                        value:
                            'capsule',
                        child: Text(
                            'capsule')),
                  ],

                  onChanged: (value) {
                    medicineData[
                            'dosageUnit']!
                        .text = value!;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(isExpanded: true,
                  value: medicineData[
                          'morningFreq']!
                      .text,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Morning",
                  ),

                  items: ['0', '1', '2', '3']
                      .map(
                        (e) =>
                            DropdownMenuItem(
                          value: e,
                          child:
                              Text(e),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    medicineData[
                            'morningFreq']!
                        .text = value!;
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(isExpanded: true,
                  value: medicineData[
                          'afternoonFreq']!
                      .text,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Afternoon",
                  ),

                  items: ['0', '1', '2', '3']
                      .map(
                        (e) =>
                            DropdownMenuItem(
                          value: e,
                          child:
                              Text(e),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    medicineData[
                            'afternoonFreq']!
                        .text = value!;
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(isExpanded: true,
                  value: medicineData[
                          'nightFreq']!
                      .text,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Night",
                  ),

                  items: ['0', '1', '2', '3']
                      .map(
                        (e) =>
                            DropdownMenuItem(
                          value: e,
                          child:
                              Text(e),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    medicineData[
                            'nightFreq']!
                        .text = value!;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                flex: 2,
                child: TextField(
                  controller:
                      medicineData[
                          'durationValue'],
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Duration",
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(isExpanded: true,
                  value: medicineData[
                          'durationUnit']!
                      .text,

                  items: const [
                    DropdownMenuItem(
                        value: 'Days',
                        child: Text(
                            'Days')),
                    DropdownMenuItem(
                        value:
                            'Weeks',
                        child: Text(
                            'Weeks')),
                    DropdownMenuItem(
                        value:
                            'Months',
                        child: Text(
                            'Months')),
                  ],

                  onChanged: (value) {
                    medicineData[
                            'durationUnit']!
                        .text = value!;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Prescription Review",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Review Medicine Details",
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ...List.generate(
              medicines.length,
              (index) =>
                  buildMedicineCard(
                index,
                medicines[index],
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: addMedicine,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "Add Another Medicine",
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveMedicines,
                icon: const Icon(
                  Icons.save,
                ),
                label: const Text(
                  "Save All Medicines",
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
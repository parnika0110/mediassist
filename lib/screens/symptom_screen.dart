import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prediction_result_screen.dart';
import '../services/symptom_ai_service.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final TextEditingController _controller = TextEditingController();

  final SymptomAIService _ai = SymptomAIService();

  List<String> allSymptoms = [];
  List<String> filteredSymptoms = [];
  List<String> selectedSymptoms = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await _ai.initialize();

    final jsonString =
        await rootBundle.loadString("assets/data/symptoms.json");

    allSymptoms = List<String>.from(json.decode(jsonString));

    filteredSymptoms = List.from(allSymptoms);

    setState(() {
      loading = false;
    });
  }

  void searchSymptoms(String value) {
    setState(() {
      filteredSymptoms = allSymptoms
          .where((e) =>
              e.toLowerCase().contains(value.toLowerCase()) &&
              !selectedSymptoms.contains(e))
          .toList();
    });
  }

  void addSymptom(String symptom) {
    if (!selectedSymptoms.contains(symptom)) {
      setState(() {
        selectedSymptoms.add(symptom);
        _controller.clear();
        filteredSymptoms = List.from(allSymptoms);
      });
    }
  }

  void removeSymptom(String symptom) {
    setState(() {
      selectedSymptoms.remove(symptom);
    });
  }

  Future<void> analyze() async {
    if (selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one symptom."),
        ),
      );
      return;
    }

    final predictions =
        await _ai.predictDiseases(selectedSymptoms);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PredictionResultScreen(
          predictions: predictions,
    ),
  ),
);

    // Result screen comes next
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptom Analysis"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: searchSymptoms,
              decoration: InputDecoration(
                hintText: "Search symptoms...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (selectedSymptoms.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedSymptoms
                      .map(
                        (e) => Chip(
                          label: Text(e),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => removeSymptom(e),
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: filteredSymptoms.length,
                itemBuilder: (context, index) {
                  final symptom = filteredSymptoms[index];

                  return ListTile(
                    leading: const Icon(Icons.medical_information),
                    title: Text(symptom),
                    onTap: () => addSymptom(symptom),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: analyze,
                icon: const Icon(Icons.psychology),
                label: const Text(
                  "Analyze Symptoms",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
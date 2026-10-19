import 'package:flutter/material.dart';

import '../models/disease_prediction.dart';

class PredictionResultScreen extends StatelessWidget {
  final List<DiseasePrediction> predictions;

  const PredictionResultScreen({
    super.key,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    final best = predictions.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Result"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------
            // Best Prediction Card
            // ------------------------------

            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.medical_services,
                      size: 70,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Most Likely Disease",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      best.disease.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    LinearProgressIndicator(
                      value: best.confidence / 100,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${best.confidence.toStringAsFixed(2)} %",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            buildSection(
              "Description",
              [
                best.description,
              ],
            ),

            buildSection(
              "Recommended Diet",
              best.diet,
            ),

            buildSection(
              "Medications",
              best.medications,
            ),

            buildSection(
              "Precautions",
              best.precautions,
            ),

            buildSection(
              "Workout",
              best.workout,
            ),

            const SizedBox(height: 25),

            const Text(
              "Other Possible Diseases",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...predictions.skip(1).map(
              (prediction) => Card(
                child: ListTile(
                  leading: const Icon(Icons.health_and_safety),
                  title: Text(prediction.disease),
                  trailing: Text(
                    "${prediction.confidence.toStringAsFixed(2)}%",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
  color: const Color.fromARGB(255, 227, 24, 10),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: const BorderSide(
      color: Colors.orange,
      width: 1,
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "This AI prediction is intended for informational purposes only.\n"
            "It is not a substitute for professional medical advice. "
            "If symptoms are severe or persistent, seek immediate medical attention.",
            style: const TextStyle(
              color: Color.fromARGB(221, 255, 255, 255),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  ),
),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildSection(
    String title,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(),

              ...items.map(
                (e) => Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
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
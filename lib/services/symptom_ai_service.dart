import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/disease_prediction.dart';

class SymptomAIService {
  static final SymptomAIService _instance = SymptomAIService._internal();

  factory SymptomAIService() => _instance;

  SymptomAIService._internal();

  Interpreter? _interpreter;

  List<String> _symptoms = [];
  List<String> _labels = [];

  Map<String, dynamic> _diseaseInfo = {};

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Load TFLite model
    _interpreter = await Interpreter.fromAsset(
      'assets/models/model.tflite',
    );

    // Load symptoms
    final symptomJson = await rootBundle.loadString(
      'assets/data/symptoms.json',
    );

    _symptoms = List<String>.from(
      jsonDecode(symptomJson),
    );

    // Load labels
    final labelJson = await rootBundle.loadString(
      'assets/data/labels.json',
    );

    _labels = List<String>.from(
      jsonDecode(labelJson),
    );

    // Load disease information
    final diseaseJson = await rootBundle.loadString(
      'assets/data/disease_info.json',
    );

    _diseaseInfo =
        jsonDecode(diseaseJson) as Map<String, dynamic>;

    _initialized = true;
  }

  bool get isInitialized => _initialized;

  List<String> get symptoms => _symptoms;
    List<double> _createInputVector(
      List<String> selectedSymptoms) {

    final vector =
        List<double>.filled(_symptoms.length, 0);

    for (final symptom in selectedSymptoms) {
      final index = _symptoms.indexWhere(
        (e) =>
            e.toLowerCase().trim() ==
            symptom.toLowerCase().trim(),
      );

      if (index != -1) {
        vector[index] = 1;
      }
    }

    return vector;
  }
    Future<List<DiseasePrediction>> predictDiseases(
      List<String> selectedSymptoms) async {
    if (!_initialized) {
      throw Exception(
          "SymptomAIService is not initialized.");
    }

    final inputVector =
        _createInputVector(selectedSymptoms);

    final input = [
      Float32List.fromList(inputVector)
    ];

    final output = [
      List<double>.filled(_labels.length, 0)
    ];

    _interpreter!.run(input, output);

    final probabilities = output.first;

    final indexed = List.generate(
      probabilities.length,
      (i) => MapEntry(i, probabilities[i]),
    );

    indexed.sort(
      (a, b) => b.value.compareTo(a.value),
    );

    final top3 = indexed.take(3).toList();

    List<DiseasePrediction> predictions = [];

    for (final item in top3) {
      final disease =
          _labels[item.key].toLowerCase().trim();

      final info =
          _diseaseInfo[disease] ??
              <String, dynamic>{};

      predictions.add(
        DiseasePrediction(
          disease: disease,

          confidence:
              item.value * 100,

          description:
              info["description"] ?? "",

          diet:
              List<String>.from(
                  info["diet"] ?? []),

          medications:
              List<String>.from(
                  info["medications"] ?? []),

          precautions:
              List<String>.from(
                  info["precautions"] ?? []),

          workout:
              List<String>.from(
                  info["workout"] ?? []),
        ),
      );
    }

    return predictions;
  }
    void dispose() {
    _interpreter?.close();
  }
}
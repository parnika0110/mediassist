class DiseasePrediction {
  final String disease;
  final double confidence;
  final String description;
  final List<String> diet;
  final List<String> medications;
  final List<String> precautions;
  final List<String> workout;

  DiseasePrediction({
    required this.disease,
    required this.confidence,
    required this.description,
    required this.diet,
    required this.medications,
    required this.precautions,
    required this.workout,
  });
}
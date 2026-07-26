class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final int experience;
  final double rating;
  final String image;
  final int consultationFee;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.experience,
    required this.rating,
    required this.image,
    required this.consultationFee,
  });

  factory Doctor.fromMap(Map<String, dynamic> map, String id) {
    return Doctor(
      id: id,
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      hospital: map['hospital'] ?? '',
      experience: map['experience'] ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
      consultationFee: map['consultationFee'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'hospital': hospital,
      'experience': experience,
      'rating': rating,
      'image': image,
      'consultationFee': consultationFee,
    };
  }
}

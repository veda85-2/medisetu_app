class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int experience;
  final int consultationFee;
  final String gender;
  final String availability;
  final String? phone;

  final String qualification;
  final String availableDays;
  final String availableFrom;
  final String availableTo;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.consultationFee,
    required this.gender,
    required this.availability,
    this.phone,
    required this.qualification,
    required this.availableDays,
    required this.availableFrom,
    required this.availableTo,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    final firstName = user['first_name']?.toString() ?? '';
    final lastName = user['last_name']?.toString() ?? '';

    final fullName =
        '$firstName $lastName'.trim();

    final rawFee =
        json['consultation_fee'] ?? 0;

    final rawExperience =
        json['experience'] ?? 0;

    return Doctor(
      id: (json['id'] ?? '').toString(),

      name: fullName.isNotEmpty
          ? fullName
          : 'Doctor',

      specialty:
          (json['specialization'] ??
                  'General Physician')
              .toString(),

      // Backend currently doesn't provide image
      imageUrl:
          (json['profile_image'] ?? '')
              .toString(),

      // Backend currently doesn't provide these
      rating:
          double.tryParse(
                (json['rating'] ?? 0).toString(),
              ) ??
              0,

      reviewCount:
          int.tryParse(
                (json['review_count'] ?? 0)
                    .toString(),
              ) ??
              0,

      experience:
          int.tryParse(
                rawExperience.toString(),
              ) ??
              0,

      consultationFee:
          double.tryParse(
                rawFee.toString(),
              )?.round() ??
              0,

      gender:
          (json['gender'] ?? 'Any')
              .toString(),

      availability:
          (json['available_days'] ??
                  'Any')
              .toString(),

      phone:
          json['phone']?.toString(),

      qualification:
          (json['qualification'] ?? '')
              .toString(),

      availableDays:
          (json['available_days'] ?? '')
              .toString(),

      availableFrom:
          (json['available_from'] ?? '')
              .toString(),

      availableTo:
          (json['available_to'] ?? '')
              .toString(),
    );
  }
}
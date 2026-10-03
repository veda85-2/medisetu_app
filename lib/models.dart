class UserProfile {
  final String name;
  final String greeting;

  UserProfile({
    required this.name,
    required this.greeting,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      greeting: json['greeting'] ?? 'Good Morning',
    );
  }
}

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String time;
  final String avatarUrl;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.time,
    required this.avatarUrl,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      time: json['time'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}

class SpecialistCategory {
  final String title;
  final String subtitle;
  final String icon;

  SpecialistCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  factory SpecialistCategory.fromJson(Map<String, dynamic> json) {
    return SpecialistCategory(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class DashboardData {
  final UserProfile user;
  final Appointment? upcomingAppointment;
  final List<SpecialistCategory> recommendedSpecialists;

  DashboardData({
    required this.user,
    this.upcomingAppointment,
    required this.recommendedSpecialists,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: UserProfile.fromJson(json['user']),
      upcomingAppointment: json['upcomingAppointment'] != null
          ? Appointment.fromJson(json['upcomingAppointment'])
          : null,
      recommendedSpecialists:
          (json['recommendedSpecialists'] as List)
              .map((e) => SpecialistCategory.fromJson(e))
              .toList(),
    );
  }
}

//doctors model

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
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'])
        : <String, dynamic>{};

    final firstName = user['first_name']?.toString() ?? '';
    final lastName = user['last_name']?.toString() ?? '';

    final fullName = '$firstName $lastName'.trim();

    final rawFee = json['consultation_fee'];
    final rawExperience = json['experience'];

    return Doctor(
      id: (json['id'] ?? '').toString(),

      name: fullName.isNotEmpty
          ? fullName
          : 'Doctor',

      specialty:
          (json['specialization'] ?? 'General Physician')
              .toString(),

      imageUrl:
          (json['profile_image'] ?? '').toString(),

      rating:
          double.tryParse(
                (json['rating'] ?? 0).toString(),
              ) ??
              0.0,

      reviewCount:
          int.tryParse(
                (json['review_count'] ?? 0).toString(),
              ) ??
              0,

      experience:
          int.tryParse(
                rawExperience?.toString() ?? '0',
              ) ??
              0,

      consultationFee:
          double.tryParse(
                rawFee?.toString() ?? '0',
              )?.round() ??
              0,

      gender:
          (json['gender'] ?? 'Any').toString(),

      availability:
          (json['available_days'] ?? 'Any').toString(),

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

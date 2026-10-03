# medisetu

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# MediSetu 🏥

MediSetu is a modern healthcare management mobile application built with **Flutter** and **Dart**.

The application provides a simple platform for patients and doctors to manage healthcare-related activities such as doctor discovery, appointments, medical records, prescriptions, and more.

---

## 📱 Features

### 👤 Patient Features

- Patient Registration & Login
- Find Doctors
- Search Doctors
- View Doctor Profiles
- Book Appointments
- Appointment Confirmation
- Medical Records
- Prescription History
- Prescription Details
- Profile Management

### 👨‍⚕️ Doctor Features

- Doctor Registration & Login
- Doctor Dashboard
- View Appointments
- View Patients
- Manage Prescriptions
- Doctor Profile

### 🔐 Authentication

- Login
- Registration
- Password visibility toggle
- Email validation
- Password validation
- Role-based navigation
- Remember login session

---

## 🛠️ Technologies Used

- **Flutter**
- **Dart**
- **Material Design**
- **HTTP**
- **Shared Preferences**
- **Image Picker**
- **URL Launcher**

---

## 📂 Project Structure

```text
lib/
│
├── main.dart
│
├── pages/
│   ├── login.dart
│   ├── signup.dart
│   ├── home.dart
│   ├── doctor_find.dart
│   ├── doctor_profile.dart
│   ├── book_appointment.dart
│   ├── appointment_confirmed.dart
│   ├── medical_records.dart
│   ├── prescriptions.dart
│   └── prescription_detail.dart
│
├── doctor/
│   └── doctor_dashboard.dart
│
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── onboarding_service.dart
│
├── models/
│   └── models.dart
│
└── assets/
    └── images/
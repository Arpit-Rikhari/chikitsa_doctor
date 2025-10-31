import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String phone;
  final String gender;
  final String mainComplaint;
  final String symptomDuration;
  final String notes;
  final Timestamp createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.gender,
    required this.mainComplaint,
    required this.symptomDuration,
    required this.notes,
    required this.createdAt,
  });

  factory Patient.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null for ID: ${doc.id}");
    }

    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      age: (data['age'] ?? 0) is int
          ? data['age']
          : int.tryParse('${data['age']}') ?? 0,
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      mainComplaint: data['mainComplaint'] ?? '',
      symptomDuration: data['symptomDuration'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'phone': phone,
      'gender': gender,
      'mainComplaint': mainComplaint,
      'symptomDuration': symptomDuration,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management/models/patient.dart';

class PatientViewModel extends ChangeNotifier {
  final CollectionReference patientsCol =
      FirebaseFirestore.instance.collection('patients');

  /// Stream all patients (ordered by created date)
  Stream<List<Patient>> watchPatients() {
    return patientsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Patient.fromDoc(d)).toList());
  }
  
//24 hrs patients stream
Stream<List<Patient>> watchRecentPatients() {
  final twentyFourHoursAgo = Timestamp.fromDate(
    DateTime.now().subtract(const Duration(hours: 24)),
  );

  return patientsCol
      .where('createdAt', isGreaterThanOrEqualTo: twentyFourHoursAgo)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Patient.fromDoc(d)).toList());
}
  /// Add a new patient record
  Future<void> addPatient({
    required String name,
    required int age,
    required String phone,
    required String gender,
    required String mainComplaint,
    required String symptomDuration,
    required String notes,
  }) async {
    final data = {
      'name': name,
      'age': age,
      'phone': phone,
      'gender': gender,
      'mainComplaint': mainComplaint,
      'symptomDuration': symptomDuration,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await patientsCol.add(data);
  }

  /// Update an existing patient record
  Future<void> updatePatient({
    required String id,
    required String name,
    required int age,
    required String phone,
    required String gender,
    required String mainComplaint,
    required String symptomDuration,
    required String notes,
  }) async {
    final data = {
      'name': name,
      'age': age,
      'phone': phone,
      'gender': gender,
      'mainComplaint': mainComplaint,
      'symptomDuration': symptomDuration,
      'notes': notes,
    };

    await patientsCol.doc(id).update(data);
  }

  /// Delete a patient record
  Future<void> deletePatient(String id) async {
    await patientsCol.doc(id).delete();
  }
}


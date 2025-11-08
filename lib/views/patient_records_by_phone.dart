import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:hospital_management/models/patient.dart';
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';
import 'package:intl/intl.dart';

class PatientRecordsByPhonePage extends StatefulWidget {
  final String phone;
  final String name;

  const PatientRecordsByPhonePage({
    super.key,
    required this.phone,
    required this.name,
  });

  @override
  State<PatientRecordsByPhonePage> createState() =>
      _PatientRecordsByPhonePageState();
}

class _PatientRecordsByPhonePageState extends State<PatientRecordsByPhonePage> {
  String searchQuery = '';

 @override
Widget build(BuildContext context) {
  final patientVm = context.read<PatientViewModel>();

  if (widget.phone.isEmpty) {
    return const Scaffold(
      body: Center(
        child: Text(
          '❌ No phone number provided in the URL',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
  
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          '📞 ${widget.phone} Records',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔍 Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 10),

            // 🩺 Patient records list
            Expanded(
              child: StreamBuilder<List<Patient>>(
                stream: patientVm.watchPatientsByPhone(widget.phone),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final patients = snapshot.data ?? [];
                  final filtered = patients
                      .where((p) => p.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'image/empty-list.svg',
                            height: 200,
                            semanticsLabel: 'no data',
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No records found 🩹',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal.shade100,
                            child: Text(
                              p.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              '🧍‍♂️ Age: ${p.age}\n💬 Problem: ${p.mainComplaint}\n📞 Phone: ${p.phone}\n📝 Note: ${p.notes}\n🗓️ Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(p.createdAt.toDate())}',
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_management/models/patient.dart';
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';

class AddEditPatientPage extends StatefulWidget {
  final Patient? patient;

  const AddEditPatientPage({
    super.key,
    this.patient,
    required PatientViewModel vm,
  });

  @override
  State<AddEditPatientPage> createState() => _AddEditPatientPageState();
}

class _AddEditPatientPageState extends State<AddEditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  String? _selectedComplaint;
  String? _selectedDuration;
  String? _customComplaint;
  String? _customDuration;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _baseComplaints = [
    'Fever',
    'Cold',
    'Headache',
    'Cough',
    'Body Pain',
  ];
  final List<String> _baseDurations = [
    '1 Day',
    '2 Days',
    '1 Week',
    '2 Weeks',
    '1 Month',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      _ageController.text = widget.patient!.age.toString();
      _phoneController.text = widget.patient!.phone;
      _notesController.text = widget.patient!.notes;
      _selectedGender = widget.patient!.gender;
      _selectedComplaint = widget.patient!.mainComplaint;
      _selectedDuration = widget.patient!.symptomDuration;

      if (!_baseComplaints.contains(_selectedComplaint)) {
        _customComplaint = _selectedComplaint;
        _selectedComplaint = 'Other';
      }
      if (!_baseDurations.contains(_selectedDuration)) {
        _customDuration = _selectedDuration;
        _selectedDuration = 'Other';
      }
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < _steps().length - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _savePatient();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePatient() async {
    final vm = Provider.of<PatientViewModel>(context, listen: false);
    final navigator = Navigator.of(context);

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final phone = _phoneController.text.trim();
    final gender = _selectedGender ?? '';
    final complaint = _selectedComplaint == 'Other'
        ? (_customComplaint?.trim() ?? '')
        : (_selectedComplaint ?? '');
    final duration = _selectedDuration == 'Other'
        ? (_customDuration?.trim() ?? '')
        : (_selectedDuration ?? '');
    final notes = _notesController.text.trim().isEmpty
        ? 'No notes'
        : _notesController.text.trim();

    if (widget.patient == null) {
      await vm.addPatient(
        name: name,
        age: age,
        phone: phone,
        gender: gender,
        mainComplaint: complaint,
        symptomDuration: duration,
        notes: notes,
      );
    } else {
      await vm.updatePatient(
        id: widget.patient!.id,
        name: name,
        age: age,
        phone: phone,
        gender: gender,
        mainComplaint: complaint,
        symptomDuration: duration,
        notes: notes,
      );
    }

    navigator.pop();
  }

  Widget _buildQuestion(String question, IconData icon, Widget field) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(icon, size: 50, color: Colors.teal.shade600),
              const SizedBox(height: 15),
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),
              field,
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _steps() {
    return [
      _buildQuestion(
        "What is the patient's full name?",
        Icons.person_outline,
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration('Full Name', Icons.badge_outlined),
          validator: (v) =>
              v == null || v.isEmpty ? 'Please enter the name' : null,
        ),
      ),
      _buildQuestion(
        'How old is the patient?',
        Icons.cake_outlined,
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Age', Icons.celebration_rounded),
          validator: (v) {
            final val = int.tryParse(v ?? '');
            if (val == null || val <= 0) return 'Enter valid age';
            return null;
          },
        ),
      ),
      _buildQuestion(
        "What is the patient's phone number?",
        Icons.phone,
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration('Phone Number', Icons.phone_android),
          validator: (v) =>
              v == null || v.length < 10 ? 'Enter valid phone number' : null,
        ),
      ),
      _buildQuestion(
        "Select the patient's gender",
        Icons.transgender,
        DropdownButtonFormField<String>(
          decoration: _inputDecoration('Gender', Icons.person),
          initialValue: _selectedGender,
          items: _genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (val) => setState(() => _selectedGender = val),
          validator: (v) => v == null || v.isEmpty ? 'Select gender' : null,
        ),
      ),
      _buildQuestion(
        'What is the main complaint?',
        Icons.medical_information_outlined,
        Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Complaint', Icons.local_hospital),
              initialValue: _selectedComplaint,
              items: [
                ..._baseComplaints,
                'Other',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() {
                _selectedComplaint = val;
                if (val != 'Other') _customComplaint = null;
              }),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Select complaint' : null,
            ),
            if (_selectedComplaint == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  initialValue:
                      _customComplaint, // ✅ show saved custom complaint
                  decoration: _inputDecoration('Enter complaint', Icons.edit),
                  onChanged: (val) => _customComplaint = val,
                  validator: (v) {
                    if (_selectedComplaint == 'Other' &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Please enter the complaint';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
      _buildQuestion(
        'How long has the patient had these symptoms?',
        Icons.timelapse,
        Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Duration', Icons.access_time),
              initialValue: _selectedDuration,
              items: [
                ..._baseDurations,
                'Other',
              ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() {
                _selectedDuration = val;
                if (val != 'Other') _customDuration = null;
              }),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Select duration' : null,
            ),
            if (_selectedDuration == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  initialValue: _customDuration, // ✅ show saved custom duration
                  decoration: _inputDecoration('Enter duration', Icons.edit),
                  onChanged: (val) => _customDuration = val,
                  validator: (v) {
                    if (_selectedDuration == 'Other' &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Please enter the duration';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
      _buildQuestion(
        'Any additional notes about the patient?',
        Icons.note_alt_outlined,
        TextFormField(
          controller: _notesController,
          maxLines: 5,
          decoration: _inputDecoration('Notes (Optional)', Icons.sticky_note_2),
        ),
      ),
    ];
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.patient == null ? 'Add Patient' : 'Edit Patient',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🧭 Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / steps.length,
                      color: Colors.teal,
                      backgroundColor: Colors.teal.shade100,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Step ${_currentStep + 1} of ${steps.length}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // 📋 Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: steps,
                ),
              ),

              // 🧭 Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      ElevatedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 100),
                    ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(
                        _currentStep == steps.length - 1
                            ? Icons.check_circle
                            : Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: Text(
                        _currentStep == steps.length - 1 ? 'Finish' : 'Next',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

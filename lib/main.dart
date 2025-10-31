import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
// Import the new files
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';
import 'package:hospital_management/viewmodels/auth_viewmodel.dart';
import 'package:hospital_management/views/home_page.dart';
import 'package:hospital_management/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBQ0tePUcw1g_KqqG74ppUgDOX5R5BjfXs',
      appId: '1:1042051267417:web:c2db807a845a6869ab6a48',
      messagingSenderId: '1042051267417',
      projectId: 'hospital-management-ad0ea',
      authDomain: 'hospital-management-ad0ea.firebaseapp.com',
      storageBucket: 'hospital-management-ad0ea.firebasestorage.app',
      measurementId: 'G-H2QXJBXT80',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup MultiProvider for both Patient and Auth ViewModels
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Reception - Hospital Management',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthWrapper(), // Use a wrapper to handle login/home state
      ),
    );
  }
}

// Widget to handle the authentication state and show the correct page
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    if (authVm.isAuthenticated) {
      // User is logged in, show the main application page
      return const HomePage();
    } else {
      // User is logged out, show the login page
      return const LoginPage();
    }
    
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ViewModels
import 'package:hospital_management/viewmodels/patient_viewmodel.dart';
import 'package:hospital_management/viewmodels/auth_viewmodel.dart';

// Views
import 'package:hospital_management/views/home_page.dart';
import 'package:hospital_management/views/login_page.dart';
import 'package:hospital_management/views/patient_records_by_phone.dart';

// ✅ Firebase auto-config
import 'firebase_options.dart';

// ✅ Conditional import for web-only URL handling
import 'helpers/url_helper_stub.dart'
    if (dart.library.js_interop) 'helpers/url_helper_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hospital Management',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
        ),

        // ✅ Use onGenerateInitialRoutes for web URL parsing
        onGenerateInitialRoutes: (String initialRoute) {
          // Get the actual URL (works on web and mobile)
          final uri = getCurrentUri();
          
          // Handle /patientHistory route
          if (uri.path.endsWith('/patientHistory')) {
            final phone = uri.queryParameters['patient'] ?? '';

            return [
              MaterialPageRoute(
                builder: (_) => AuthGuard(
                  child: PatientRecordsByPhonePage(
                    name: '', // Name not needed in URL anymore
                    phone: phone,
                  ),
                ),
              ),
            ];
          }

          // Default route
          return [
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          ];
        },

        // ✅ Keep onGenerateRoute for in-app navigation
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '');

          // Handle /patientHistory?patient=7007224036
          if (uri.path == '/patientHistory') {
            final phone = uri.queryParameters['patient'] ?? '';

            return MaterialPageRoute(
              builder: (_) => AuthGuard(
                child: PatientRecordsByPhonePage(
                  name: '', // Name not needed
                  phone: phone,
                ),
              ),
            );
          }

          // Default routes
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const AuthGuard(child: HomePage()),
              );
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            default:
              return MaterialPageRoute(builder: (_) => const AuthWrapper());
          }
        },

        initialRoute: '/',
      ),
    );
  }
}

// ✅ Handles whether to show login or home
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData || authVm.isAuthenticated) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

// ✅ Authentication Guard - Protects routes from unauthorized access
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ If user is authenticated, show the protected page
        if (snapshot.hasData || authVm.isAuthenticated) {
          return child;
        }

        // ❌ If not authenticated, show login page in place
        // This preserves the URL so user stays on the same route after login
        return const LoginPage();
      },
    );
  }
}
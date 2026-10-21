import 'package:atox_mobile_app/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'ads/ad_route_observer.dart';
import 'ads/ad_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'utils/constants.dart';

final AdRouteObserver adRouteObserver = AdRouteObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ads must never block or crash app startup.
  try {
    await Get.putAsync(() => AdService().init());
  } catch (e, st) {
    debugPrint('[main] AdService init skipped: $e\n$st');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'ATox Earning',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [adRouteObserver],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _loadedUid;

  void _syncUser(String? uid) {
    if (uid == null) {
      // Logged out — clear cached data and cancel the stream.
      if (_loadedUid != null) {
        _loadedUid = null;
        Provider.of<UserProvider>(context, listen: false).clear();
      }
      return;
    }
    if (_loadedUid == uid) return;
    _loadedUid = uid;
    // Load once per authenticated user (guarded inside the provider).
    Provider.of<UserProvider>(context, listen: false).loadUserData(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.user == null) {
          return const OnboardingScreen();
        }

        // Schedule the load after this build frame (never call notifyListeners
        // synchronously during build).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncUser(authProvider.user?.uid);
        });

        return const DashboardScreen();
      },
    );
  }
}

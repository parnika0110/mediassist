import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constants/theme.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init();

  runApp(const MediAssistApp());
  
}

class MediAssistApp extends StatelessWidget {
  const MediAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediAssist',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

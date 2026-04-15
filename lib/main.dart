import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/diet_profile.dart';
import 'screens/chat_screen.dart';
import 'screens/diet_profile_screen.dart';
import 'services/profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final profile = await ProfileService().loadProfile();
  runApp(HealthChatbotApp(initialProfile: profile));
}

class HealthChatbotApp extends StatelessWidget {
  final DietProfile? initialProfile;

  const HealthChatbotApp({super.key, this.initialProfile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: initialProfile == null
          ? const DietProfileScreen(isFirstSetup: true)
          : ChatScreen(initialProfile: initialProfile),
    );
  }
}

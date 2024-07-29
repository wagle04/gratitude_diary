import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';
import 'package:gratitude_diary/firebase_options.dart';
import 'package:gratitude_diary/services/get_it/get_it_locator.dart';
import 'package:gratitude_diary/services/page_router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupGetItLocator();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gratitude Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
      builder: BotToastInit(),
    );
  }
}

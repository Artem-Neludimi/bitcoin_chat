import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/currency_provider.dart';
import 'services/api/firebase_options.dart';
import 'services/get_it.dart';
import 'ui/main_widgets/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Bitcoin Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xfff0b90a),
          ),
        ),
        home: const Home(),
      ),
    );
  }
}

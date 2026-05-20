import 'package:flutter/material.dart';
import 'package:live_loc/live_location.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'checklist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isFinished = false;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home:ElectronicsChecklistPage()
    );
  }
}
import 'package:fish_track/firebase_options.dart';
import 'package:fish_track/sign_in_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Assurez-vous que les liaisons Flutter sont initialisées
  await initializeFirebase(); // Appel de la fonction d'initialisation de Firebase
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignInPage(title: 'Home Page'),
      //home: const BottomNavigationBarExampleApp(userId: "blJtn5Bchsash4FRl5jj7B4mwHg2"),
    );
  }
}


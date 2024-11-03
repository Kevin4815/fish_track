import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_track/navigationbar.dart';
import 'package:fish_track/sign_in_page.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return BottomNavigationBarExampleApp(userId: snapshot.data!.uid);
        } else {
          return SignInPage(title: "Connexion");
        }
      },
    );
  }
}
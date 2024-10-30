import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_track/navigationbar.dart';
import 'package:fish_track/sign_in_page.dart';
import 'package:fish_track/toast.dart';
import 'package:flutter/material.dart';

class FirebaseManager {


    static Future<void> firebaseLogin(login, password, context) async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: login.text,
          password: password.text
        );

        User? user = userCredential.user;
        var uid = user?.uid ?? ''; 
        
        Navigator.push(    
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationBarExampleApp(userId : uid)),
        );

      } on FirebaseAuthException catch (e) {
        print(e.code);
        if (e.code == 'invalid-credential') {
          print("Erreur d'email ou de mot de passe");
          MessageToast.displayToast("Erreur d'email ou de mot de passe");
        } else if (e.code == 'channel-error') {
          print('Problème avec le mot de passe');
          MessageToast.displayToast("Email et mot de passe obligatoire");
        } else if (e.code == 'invalid-email') {
          MessageToast.displayToast("Adresse email invalide");
          print('Adresse email invalide');
          
        }
      }
    }

    static Future<void> firebaseRegister(name, login, password, confirmPassword, context) async {
      if(name != "" && login != "" && password != "" && confirmPassword != ""){
        try {
          if (password == confirmPassword) {
            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: login,
              password: password,
            );

            String userId = userCredential.user!.uid;

            CollectionReference users = FirebaseFirestore.instance.collection('Users');

            await users.doc(userId).set({
            'name': name,
            });
            print("User name Added");
            Navigator.push(    
              context,
              MaterialPageRoute(builder: (context) => const SignInPage(title: "Connexion")),
            );

          }
          else{
            MessageToast.displayToast("Les mot de passe ne correspondent pas");
          }
        } on FirebaseAuthException catch (e) {
          print(e.code);
          if (e.code == 'invalid-email') {
            print("L'adresse email n'est pas valide.");
            MessageToast.displayToast("L'adresse email n'est pas valide.");
          } else if(e.code == 'email-already-in-use') {
            print("Ce compte existe déjà");
            MessageToast.displayToast("Ce compte existe déjà");
          } else if (e.code == 'weak-password') {
            print('Mot de passe trop court');
            MessageToast.displayToast("Mot de passe trop court");
          }
        } 
      }
      else{
        MessageToast.displayToast("Tout les champs sont obligatoire");
      }
    }

    static Future<void> signOut(context) async {
      try {
        await FirebaseAuth.instance.signOut();

        if (FirebaseAuth.instance.currentUser == null) {
          print('Utilisateur déconnecté avec succès.');

          Navigator.push(    
          context,
          MaterialPageRoute(builder: (context) => const SignInPage(title: "Connexion")),
        );
          
        } else {
          print('Erreur : l\'utilisateur n\'a pas été déconnecté.');
        }
      } catch (e) {
        print('Erreur lors de la déconnexion : $e');
      }
    }
}

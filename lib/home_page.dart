import 'package:fish_track/main_app_page.dart';
import 'package:fish_track/navigationbar.dart';
import 'package:fish_track/sign_up_page.dart';
import 'package:fish_track/toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _login = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/peche_home2.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.0, 0.4), // Ajuster la valeur verticale pour déplacer le formulaire vers le bas
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _login,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Espacement entre les champs
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Mot de passe',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Espacement entre les champs et le bouton
                    ElevatedButton(
                      onPressed: () {
                        firebaseLogin(_login, _password, context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        backgroundColor: const Color.fromARGB(211, 37, 115, 160),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16), // Espacement entre le bouton de connexion et le texte d'inscription
                    RichText(
                      text: TextSpan(
                        text: "Pas encore de compte ? ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "S'inscrire",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Action pour rediriger vers la page d'inscription
                                Navigator.push(    
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUp(title: "S'inscrire")),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> firebaseLogin(login, password, context) async {
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

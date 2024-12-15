import 'package:fish_track/firebase.dart';
import 'package:fish_track/pages/sign_in_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.title});

  final String title;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController _name = TextEditingController();
  final TextEditingController _login = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool isPasswordShort = false;

  @override
  void dispose() {
    _name.dispose();
    _login.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
                      controller: _name,
                      decoration: InputDecoration(
                        hintText: "Nom d'utilisateur",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Espacement entre les champs
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
                      obscureText: true,
                      controller: _password,
                      decoration: InputDecoration(
                        hintText: 'Mot de passe',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      onChanged: (password) {
                        int passwordLength = password.length;
                        setState(() {
                          // Mettre à jour l'état de la longueur du mot de passe
                          isPasswordShort = passwordLength < 6 && passwordLength != 0;
                        });
                      },
                    ),
                    // Afficher le texte d'erreur en fonction de la condition
                    isPasswordShort
                        ? const Text(
                            "6 caractères minimum",
                            style: TextStyle(color: Colors.red),
                          )
                        : const SizedBox(height: 16,), // Utilisation de SizedBox pour occuper l'espace même lorsque le texte d'erreur n'est pas affiché
                    //const SizedBox(height: 16), // Espacement entre les champs  
                    TextField(
                      obscureText: true,
                      controller: _confirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirmez le mot de passe',
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
                        FirebaseManager.firebaseRegister(_name.text, _login.text, _password.text, _confirmPassword.text, context);
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
                        "S'inscrire",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16), // Espacement entre le bouton de connexion et le texte d'inscription
                    RichText(
                      text: TextSpan(
                        text: "Déjà un compte ? ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Se connecter",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Action pour rediriger vers la page d'inscription
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignInPage(title: "Connexion")),
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


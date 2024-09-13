import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_track/home_page.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onLogoutPressed;

  const CustomAppBar({
    required this.title,
    required this.onLogoutPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () async {
            await _signOut(context);
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

Future<void> _signOut(context) async {
  try {
    await FirebaseAuth.instance.signOut();

    if (FirebaseAuth.instance.currentUser == null) {
      print('Utilisateur déconnecté avec succès.');

      Navigator.push(    
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: "Connexion")),
    );
      
    } else {
      print('Erreur : l\'utilisateur n\'a pas été déconnecté.');
    }
  } catch (e) {
    print('Erreur lors de la déconnexion : $e');
  }
}


  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

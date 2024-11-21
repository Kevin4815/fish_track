import 'package:fish_track/firebase.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white, // Ajustez la couleur de texte
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF28A2C8), // Ajustez la couleur et transparence de l'AppBar
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white), // Ajustez l'icône et sa couleur
          onPressed: () => FirebaseManager.signOut(context),  // Passez la méthode signOut correctement
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

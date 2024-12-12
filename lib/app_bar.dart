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
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2, 2))
          ],
        ),
      ),
      backgroundColor: const Color(0xFF2C3A41), // Ajustez la couleur et transparence de l'AppBar
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

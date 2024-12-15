import 'package:flutter/material.dart';
import 'package:fish_track/firebase.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.onToggleDarkMode, // Paramètre pour le gestionnaire de mode sombre/clair
    required this.isDarkMode, // Paramètre pour savoir si c'est en mode sombre
  });

  final String title;
  final Color backgroundColor;
  final VoidCallback onToggleDarkMode; // Fonction à appeler lors du changement de mode
  final bool isDarkMode; // Indicateur de mode sombre

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white :  const Color(0xFF424242),
          shadows: const [
            Shadow(blurRadius: 4, color: Colors.black),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      actions: [
        // Bouton pour se déconnecter
        IconButton(
           icon: Icon(
            Icons.logout,  // Lune ou Soleil selon l'état du mode
            color: isDarkMode ? Colors.white : const Color(0xFF424242), // Blanc en mode sombre, gris foncé en mode clair
          ),
          onPressed: () => FirebaseManager.signOut(context),
        ),
        // Bouton pour changer le mode sombre/clair
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.nights_stay : Icons.wb_sunny,  // Lune ou Soleil selon l'état du mode
            color: isDarkMode ? Colors.white : const Color(0xFF424242), // Blanc en mode sombre, gris foncé en mode clair
          ),
          onPressed: onToggleDarkMode, // Appelle la fonction pour changer le mode
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

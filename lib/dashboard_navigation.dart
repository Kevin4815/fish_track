import 'package:flutter/material.dart';
import 'package:fish_track/custom_app_bar.dart';
import 'package:fish_track/pages/add_fishing_page.dart';
import 'package:fish_track/pages/fish_list_page.dart';
import 'package:fish_track/pages/map_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardNavigation extends StatefulWidget {
  final String userId;

  const DashboardNavigation({Key? key, required this.userId}) : super(key: key);

  @override
  _DashboardNavigationState createState() => _DashboardNavigationState();
}

class _DashboardNavigationState extends State<DashboardNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  late List<String> _pageTitles;
  bool _isDarkMode = false;  // Variable pour gérer l'état du mode sombre
  Color _appBarColor = Colors.white; // Couleur par défaut de l'AppBar
  Color _backgroundColor = const Color(0xFFF5F5F5); // Couleur de fond par défaut
  Color _fontColor = Colors.black; // Couleur des icônes et textes par défaut
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference(); // Charger la préférence du mode sombre
    _pageController = PageController(initialPage: _selectedIndex);

    // Initialisez vos pages ici pour qu'elles soient créées lors du premier chargement
    _initializePages();
  }

  // Fonction pour charger la préférence du mode sombre
  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false; // Charger la valeur enregistrée (false par défaut)
      _updateColors(); // Mettre à jour les couleurs en fonction du mode choisi
      _initializePages(); // Recréer les pages après le chargement des préférences
    });
  }

  // Fonction pour initialiser les pages avec la bonne valeur de isDarkMode
  void _initializePages() {
    _widgetOptions = <Widget>[
      MainAppPage(title: "Mes captures", userId: widget.userId, isDarkMode: _isDarkMode),
      AddFishingPage(title: "Fishing", userId: widget.userId, isDarkMode: _isDarkMode),
      MyMapPage(title: "Map", isDarkMode: _isDarkMode),
    ];
    _pageTitles = [
      "Mes captures", 
      "Ajouter une pêche", 
      "Carte",
    ];
  }

  // Fonction pour enregistrer la préférence du mode sombre
  Future<void> _saveDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode); // Sauvegarder l'état du mode sombre
  }

  // Fonction pour mettre à jour les couleurs en fonction du mode sombre
  void _updateColors() {
    if (_isDarkMode) {
      _appBarColor = const Color(0xFF2C3A41);
      _backgroundColor = Colors.black87;
      _fontColor = Colors.white;
    } else {
      _appBarColor = Colors.white;
      _backgroundColor = const Color(0xFFF5F5F5);
      _fontColor = Colors.black;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  // Fonction pour basculer entre mode sombre et clair
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _updateColors(); // Mettre à jour les couleurs lorsque le mode change
      _saveDarkModePreference(); // Sauvegarder la préférence du mode sombre
      _initializePages(); // Recréer les pages avec la nouvelle valeur de isDarkMode
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _pageTitles[_selectedIndex],
        backgroundColor: _appBarColor,
        onToggleDarkMode: _toggleDarkMode,
        isDarkMode: _isDarkMode,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Désactiver le swipe
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _fontColor),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: _fontColor),
            label: 'Ajouter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: _fontColor),
            label: 'Carte',
          ),
        ],
        backgroundColor: _appBarColor,
        currentIndex: _selectedIndex,
        selectedItemColor: _fontColor,
        unselectedItemColor: _fontColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'dart:io';
import 'package:fish_track/app_bar.dart';
import 'package:fish_track/fish.dart';
import 'package:fish_track/location_service.dart';
import 'package:fish_track/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

const List<String> fishList = <String>['Black-bass', 'Chevesne', 'Brochet', 'Carpe', 'Silure'];
const List<String> fishingRodType = <String>['Ultra-light', 'Light', 'Medium-light', 'Medium', 'Medium-heavy', 'Heavy'];

class AddFishingPage extends StatefulWidget {
  const AddFishingPage({super.key, required this.title, required this.userId});

  final String title;
  final String userId;

  @override
  State<AddFishingPage> createState() => _MyAddFishingPageState();
}

class _MyAddFishingPageState extends State<AddFishingPage> {
  String? dropdownFishValue; // Définir sur null pour afficher "Sélectionnez une option"
  String? dropdownRodValue; // Définir sur null pour afficher "Sélectionnez une option"
  File? _imgFile;
  final TextEditingController _inputSizeValueController = TextEditingController();
  final LocationService _locationService = LocationService();
  LocationData? _position;

  @override
  void initState() {
    super.initState();
    currentPosition();
  }

  @override
  void dispose() {
    _inputSizeValueController.dispose();
    super.dispose();
  }

  Future<void> currentPosition() async {
    LocationData? position = await _locationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _position = position;
      });
    }
  }

  Future<String> getCityName(double latitude, double longitude) async {
    // Effectue une géocodification inversée
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

    // Récupère le nom de la ville
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      return placemark.locality ?? 'Ville non trouvée';
    } else {
      return 'Ville non trouvée';
    }
  }

  void takeSnapshot() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 400,
    );
    if (img == null) return;
    setState(() {
      _imgFile = File(img.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes pêches',
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/river.jpg"), // Image de fond
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Main UI
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header title
                    const Text(
                      "Ajoute ton poisson !",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2, 2))
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Fish Type Dropdown
                    _buildLabel("Type de poisson"),
                    _buildDropdownField(
                      dropdownValue: dropdownFishValue,
                      items: fishList,
                      onChanged: (value) => setState(() => dropdownFishValue = value),
                    ),
                    const SizedBox(height: 15),
                    // Size Input
                    _buildLabel("Taille (cm)"),
                    _buildTextField(
                      controller: _inputSizeValueController,
                      hintText: 'Entrez la taille en cm',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    // Rod Type Dropdown
                    _buildLabel("Type de canne"),
                    _buildDropdownField(
                      dropdownValue: dropdownRodValue,
                      items: fishingRodType,
                      onChanged: (value) => setState(() => dropdownRodValue = value),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 180,
                        height: 180,
                        color: Colors.white.withOpacity(0.3),
                        child: _imgFile == null
                            ? Image.asset('images/no_photo.jpg', fit: BoxFit.cover)
                            : Image.file(_imgFile!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildButton(
                      text: "Ajouter une photo",
                      onPressed: takeSnapshot,
                    ),
                    const SizedBox(height: 20),
                    // Save button
                    _buildButton(
                      text: "Sauvegarder",
                      onPressed: () {
                        saveFish(widget.userId);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(blurRadius: 3, color: Colors.black, offset: Offset(0, 1))],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? dropdownValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    List<String> dropdownItems = ["Sélectionnez une option", ...items];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: InputBorder.none),
        value: dropdownValue,
        items: dropdownItems.map((String value) {
          return DropdownMenuItem<String>(
            value: value == "Sélectionnez une option" ? null : value,
            child: Text(
              value,
              style: TextStyle(color: value == "Sélectionnez une option" ? Colors.grey : Colors.black),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF28A2C8),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

Future<void> saveFish(String userId) async {
  CollectionReference fishes = FirebaseFirestore.instance.collection('Fish');

  // Assurez-vous que les valeurs par défaut sont définies pour éviter les erreurs
  String fishType = dropdownFishValue ?? "Non spécifié";
  String fishSize = _inputSizeValueController.text.isNotEmpty ? _inputSizeValueController.text : "Non spécifié";
  String rodType = dropdownRodValue ?? "Non spécifié";
  String picturePath = _imgFile?.path ?? "";

  Fish fish = Fish(fishType, fishSize, rodType, picturePath);

  try {
    if (_position == null) {
      print("Position is null");
      return;
    }

    String cityName = '';
    try {
      cityName = await getCityName(_position!.latitude!, _position!.longitude!);
      print("City name: $cityName");
    } catch (error) {
      print("Error in getCityName: $error");
      cityName = 'Non renseigné';
    }

    // Créer une Map pour la position
    Map<String, dynamic>? positionMap;
    if (_position != null) {
      positionMap = {
        'city' : cityName,
        'latitude': _position!.latitude!,
        'longitude': _position!.longitude!,
      };
    }

    // Ajout dans Firestore
    await fishes.doc(userId).collection('user_fish').add({
      'type': fish.type,
      'size': fish.size,
      'rod_type': fish.rodType,
      'picture': fish.picture,
      'timestamp': Timestamp.now(),
      'position': positionMap, // Utiliser le Map pour la position
    });

    homeRedirection(context, userId);
  } catch (error) {
    print("Failed to add fish: $error");
  }
}


  void homeRedirection(BuildContext context, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavigationBarExampleApp(userId: id),
      ),
    );
  }
}

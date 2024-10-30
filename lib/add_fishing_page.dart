import 'dart:io';
import 'package:fish_track/app_bar.dart';
import 'package:fish_track/fish.dart';
import 'package:fish_track/main_app_page.dart';
import 'package:fish_track/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> fish_list = <String>['Black-bass', 'Chevesne', 'Brochet', 'Carpe', 'Silure'];
const List<String> fishing_rod_type = <String>['Ultra-light', 'Light', 'Medium-light', 'Medium', 'Medium-heavy', 'Heavy'];

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

  @override
  void dispose() {
    _inputSizeValueController.dispose();
    super.dispose();
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
      appBar: CustomAppBar(
        title: 'Ajouter une pêche',
        onLogoutPressed: () {
          // Action de déconnexion ici
        },
      ),
      body: Stack(
        children: [
          // Fond d'image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/river.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Voile noir
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Contenu principal
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Type de poisson",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      dropdownValue: dropdownFishValue,
                      items: fish_list,
                      onChanged: (value) => setState(() => dropdownFishValue = value),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Taille (cm)",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _inputSizeValueController,
                      hintText: 'Entrez la taille en cm',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Type de canne",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      dropdownValue: dropdownRodValue,
                      items: fishing_rod_type,
                      onChanged: (value) => setState(() => dropdownRodValue = value),
                    ),
                    const SizedBox(height: 25),
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 180,
                            height: 180,
                            color: Colors.white.withOpacity(0.1),
                            child: _imgFile == null
                                ? Image.asset('images/empty_image.jpg', fit: BoxFit.cover)
                                : Image.file(_imgFile!, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: takeSnapshot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(211, 37, 115, 160),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Ajouter une photo",
                            style: TextStyle(color: Color.fromARGB(221, 255, 255, 255), fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () => saveFish(widget.userId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(211, 37, 115, 160),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Sauvegarder",
                        style: TextStyle(color: Color.fromARGB(221, 255, 255, 255), fontSize: 18),
                      ),
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

  Widget _buildDropdownField({
    required String? dropdownValue, // Changement pour String? (nullable)
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Ajout d'une valeur par défaut au début de la liste d'options
    List<String> dropdownItems = ["Sélectionnez une option", ...items];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: InputBorder.none),
        // Pas de valeur initiale pour afficher "Sélectionnez une option"
        value: dropdownValue,
        items: dropdownItems.map((String value) {
          return DropdownMenuItem<String>(
            value: value == "Sélectionnez une option" ? null : value, // "Sélectionnez une option" pointe vers null
            child: Text(
              value,
              style: TextStyle(color: value == "Sélectionnez une option" ? Colors.grey : Colors.black),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          // Ignorer l'option par défaut
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        // Validation pour forcer la sélection d'une option
        validator: (value) => value == null ? 'Veuillez choisir une option valide' : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Future<void> saveFish(String userId) async {
    CollectionReference fishes = FirebaseFirestore.instance.collection('Fish');
    Fish fish = Fish(dropdownFishValue ?? "Non spécifié", _inputSizeValueController.text, dropdownRodValue ?? "Non spécifié", _imgFile?.path ?? "");
    try {
      await fishes.doc(userId).collection('user_fish').add({
        'type': fish.type,
        'size': fish.size,
        'rod_type': fish.rodType,
        'picture': fish.picture,
        'timestamp': Timestamp.now(),
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

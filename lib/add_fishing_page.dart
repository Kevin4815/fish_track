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
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  String? dropdownFishValue;
  String? dropdownRodValue;
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
    print(position);
    if (mounted) {
      setState(() {
        _position = position;
      });
    }
  }

  Future<String> getCityName(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      return placemark.locality ?? 'Ville non trouvée';
    } else {
      return 'Ville non trouvée';
    }
  }

  void takeSnapshot(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Affiche un dialogue avec deux options : appareil photo ou galerie
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Choisissez une option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choisir dans la galerie'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    // Si l'utilisateur annule la boîte de dialogue
    if (source == null) return;

    // Récupère l'image depuis la source sélectionnée
    final XFile? img = await picker.pickImage(
      source: source,
      maxWidth: 400,
    );
    if (img == null) return;

    // Enregistrez l'image dans un répertoire persistant
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String fileName = img.name;
    final File newImage = File('$appDocPath/$fileName');
    await img.saveTo(newImage.path);

    // Mettez à jour l'état avec l'image sélectionnée
    setState(() {
      _imgFile = newImage;
    });
  }


  Future<String> uploadImageToFirebase(File image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erreur lors du téléchargement de l'image : $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Ajout de pêches',
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/peche-background-sun.jpg"),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildLabel("Type de poisson"),
                    _buildDropdownField(
                      dropdownValue: dropdownFishValue,
                      items: fishList,
                      onChanged: (value) => setState(() => dropdownFishValue = value),
                    ),
                    const SizedBox(height: 15),
                    _buildLabel("Taille (cm)"),
                    _buildTextField(
                      controller: _inputSizeValueController,
                      hintText: 'Entrez la taille en cm',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    _buildLabel("Type de canne"),
                    _buildDropdownField(
                      dropdownValue: dropdownRodValue,
                      items: fishingRodType,
                      onChanged: (value) => setState(() => dropdownRodValue = value),
                    ),
                    const SizedBox(height: 50),
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
                    const SizedBox(height: 25),
                    _buildButton(
                      text: "Ajouter une photo",
                      onPressed: () {
                         takeSnapshot(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      text: "Sauvegarder",
                      onPressed: () async {
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
        backgroundColor: const Color.fromARGB(255, 69, 177, 173),
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

    String fishType = dropdownFishValue ?? "Non spécifié";
    String fishSize = _inputSizeValueController.text.isNotEmpty ? _inputSizeValueController.text : "Non spécifié";
    String rodType = dropdownRodValue ?? "Non spécifié";
    String picturePath = _imgFile?.path ?? "";

    Fish fish = Fish(fishType, fishSize, rodType, picturePath);

    try {
      String cityName = '';
      try {
        cityName = await getCityName(_position!.latitude!, _position!.longitude!);
        print("City name: $cityName");
      } catch (error) {
        print("Error in getCityName: $error");
        cityName = 'Non renseigné';
      }

      Map<String, dynamic>? positionMap;
      if (_position != null) {
        positionMap = {
          'city': cityName,
          'latitude': _position!.latitude!,
          'longitude': _position!.longitude!,
        };
      }

      DocumentReference userDoc = fishes.doc(userId);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'userId': userId,
          'createdAt': Timestamp.now(),
        });
        print("Document utilisateur créé");
      }

      // Upload image to Firebase Storage and get the URL
      String imageUrl = '';
      if (_imgFile != null) {
        imageUrl = await uploadImageToFirebase(_imgFile!);
      }

      await userDoc.collection('user_fish').add({
        'type': fish.type,
        'size': fish.size,
        'rod_type': fish.rodType,
        'picture': imageUrl.isNotEmpty ? imageUrl : fish.picture,
        // PATH PHOTO VIDE POUR EVITER LES ERREURS DE RÉCUPÉRATION (PHOTO DISPARAIT DU STOCKAGE IPHONE)
        //'picture': "",
        'timestamp': Timestamp.now(),
        'position': positionMap,
      });

      print("Poisson ajouté avec succès");
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

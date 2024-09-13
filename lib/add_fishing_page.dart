import 'dart:ffi';
import 'dart:io';

import 'package:fish_track/app_bar.dart';
import 'package:fish_track/fish.dart';
import 'package:fish_track/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> fish_list = <String>['Black-bass', 'Chevesne', 'Brochet', 'Carpe', 'Silure'];
const List<String> fishing_rod_type = <String>['Ultra-light', 'Light', 'Medium-ight', 'Medium', 'Medium-heavy', 'Heavy'];

class AddFishingPage extends StatefulWidget {
  const AddFishingPage({super.key, required this.title, required this.userId});

  final String title;
  final String userId;

  @override
  State<AddFishingPage> createState() => _MyAddFishingPageState();
}

class _MyAddFishingPageState extends State<AddFishingPage> {

  String dropdownFishValue = fish_list.first;
  String dropdownRodValue = fishing_rod_type.first;
  File? _imgFile;

  final TextEditingController _inputSizeValueController = TextEditingController();

  @override
  void dispose() {
    // Don't forget to dispose the controller when it's no longer needed to avoid memory leaks
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
    resizeToAvoidBottomInset: false,
    appBar: CustomAppBar(
      title: 'Ajouter un poisson',
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
          color: Colors.black.withOpacity(0.5), // Couleur noire avec une opacité de 0.5
        ),
        // Contenu scrollable
        SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0), // Ajustement de la marge supérieure
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Type de poisson :", style: TextStyle(color: Colors.white)),
                  Container(
                     padding: const EdgeInsets.only(
                        left: 100.0, // Padding gauche
                        top: 10.0, // Padding haut
                        right: 100.0, // Padding droit (différent de gauche)
                        bottom: 10.0, // Padding bas
                      ),
                    child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      fillColor: Colors.white, // Définir la couleur de fond blanc
                      filled: true, // Rendre le champ opaque
                      border: OutlineInputBorder(borderSide: BorderSide.none), // Supprimer la bordure
                    ),
                    items: fish_list.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) => value == null || value.isEmpty ? 'Sélectionnez un type' : null,
                    onChanged: (String? value) => setState(() => dropdownFishValue = value!),
                    )
                  ),
                const SizedBox(height: 10.0),
                const Text("Taille (cm) :", style: TextStyle(color: Colors.white)),
                Container(
                  padding: const EdgeInsets.only(
                    left: 100.0, // Padding gauche
                    top: 10.0, // Padding haut
                    right: 100.0, // Padding droit (différent de gauche)
                    bottom: 10.0, // Padding bas
                  ),
                  child: TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    fillColor: Colors.white, // Définir la couleur de fond blanc
                    filled: true, // Rendre le champ opaque
                    border: OutlineInputBorder(borderSide: BorderSide.none), // Supprimer la bordure
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  controller: _inputSizeValueController,
                  validator: (value) => value == null || value.isEmpty ? 'Entrez une taille' : null,
                ),
                ),
                
                const SizedBox(height: 10.0),
                const Text("Type de canne :", style: TextStyle(color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 100.0, // Padding gauche
                      top: 10.0, // Padding haut
                      right: 100.0, // Padding droit (différent de gauche)
                      bottom: 10.0, // Padding bas
                    ),
                    child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      fillColor: Colors.white, // Définir la couleur de fond blanc
                      filled: true, // Rendre le champ opaque
                      border: OutlineInputBorder(borderSide: BorderSide.none), // Supprimer la bordure
                    ),
                    items: fishing_rod_type.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) => value == null || value.isEmpty ? 'Sélectionnez un type' : null,
                    onChanged: (String? value) => setState(() => dropdownRodValue = value!),
                    )
                  ),
                  const SizedBox(height: 20.0),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0), // Définir le rayon de bordure
                              child: SizedBox(
                                width: 150, // Définissez la largeur de l'image pour qu'elle soit carrée
                                height: 150, // Définissez la hauteur de l'image pour qu'elle soit carrée
                                child: Image(
                                  image: (_imgFile == null)
                                    ? const AssetImage('images/empty_image.jpg')
                                    : FileImage(_imgFile!) as ImageProvider,
                                  fit: BoxFit.cover, // Ajustez le mode d'ajustement de l'image
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  takeSnapshot();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor: const Color.fromARGB(211, 37, 115, 160),
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  textStyle: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Text(
                                  "Ajouter une photo",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          saveFish(widget.userId);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: const Color.fromARGB(211, 37, 115, 160),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          "Sauvegarder",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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



 Future<void> saveFish(String userId) async {
    CollectionReference fishes = FirebaseFirestore.instance.collection('Fish');

    Fish fish;

    if (_imgFile != null) {
      fish = Fish(dropdownFishValue, _inputSizeValueController.text, dropdownRodValue, _imgFile!.path);
    } else {
      fish = Fish(dropdownFishValue, _inputSizeValueController.text, dropdownRodValue, "");
    }

    try {
      await fishes.doc(userId).collection('user_fish').add({
        'type': fish.type,
        'size': fish.size,
        'rod_type': fish.rodType,
        'picture': fish.picture,
        'timestamp': Timestamp.now(),
      });
      print("Fish Added");
      //homeRedirection();

    } catch (error) {
      print("Failed to add fish: $error");
    }
  }

  void homeRedirection(){
    Navigator.push(    
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: "Connexion")),
      );
  }
}



//  Column(
//                     children: [
//                       const Text("Type de canne :", style: TextStyle(color: Colors.white)),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10.0),
//                         child: Container(
//                           color: Colors.white, // Fond blanc pour le dropdown
//                           child: DropdownMenu<String>(
//                             initialSelection: "",
//                             onSelected: (String? value) {
//                               setState(() {
//                                 dropdownRodValue = value!;
//                               });
//                             },
//                             dropdownMenuEntries: fishing_rod_type.map<DropdownMenuEntry<String>>((String value) {
//                               return DropdownMenuEntry<String>(value: value, label: value);
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),






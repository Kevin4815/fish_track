import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_track/gps.dart';
import 'package:fish_track/location_service.dart';
import 'package:fish_track/map_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

class FishInformations extends StatefulWidget {
  const FishInformations({
    super.key,
    required this.userId,
    required this.docId,
    required this.title,
    required this.city,
    required this.picture,
    required this.size,
    required this.type,
    required this.rod,
    required this.date,
    required this.fishPosition,
  });

  final String userId;
  final String docId;
  final String title;
  final String city;
  final String picture;
  final String size;
  final String type;
  final String rod;
  final Timestamp date;
  final Map<String, dynamic> fishPosition;

  @override
  State<FishInformations> createState() => _MyFishInformationsState();
}

class _MyFishInformationsState extends State<FishInformations> {
  late String formattedDate;
  late String editableType;
  late String editableSize;
  late String editableRod;

  Map<String, dynamic>? _fishPosition;
  final LocationService _locationService = LocationService();
  final GPS _gps = GPS();

  bool isModified = false;
  Map<String, bool> activeFields = {
    'Type': false,
    'Taille': false,
    'Canne': false,
    'Lieu': false,
    'Image': false, // Ajout d'un champ pour l'image
  };

  final TextEditingController _updateData = TextEditingController();
  late MapLocation mapLocation;
  LocationData? _position;

  bool showEditButton = false;
  late String currentImagePath;

  @override
  void initState() {
    super.initState();
    formattedDate = timeStampToDateFormat(widget.date);
    editableType = widget.type;
    editableSize = widget.size;
    editableRod = widget.rod;
    mapLocation = MapLocation();
    currentImagePath = widget.picture;

    fetchFishDetails();

    mapLocation.currentPosition((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _updateData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3A41),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3A41),
        title: const Text('Informations', style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2, 2))
          ],
        ),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, isModified ? true : false);
          },
        ),
      ),
      body: Stack(
        children: [
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
            color: Colors.black.withOpacity(0.6),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Lorsque l'image est tapée, active le bouton d'édition et désactive les autres boutons
                          activeFields.forEach((key, value) {
                            activeFields[key] = false;
                          });
                          activeFields['Image'] = true; // Active l'édition pour l'image
                        });

                        // Cache le bouton d'édition après 3 secondes
                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            activeFields['Image'] = false; // Masque le bouton d'édition après le délai
                          });
                        });
                      },
                      child: Stack(
                        children: [
                          // Le container ici permet d'ajouter un rayon autour de l'image
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20), // Rayon arrondi
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20), // Appliquer le rayon d'arrondi sur l'image
                              child: currentImagePath.startsWith('/')
                                  ? Image.file(
                                      File(currentImagePath),
                                      width: double.infinity,
                                      height: 250,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      currentImagePath,
                                      width: double.infinity,
                                      height: 250,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          if (activeFields['Image'] == true) // Condition pour afficher le bouton d'édition
                            Positioned(
                              top: 10,
                              right: 10,
                              child: ElevatedButton(
                                onPressed: () => updateImage(),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                  backgroundColor: const Color.fromARGB(189, 37, 37, 37),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Icon(Icons.edit, size: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        buildInfoRow("Type", editableType),
                        const SizedBox(height: 10),
                        buildInfoRow("Taille", editableSize),
                        const SizedBox(height: 10),
                        buildInfoRow("Canne", editableRod),
                        const SizedBox(height: 10),
                        buildInfoRow("Lieu", widget.city),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      SizedBox(
                    height: 300,
                    child: _position == null
                        ? Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          )
                        : FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                _position!.latitude!,
                                _position!.longitude!,
                              ),
                              initialZoom: 9.2,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: mapLocation.buildMarkerForFish(widget.fishPosition),
                              ),
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C3A41),
                        ),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(8),
                              child: Image.asset('images/waze.png'),
                            ),
                            onPressed: () {
                              _gps.launchWaze(widget.fishPosition['latitude'], widget.fishPosition['longitude']);
                            },
                          ),
                          IconButton(
                            icon: Container(
                              width: 55,
                              height: 55,
                              padding: const EdgeInsets.all(8),
                              child: Image.asset('images/google_maps.png'),
                            ),
                            onPressed: () {
                              _gps.launchGoogleMaps(widget.fishPosition['latitude'], widget.fishPosition['longitude']);
                            },
                          ),
                          const SizedBox(height: 50),
                        ],
                      )
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: GestureDetector(
        onTap: () {
          // Vérifier si l'élément n'est pas "Lieu", sinon ne pas activer le champ
          if (label != 'Lieu') {
            setState(() {
              activeFields.forEach((key, value) {
                activeFields[key] = false;
              });
              activeFields[label] = true;
            });

            // Désactiver après 3 secondes
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                activeFields[label] = false;
              });
            });
          }
        },
        child: Card(
          color: const Color.fromARGB(255, 65, 83, 93),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Affiche le label (type, taille canne, etc.)
                Text(
                  '$label :',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    // Affiche le bouton d'édition uniquement si l'élément n'est pas "Lieu"
                    AnimatedOpacity(
                      opacity: activeFields[label]! ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: activeFields[label] == true
                            ? () {
                                showCustomAlertDialog(context, _updateData, label, value);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(30, 30), // Réduit la taille du bouton
                          backgroundColor: const Color.fromARGB(160, 0, 0, 0),
                          foregroundColor: Colors.white,
                        ),
                        child: const Icon(Icons.edit, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Affiche la valeur dans un conteneur avec padding uniforme
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Padding uniforme pour tous les éléments
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 69, 177, 173),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value.isEmpty ? "Inconnu" : value, // Vérifie si la valeur est null ou vide
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



void showCustomAlertDialog(BuildContext context, TextEditingController controller, String label, String value) {
  TextEditingController dynamicController = TextEditingController(text: value);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2C3A41),
        title: Text(
          label, 
          style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: dynamicController,
          style: const TextStyle(color: Colors.white), // Change la couleur du texte tapé
          decoration: InputDecoration(
            filled: true, // Active le fond rempli
            fillColor: const Color.fromARGB(255, 91, 91, 91), // Change la couleur de fond de l'input
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder( // Contour lorsque le champ n'est pas cliqué
              borderSide: const BorderSide(color: Colors.grey, width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder( // Contour lorsque le champ est cliqué
              borderSide: const BorderSide(color: Color.fromARGB(255, 69, 177, 173), width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fermer', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              String inputValue = dynamicController.text;
              // Appel à la fonction de mise à jour dynamique
              await updateFish(label, inputValue);

              setState(() {
                // Mise à jour dynamique de l'état en fonction du champ modifié
                if ((label == "Type" && editableType != inputValue) || 
                    (label == "Taille" && editableSize != inputValue) || 
                    (label == "Canne" && editableRod != inputValue)) {
                  isModified = true;
                }

                if (label == "Type") {
                  editableType = inputValue;
                } else if (label == "Taille") {
                  editableSize = inputValue;
                } else if (label == "Canne") {
                  editableRod = inputValue;
                }
              });

              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:const Color.fromARGB(255, 69, 177, 173),
            ),
            child: const Text('Modifier', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}



  // Mise à jour dynamique du champ dans la base de données
  Future<void> updateFish(String label, String updatedValue) async {
    try {
      // Mise à jour dynamique en fonction du label
      Map<String, String> fieldToUpdate = {
        "Type": 'type',
        "Taille": 'size',
        "Canne": 'rod',
      };

      // On vérifie si le label correspond à un champ connu
      if (fieldToUpdate.containsKey(label)) {
        await FirebaseFirestore.instance
            .collection('Fish')
            .doc(widget.userId)
            .collection('user_fish')
            .doc(widget.docId)
            .update({fieldToUpdate[label]!: updatedValue});
      }
    } catch (e) {
      print("Erreur de mise à jour du poisson : $e");
    }
  }


  Future<void> updateImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Récupérer le répertoire de stockage local
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = pickedFile.name; // Nom du fichier sélectionné
        final String localPath = '${directory.path}/$fileName';

        // Copier l'image sélectionnée dans le répertoire local
        final File imageFile = File(pickedFile.path);
        final File savedImage = await imageFile.copy(localPath);

        setState(() {
          currentImagePath = savedImage.path; // Met à jour avec le chemin local
          isModified = true;
        });

        // Mettre à jour l'image dans la base de données avec le chemin local
        await updateImageInDatabase(currentImagePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image mise à jour et sauvegardée avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucune image sélectionnée.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour de l\'image : $e')),
      );
    }
  }

  Future<void> updateImageInDatabase(String localPath) async {
    try {
      await FirebaseFirestore.instance
          .collection('Fish')
          .doc(widget.userId)
          .collection('user_fish')
          .doc(widget.docId)
          .update({'picture': localPath});
    } catch (e) {
      print("Erreur de mise à jour du poisson : $e");
    }
  }

  Future<void> fetchFishDetails() async {
    try {
      _fishPosition = await getOneFish(); // Remplacez par l'ID réel
      if (_fishPosition != null) {
        print("Données du poisson : $_fishPosition");
      } else {
        print("Aucune donnée trouvée pour ce poisson.");
      }
    } catch (e) {
      print("Erreur lors de la récupération des détails du poisson : $e");
    }
  }

  Future<Map<String, dynamic>?> getOneFish() async {
    try {
      // Récupérer le document par son ID
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('Fish')
          .doc(widget.userId) // Remplace par l'ID utilisateur correct
          .collection('user_fish')
          .doc(widget.docId)
          .get();

      if (document.exists) {
        // Retourner les données du document sous forme de Map
        return document.data() as Map<String, dynamic>?;
      } else {
        print("Document non trouvé");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la récupération du poisson : $e");
      return null;
    }
  }

  // Fonction pour formater le timestamp
  String timeStampToDateFormat(Timestamp timestamp) {
    DateTime inputDate = timestamp.toDate();
    DateFormat outputFormat = DateFormat('dd/MM/yyyy HH:mm');
    return outputFormat.format(inputDate);
  }

}


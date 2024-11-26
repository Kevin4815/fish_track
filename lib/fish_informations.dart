import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_track/gps.dart';
import 'package:fish_track/location_service.dart';
import 'package:fish_track/map_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
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

  // Ajouter une variable pour suivre les modifications
  bool isModified = false; // Suivi des modifications

  // Stocker un map pour les timers de chaque champ
  Map<String, bool> activeFields = {
    'Type': false,
    'Taille': false,
    'Canne': false,
    'Lieu': false,
  };

  final TextEditingController _updateData = TextEditingController();
  late MapLocation mapLocation;
  LocationData? _position;

  @override
  void initState() {
    super.initState();
    formattedDate = timeStampToDateFormat(widget.date);
    editableType = widget.type;
    editableSize = widget.size;
    editableRod = widget.rod;
    mapLocation = MapLocation();

    fetchFishDetails();

  // Récupère la position actuelle
    mapLocation.currentPosition((position) {
      if(mounted){
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF28A2C8),
        title: const Text('Informations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Icône de la flèche de retour
          onPressed: () {
            Navigator.pop(context, isModified ? true : false);
          },
        ),
      ),
      body: Stack(
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage("images/river.jpg"),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          // // Couche semi-transparente
          // Container(
          //   color: Colors.black.withOpacity(0.4),
          // ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image en haut
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      child: widget.picture.startsWith('/')
                          ? Image.file(
                              File(widget.picture),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.picture,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Titre principal
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Le : $formattedDate",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Liste des informations
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
                  const SizedBox(height: 20),
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
                              ), // Centre sur la position actuelle
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
                                    onTap: () => launchUrl(
                                        Uri.parse('https://openstreetmap.org/copyright')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 10),
                  Row(
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Fonction pour construire une ligne d'information
  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$label :',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Le lieu n'est pas modifiable
                if (label != 'Lieu')
                  AnimatedOpacity(
                    opacity: activeFields[label]! ? 1.0 : 0.0, // Gère la visibilité
                    duration: const Duration(milliseconds: 300), // Animation
                    child: ElevatedButton(
                      onPressed: (activeFields[label] == true)
                          ? () {
                            showCustomAlertDialog(context, _updateData, label, value);
                          }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                        backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                        foregroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeFields.forEach((key, value) {
                        activeFields[key] = false;
                      });
                      activeFields[label] = true;
                    });

                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        activeFields[label] = false;
                      });
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 205, 202, 202),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showCustomAlertDialog(BuildContext context, TextEditingController controller, String label, String value) {
    TextEditingController dynamicController = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: TextField(
            controller: dynamicController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () async {
                String inputValue = dynamicController.text;
                await updateFish(inputValue);

                setState(() {
                  // Si la valeur a changé, on marque que la donnée a été modifiée
                  if ((label == "Type" && editableType != inputValue) || 
                      (label == "Taille" && editableSize != inputValue) || 
                      (label == "Canne" && editableRod != inputValue)) {
                    isModified = true; // Si la modification est effective, on marque qu'il y a un changement
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
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateFish(String updatedValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('Fish')
          .doc(widget.userId)
          .collection('user_fish')
          .doc(widget.docId)
          .update({'type': updatedValue});
    } catch (e) {
      print("Erreur de mise à jour du poisson : $e");
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

  // Fonction pour formater le timestamp
  String timeStampToDateFormat(Timestamp timestamp) {
    DateTime inputDate = timestamp.toDate();
    DateFormat outputFormat = DateFormat('dd/MM/yyyy HH:mm');
    return outputFormat.format(inputDate);
  }
}

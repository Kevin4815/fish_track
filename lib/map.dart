import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_track/app_bar.dart';
import 'package:fish_track/location_service.dart';
import 'package:fish_track/map_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MyMapPage extends StatefulWidget {
  MyMapPage({super.key, required this.title});

  final String title;

  @override
  State<MyMapPage> createState() => _MyMapPagePageState();
}

class _MyMapPagePageState extends State<MyMapPage> {
  late Future<List<Map<String, dynamic>>> _fishesPositionsList;
  final LocationService _locationService = LocationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocationData? _position;

  late MapLocation mapLocation;

  @override
  void initState() {
    super.initState();
    mapLocation = MapLocation(); // Initialiser mapLocation
    _fishesPositionsList = fishesList();

     // Récupère la position actuelle
    mapLocation.currentPosition((position) {
        setState(() {
          _position = position;
        });
      });
  }

  Future<List<Map<String, dynamic>>> fishesList() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .get();

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Fish')
            .doc(userId)
            .collection('user_fish')
            .get();

        List<Map<String, dynamic>> fishesPositionList = querySnapshot.docs
            .map((doc) {
              final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return {
                ...data, // Utiliser l'opérateur spread avec les données
                'name': userDataSnapshot['name'], // Ajouter le nom de l'utilisateur
                'id': doc.id // Ajoutez l'ID du document ici pour la suppression
              };
            })
            .toList();

        // Afficher le contenu de la liste fishPositionList
        print('Contenu de la liste fishPositionList :');
        for (int i = 0; i < fishesPositionList.length; i++) {
          print('Élément $i : ${fishesPositionList[i]}');
        }

        return fishesPositionList;
      } else {
        print('No user signed in.');
        return [];
      }
    } catch (error) {
      print('Failed to get fish data: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si la position est nulle et attendre le chargement
    if (_position == null) {
      return const Center(child: CircularProgressIndicator()); // Affiche un indicateur de chargement
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes spots',
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fishesPositionsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Affiche un indicateur de chargement
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}')); // Affiche l'erreur si elle se produit
          } else {
            // Si tout est correct, récupérer les données
            List<Map<String, dynamic>> fishesPositionList = snapshot.data!;

            return FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_position!.latitude!, _position!.longitude!), // Centre sur la position actuelle
                initialZoom: 9.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: mapLocation.buildMarkers(fishesPositionList), // Appeler la méthode pour générer les marqueurs
                ),
              ],
            );
          }
        },
      ),
    );
  }

}

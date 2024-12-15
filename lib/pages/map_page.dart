import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_track/map_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MyMapPage extends StatefulWidget {
  MyMapPage({super.key, required this.title, required this.isDarkMode});

  final String title;
  final bool isDarkMode;

  @override
  State<MyMapPage> createState() => _MyMapPagePageState();
}

class _MyMapPagePageState extends State<MyMapPage> {
  late Future<List<Map<String, dynamic>>> _fishesPositionsList;
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
      if (mounted) {
        setState(() {
          _position = position;
          print(_position);
        });
      }
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
    return Scaffold(
      body: Builder(
        builder: (context) {
          // Si la position est nulle, afficher un indicateur de chargement en attendant qu'elle soit récupérée
          if (_position == null) {
            return const Center(child: CircularProgressIndicator()); // Affiche un indicateur de chargement pendant que la position est récupérée
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fishesPositionsList,
            builder: (context, snapshot) {
              // Si la récupération des poissons prend du temps, afficher un indicateur de chargement
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              } else {
                // Si tout est chargé, afficher la carte
                List<Map<String, dynamic>> fishesPositionList = snapshot.data!;

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(_position!.latitude!, _position!.longitude!),
                    initialZoom: 9.2,
                  ),
                  children: [
                   TileLayer(
                      urlTemplate: widget.isDarkMode
                          ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png'
                          : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
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
                      markers: mapLocation.buildMarkers(fishesPositionList),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}

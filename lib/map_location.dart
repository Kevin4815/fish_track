import 'package:fish_track/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Pour flutter_map
import 'package:latlong2/latlong.dart'; // Importer LatLng depuis latlong2
import 'package:location/location.dart';

class MapLocation {
  final LocationService _locationService = LocationService();
  LocationData? _position;

  Future<void> currentPosition(Function(LocationData?) onPositionUpdated) async {
    LocationData? position = await _locationService.getCurrentPosition();
    onPositionUpdated(position);
  }


  Future<dynamic> getCurrentFishPosition(Map<String, dynamic> fish) async {
    return fish['position'];
  }

  // Getter pour obtenir LatLng à partir de la position
  LatLng? get latLng {
    if (_position != null) {
      // Si la position est disponible, retourner un LatLng
      return LatLng(_position!.latitude!, _position!.longitude!);
    }
    return null; // Retourner null si la position n'est pas définie
  }

  // Fonction pour construire les marqueurs
  List<Marker> _buildMarkers(List<Map<String, dynamic>> fishesPositionList) {
    return fishesPositionList.map((fish) {
      final position = fish['position'];
      if (position != null) {
        return Marker(
          point: LatLng(position['latitude'], position['longitude']),  // Utilisation de LatLng de latlong2
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red, // Couleur de l'épingle
            size: 40, // Taille de l'épingle
          ),
        );
      } else {
        return null; // Retourner null si la position n'est pas valide
      }
    }).where((marker) => marker != null).cast<Marker>().toList(); // Filtrer les marqueurs null
  }

  List<Marker> _buildMarkerForFish(Map<String, dynamic> fish) {
    final latitude = fish['latitude'];
    final longitude = fish['longitude'];

    // Vérifier si la latitude et la longitude existent (ne sont pas null)
    if (latitude != null && longitude != null) {
      // Si la latitude et la longitude sont valides, créer le marqueur
      return [
        Marker(
          point: LatLng(latitude, longitude),  // Utilisation de LatLng de latlong2
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,  // Couleur de l'épingle
            size: 40,           // Taille de l'épingle
          ),
        ),
      ];
    }

    // Si la latitude ou la longitude est null, ne pas retourner de marqueur
    return [];  // Liste vide, pas de marqueur
  }




  // Getter pour la position
  LocationData? get position => _position;

  // Getter pour la fonction de construction des marqueurs
  List<Marker> Function(List<Map<String, dynamic>> fishesPositionList) get buildMarkers => _buildMarkers;
  List<Marker> Function(Map<String, dynamic> fish) get buildMarkerForFish => _buildMarkerForFish;
}

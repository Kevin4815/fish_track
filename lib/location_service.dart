import 'package:location/location.dart';

class LocationService {
  LocationData? _position; // Position peut être null tant qu'elle n'est pas obtenue
  bool _isLoading = true; // Indique si la position est en cours de chargement

  // Méthode pour obtenir la position
  Future<LocationData?> getCurrentPosition() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Vérifie si le service de localisation est activé
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Si le service n'est pas activé, demande à l'utilisateur de l'activer
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _isLoading = false; // Fin du chargement même si l'utilisateur refuse le service
        return null;
      }
    }

    // Vérifie les permissions de localisation
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _isLoading = false; // Fin du chargement si les permissions sont refusées
        return null;
      }
    }

    // Obtient la position actuelle
    _position = await location.getLocation();
    _isLoading = false; // Fin du chargement après avoir obtenu la position

    print("oeoeoeoeo");
    print(_position);

    return _position; // Retourne la position
  }

  bool isLoading() => _isLoading; // Accesseur pour vérifier si le chargement est en cours
}

import 'package:url_launcher/url_launcher.dart';

class GPS{

  Future<void> launchWaze(double lat, double lng) async {
    var wazeUrl = 'waze://?ll=${lat.toString()},${lng.toString()}';
    var fallbackUrl =
        'https://waze.com/ul?ll=${lat.toString()},${lng.toString()}&navigate=yes';

    final Uri uri = Uri.parse(wazeUrl);
    final Uri fallbackUri = Uri.parse(fallbackUrl);

    try {
      bool launched = await launchUrl(uri); 

      if (launched) {
        await launchUrl(uri);
      } else {
        await launchUrl(fallbackUri);
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de Waze: $e');
    }
  }


  Future<void> launchGoogleMaps(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    final Uri uri = Uri.parse(googleUrl);

    try{
      bool launched = await launchUrl(uri);  // Vérifier si Waze est installé

      if (launched) {
        await launchUrl(Uri.parse(googleUrl));
      }
    } catch (e){
      print('Erreur lors de l\'ouverture de Google Maps: $e');
    }
  }
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_track/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FishInformations extends StatefulWidget {
  const FishInformations({
    super.key,
    required this.title,
    required this.city,
    required this.picture,
    required this.size,
    required this.type,
    required this.rod,
    required this.date,
  });

  final String title;
  final String city;
  final String picture;
  final String size;
  final String type;
  final String rod;
  final Timestamp date;

  @override
  State<FishInformations> createState() => _MyFishInformationsState();
}

class _MyFishInformationsState extends State<FishInformations> {
  late String formattedDate;

  @override
  void initState() {
    formattedDate = timeStampToDateFormat(widget.date);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Informations',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image en haut
            SizedBox(
              height: 250,
              child: ClipRRect(
               child: widget.picture.startsWith('/')
               // Si l'image vient de la base de données
                ? Image.file(
                    File(widget.picture),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                  // Si elle vient du projet (pas d'image ajouté en base de données)
                : Image.asset(
                    widget.picture, // Chemin relatif à l'asset
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
                    buildInfoRow("Type", widget.type),
                    const SizedBox(height: 10),
                    buildInfoRow("Taille", widget.size),
                    const SizedBox(height: 10),
                    buildInfoRow("Canne", widget.rod),
                    const SizedBox(height: 10),
                    buildInfoRow("Lieu", widget.city),
                  ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour construire une ligne d'information
  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
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
                color:  Color(0xFF28A2C8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour formater le timestamp
  String timeStampToDateFormat(Timestamp timestamp) {
    DateTime inputDate = timestamp.toDate();
    DateFormat outputFormat = DateFormat('dd/MM/yyyy hh:mm');
    return outputFormat.format(inputDate);
  }
}

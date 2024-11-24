import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_track/app_bar.dart';
import 'package:fish_track/fish_informations.dart';
import 'package:flutter/material.dart';

class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key, required this.title, required this.userId});

  final String title;
  final String userId;

  @override
  State<MainAppPage> createState() => _MyMainAppPageState();
}

class _MyMainAppPageState extends State<MainAppPage> {
  late Future<List<Map<String, dynamic>>> _fishData;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fishData = getFishData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes pêches',
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
          // Couche semi-transparente
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Contenu principal
          Center(
            child: FutureBuilder<List<Map<String, dynamic>>>(  // FutureBuilder pour récupérer les données
              future: _fishData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.white);
                } else if (snapshot.hasError) {
                  return Text(
                    'Erreur : ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  );
                } else {
                  final fishList = snapshot.data!;
                  if (fishList.isEmpty) {
                    return const Text(
                      "Aucune pêche enregistrée.",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    );
                  }
                  return ListView.builder(
                    itemCount: fishList.length,
                    itemBuilder: (context, index) {
                      final fishData = fishList[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FishInformations(
                                userId: fishData['userId'],
                                docId: fishData['docId'],
                                title: "Informations",
                                city: fishData.containsKey('position') && fishData['position']?.containsKey('city') == true
                                    ? fishData['position']['city']
                                    : 'Inconnue',
                                picture: fishData.containsKey('picture') && fishData['picture'] != null && fishData['picture'].isNotEmpty
                                    ? fishData['picture']
                                    : 'images/no_photo.jpg',
                                size: fishData.containsKey('size') && fishData['size'] != null
                                    ? fishData['size']
                                    : 'Taille non spécifiée',
                                type: fishData.containsKey('type') && fishData['type'] != null
                                    ? fishData['type']
                                    : 'Type non spécifié',
                                rod: fishData.containsKey('rod_type') && fishData['rod_type'] != null
                                    ? fishData['rod_type']
                                    : 'Type de canne non spécifié',
                                date: fishData.containsKey('timestamp') && fishData['timestamp'] != null
                                    ? fishData['timestamp'] as Timestamp
                                    : Timestamp.fromDate(DateTime.now()),
                              ),
                            ),
                          );

                          // Si le résultat est true, on recharge les données
                          if (result == true) {
                            setState(() {
                              _fishData = getFishData(); // Rafraîchir les données
                            });
                          }
                        },
                        child: Dismissible(
                          key: Key(fishData['id'].toString()),
                          direction: DismissDirection.endToStart,
                          resizeDuration: const Duration(milliseconds: 200),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await _showDeleteConfirmationDialog(
                                  context, fishData['id'].toString());
                            }
                            return false;
                          },
                          background: Container(
                            color: Colors.blue,  // Couleur de fond pour les paramètres
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.settings, color: Colors.white),  // Icône des paramètres
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,  // Couleur de fond pour la suppression
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),  // Icône de suppression
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                // Image du poisson
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: fishData['picture'] != null && fishData['picture'].isNotEmpty
                                      ? Image.file(
                                          File(fishData['picture']),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'images/no_photo.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Informations sur le poisson
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow("Pêcheur", fishData['name']),
                                      _buildInfoRow("Type", fishData['type']),
                                      _buildInfoRow("Taille", "${fishData['size']} cm"),
                                      _buildInfoRow("Canne", fishData['rod_type']),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getFishData() async {
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

        List<Map<String, dynamic>> fishDataList = querySnapshot.docs.map((doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'name': userDataSnapshot['name'],
            'userId': userId,
            'docId': doc.id,
          };
        }).toList();

        return fishDataList;
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context, String cardId) async {
    String? userId = FirebaseAuth.instance.currentUser!.uid;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmer la suppression'),
              content: const Text('Êtes-vous sûr de vouloir supprimer cet élément ?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Supprimer'),
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection("Fish")
                          .doc(userId)
                          .collection("user_fish")
                          .doc(cardId)
                          .delete();
                      Navigator.of(context).pop(true);
                    } catch (error) {
                      Navigator.of(context).pop(false);
                    }
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

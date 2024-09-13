import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_track/app_bar.dart';
import 'package:flutter/material.dart';


class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key, required this.title, required this.userId});

  final String title;
  final String userId;

  @override
  State<MainAppPage> createState() => _MyMainAppPageState();
}

class _MyMainAppPageState extends State<MainAppPage> {
  final CollectionReference _collectionRef = FirebaseFirestore.instance.collection('Fish');
  late Future<List<Map<String, dynamic>>> _fishData;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fishData = getFishData();
  }
  

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(
      title: 'Mes poissons',
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
              image: AssetImage("images/home.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Contenu de FutureBuilder superposé
        Center(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fishData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erreur : ${snapshot.error}');
              } else {
                final fishList = snapshot.data!;
                return ListView.builder(
                  itemCount: fishList.length,
                  itemBuilder: (context, index) {
                    final fishData = fishList[index];
                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.all(4.0),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromARGB(255, 205, 208, 211),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Pêcheur : ', style: TextStyle(fontSize: 12)),
                                    Text('${fishData['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Type : ', style: TextStyle(fontSize: 12)),
                                    Text('${fishData['type']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Taille : ', style: TextStyle(fontSize: 12)),
                                    Text('${fishData['size']} cm', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Canne: ', style: TextStyle(fontSize: 12)),
                                    Text('${fishData['rod_type']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.file(
                                      File(fishData['picture']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
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
            
        List<Map<String, dynamic>> fishDataList = querySnapshot.docs
            .map((doc) {
              final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              final Map<String, dynamic>? nullableData = data;
              final Map<String, dynamic> nonNullableData = nullableData ?? {}; // Si nullableData est null, utilisez un objet vide
              return {
                ...nonNullableData, // Utiliser l'opérateur spread avec nonNullableData
                'name': userDataSnapshot['name'], // Ajouter le nom de l'utilisateur
              };
            })
            .toList();


        // Afficher le contenu de la liste fishDataList
        print('Contenu de la liste fishDataList :');
        for (int i = 0; i < fishDataList.length; i++) {
          print('Élément $i : ${fishDataList[i]}');
        }


        return fishDataList;
      } else {
        print('No user signed in.');
        return [];
      }
    } catch (error) {
      print('Failed to get fish data: $error');
      return [];
    }
  }
}

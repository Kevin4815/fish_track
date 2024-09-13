import 'package:fish_track/add_fishing_page.dart';
import 'package:fish_track/main_app_page.dart';
import 'package:fish_track/messages_pages.dart';
import 'package:flutter/material.dart';


class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomNavigationBarExample(userId: userId),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
      
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      MainAppPage(title: "Home", userId: widget.userId,),
      AddFishingPage(title: "Fishing", userId: widget.userId),
      const MessagesPage(title: "Messages"),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ajouter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 8, 164, 255),
        onTap: _onItemTapped,
      ),
    );
  }
}

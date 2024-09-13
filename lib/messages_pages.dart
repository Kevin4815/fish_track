import 'package:flutter/material.dart';


class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key, required this.title});

  final String title;

  @override
  State<MessagesPage> createState() => _MyMessagesPageState();
}

class _MyMessagesPageState extends State<MessagesPage> {

 @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Stack(
          children: [
            Text("Page de messages")
          ],
        ),
      ),
    );
  }
}
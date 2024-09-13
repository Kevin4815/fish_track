import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';


class MessageToast {

  static void displayToast(String message){
    Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 37, 37, 37),
          textColor: Colors.white,
          fontSize: 16.0
      );
  }
}


import 'package:flutter/material.dart';

class ColorProvider extends ChangeNotifier {


  Color currentColor = Colors.red;


  void changeColor() {

    if (currentColor == Colors.red) {
      currentColor = Colors.blue;
    } 
    else {
      currentColor = Colors.red;
    }


    notifyListeners();
  }
}

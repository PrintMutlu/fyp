import 'package:flutter/material.dart';
class LocationProvider extends ChangeNotifier {
  double x = 0;
  double y = 0;
  void updateLocation(double newX, double newY) {
    x = newX;
    y = newY;
    notifyListeners();
  }
}

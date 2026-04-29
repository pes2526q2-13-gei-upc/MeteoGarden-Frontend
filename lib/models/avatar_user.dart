import 'package:flutter/material.dart';

class AvatarUser with ChangeNotifier {
  String body = '';
  String eye = '';
  String expression = '';
  String hair = '';
  String facialHair = '';
  String clothing = '';
  String accessories = '';

  void setAvatar({
    required String newBody,
    required String newEye,
    required String newExpression,
    required String newHair,
    required String newFacialHair,
    required String newClothing,
    required String newAccessories,
  }) {
    body = newBody;
    eye = newEye;
    expression = newExpression;
    hair = newHair;
    facialHair = newFacialHair;
    clothing = newClothing;
    accessories = newAccessories;
    notifyListeners();
  }
}

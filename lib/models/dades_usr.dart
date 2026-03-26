/*
Per utilitzar les dades desde qualsevol screen s'ha de fer:

final user = Provider.of<UserModel>(context);
Text('Benvingut, ${user.username}');

i afegir aquests 2 imports:

import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';

Per guardar qualsevol dada nova, s'ha de fer (també son necessaris els imports):

Provider.of<UserModel>(context, listen: false).setToken(jsonDecode(response.body)['token']);

Si es vol actualitzar una dada concreta(una combinació de atributs que no estigui definida)
s'ha de crear una funció que editi aquella dada i cridar desde la pantalla en la que es vulgui editar
 
 */

import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String username = '';
  String email = '';
  String city = '';
  String language = '';
  String lastEntry = '';
  int numPlantsCollected = 0;
  int monedes = 0;
  String token = '';
  List<String> gardens = [];
  void setToken(String newToken) {
    token = newToken;
    notifyListeners();
  }

  // Helpers per agafar el primer valor dels jardins
  String get gardenName => gardens.isNotEmpty ? gardens.first : '';

  void setProfile({
    required String newUsername,
    required String newEmail,
    required String newCity,
    required String newLanguage,
    required String newLastEntry,
    required int newNumPlantsCollected,
    required int newMonedes,
    required List<String> newGardens,
  }) {
    username = newUsername;
    email = newEmail;
    city = newCity;
    language = newLanguage;
    lastEntry = newLastEntry;
    numPlantsCollected = newNumPlantsCollected;
    monedes = newMonedes;
    gardens = newGardens;
    notifyListeners();
  }

  void clearUser() {
    username = '';
    email = '';
    city = '';
    language = '';
    lastEntry = '';
    numPlantsCollected = 0;
    monedes = 0;
    token = '';
    gardens = [];
    notifyListeners();
  }
}

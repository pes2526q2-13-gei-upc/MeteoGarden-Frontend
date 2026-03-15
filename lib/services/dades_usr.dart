import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String username = '';
  String email = '';
  String city = '';
  String language = '';
  String lastEntry = '';
  String numPlantsCollected = '';
  String monedes = '';
  String token = '';

 /*
Per utilitzar les dades desde qualsevol screen s'ha de fer:

final user = Provider.of<UserModel>(context);
Text('Benvingut, ${user.username}');

i afegir aquests 2 imports:

import 'package:provider/provider.dart';
import 'package:meteo_gareden/services/dades_usr.dart';

Per guardar qualsevol dada nova, s'ha de fer (també son necessaris els imports):

Provider.of<UserModel>(context, listen: false).setToken(jsonDecode(response.body)['token']);

Si es vol actualitzar una dada concreta(una combinació de atributs que no estigui definida)
s'ha de crear una funció que editi aquella dada i cridar desde la pantalla en la que es vulgui editar
 
 */

  void setUser(String name, String mail, String cityName, String langaugenew, 
  String lastEntryNew, String numPlantsCollectedNew) {
    username = name;
    email = mail;
    city = cityName;
    language = langaugenew;
    lastEntry = lastEntryNew;
    numPlantsCollected = numPlantsCollectedNew;
    notifyListeners(); // avisa a totes les pantalles
  }

  void setToken(String token) {
    token = token;
    notifyListeners(); // avisa a totes les pantalles
  }
}
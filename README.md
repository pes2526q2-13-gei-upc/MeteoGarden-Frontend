# MeteoGarden Frontend

Aquest repositori conté el frontend de MeteoGarden, una aplicació desenvolupada amb Flutter i Dart.

El frontend permet als usuaris interactuar amb l’aplicació des d’una interfície mòbil, gestionar el seu jardí, consultar informació meteorològica, veure plantes, inventari, esdeveniments i altres funcionalitats relacionades amb el projecte.

Aquest frontend forma part del projecte MeteoGarden i ha estat desenvolupat amb Flutter i Dart amb l’objectiu d’oferir una aplicació mòbil multiplataforma, intuïtiva i accessible per gestionar jardins virtuals relacionats amb dades meteorològiques reals.



### TECNOLOGIES UTILITZADES

- Dart: llenguatge de programació utilitzat per desenvolupar l’aplicació.
- Flutter: framework per crear aplicacions multiplataforma.
- Visual Studio Code: editor recomanat per desenvolupar i executar el projecte.
- Android Emulator o dispositiu Android físic: necessari per provar l’aplicació en entorn mòbil.


### INSTAL·LACIÓ DE DART I FLUTTER

Per executar el projecte és necessari tenir instal·lat Flutter SDK.

Flutter ja inclou el SDK de Dart, per tant, normalment no cal instal·lar Dart per separat si Flutter s’ha instal·lat correctament.

Passos d’instal·lació en Windows:

1. Instal·lar Visual Studio Code.
2. Obrir Visual Studio Code.
3. Anar a la pestanya d’extensions.
4. Buscar i instal·lar l’extensió oficial de Flutter.
5. L’extensió de Dart s’instal·larà automàticament.
6. Obrir la paleta de comandes amb:

   Ctrl + Shift + P

7. Escriure:

   Flutter: New Project

8. Si Visual Studio Code no troba el SDK de Flutter, permetrà descarregar-lo i afegir-lo al PATH.

També es pot comprovar si Flutter està ben instal·lat executant:

   flutter doctor

Aquest comandament mostra l’estat de la instal·lació i indica si falta configurar algun component, com Android Studio, l’emulador o les eines d’Android.


### ÚS DE VISUAL STUDIO CODE

Per treballar amb el projecte es recomana obrir la carpeta arrel del frontend amb Visual Studio Code.

Passos:

1. Obrir Visual Studio Code.
2. Seleccionar:

   File > Open Folder

3. Obrir la carpeta del projecte MeteoGarden-Frontend.
4. Obrir una terminal integrada amb:

   Ctrl + `

5. Executar les comandes necessàries des de la carpeta arrel del projecte.

Les extensions de Flutter i Dart permeten executar, depurar i gestionar l’aplicació directament des de Visual Studio Code.


### REQUISITS PREVIS

Abans d’executar el projecte cal tenir instal·lat:

- Flutter SDK
- Dart SDK, inclòs amb Flutter
- Visual Studio Code
- Extensió Flutter per Visual Studio Code
- Extensió Dart per Visual Studio Code
- Android Studio o Android SDK
- Un emulador Android o un dispositiu físic connectat


### ARQUITECTURA DEL PROJECTE

El projecte està organitzat en diferents carpetes dins del directori lib/.

Estructura principal:

lib/
 ├── main.dart
 ├── screens/
 ├── widgets/
 ├── models/
 ├── services/
 ├── providers/
 └── l10n/

Descripció de les carpetes principals:

- lib/main.dart
  Punt d’entrada de l’aplicació.

- lib/screens/
  Conté les pantalles principals de l’aplicació, com GardenPage, CalendarPage, FriendsPage, PerfilPage, entre d’altres.

- lib/widgets/
  Conté components reutilitzables de la interfície, com PotWidget, WeatherCard, AvatarStack o altres widgets comuns.

- lib/models/
  Conté els models de dades utilitzats per representar la informació de l’aplicació.

- lib/services/
  Conté les crides a l’API i la comunicació amb el backend.

- lib/providers/
  Conté classes encarregades de gestionar l’estat de l’aplicació.

- lib/l10n/
  Conté els fitxers de traducció i internacionalització.


### INTERNACIONALITZACIÓ

L’aplicació utilitza fitxers de traducció per permetre la internacionalització de la interfície.

Els fitxers de traducció es troben a:

   lib/l10n/

Per generar les traduccions cal executar:

   flutter gen-l10n

Aquest comandament genera els fitxers necessaris perquè l’aplicació pugui utilitzar els textos traduïts en els diferents idiomes configurats.


### INSTAL·LACIÓ DE DEPENDÈNCIES

Abans d’executar el projecte, cal instal·lar les dependències definides al fitxer pubspec.yaml.

Des de l’arrel del projecte, executar:

   flutter pub get

Aquest comandament descarrega totes les llibreries necessàries perquè el projecte pugui compilar i executar-se correctament.


### EXECUCIÓ DE L’APLICACIÓ

Per executar l’aplicació en un emulador o dispositiu connectat:

   flutter run

També es pot executar des de Visual Studio Code seleccionant un dispositiu a la barra inferior i prement el botó de Run o Debug.

Per veure els dispositius disponibles:

   flutter devices

Execució recomanada del projecte des de zero:

   flutter doctor
   flutter pub get
   flutter devices
   flutter run

Si apareixen errors després d’actualitzar dependències o canviar de branca, es recomana executar:

   flutter clean
   flutter pub get
   flutter run


### FORMAT I ANÀLISI DE CODI

Per mantenir la consistència del codi, es recomana formatar i analitzar el projecte abans de fer commits.

Per formatar el codi:

   dart format .

Per analitzar possibles errors o avisos:

   dart analyze

També es poden executar les dues comandes seguides:

   dart format .
   dart analyze


### GIT WORKFLOW

El projecte segueix una organització basada en branques.

Branques principals:

- main
  Conté la versió estable del projecte.

- develop
  Conté la versió d’integració on s’uneixen les funcionalitats abans de passar-les a main.

- feature/
  Branques utilitzades per desenvolupar noves funcionalitats.

- fix/
  Branques utilitzades per corregir errors.

- docs/
  Branques utilitzades per afegir o modificar documentació.

Flux típic de treball:

1. Canviar a la branca develop:

   git checkout develop

2. Actualitzar la branca develop:

   git pull

3. Crear una nova branca de funcionalitat:

   git checkout -b feature/nom-funcionalitat

4. Afegir els canvis:

   git add .

5. Fer commit dels canvis:

   git commit -m "feat: missatge del canvi"

6. Pujar la branca al repositori remot:

   git push -u origin feature/nom-funcionalitat

Per correccions d’errors es pot utilitzar:

   git checkout -b fix/nom-error

Per documentació es pot utilitzar:

   git checkout -b docs/nom-documentacio


### EXECUCIÓ DE TESTS

Abans d’executar qualsevol test, cal instal·lar les dependències del projecte:

   flutter pub get


### TESTS UNITARIS

Els tests unitaris serveixen per comprovar components, funcions o parts concretes del codi de manera aïllada.

Per executar tots els tests unitaris:

   flutter test

Per executar un test unitari concret:

   flutter test test/<NOM_TEST_UNITARI>.dart

Exemple:

   flutter test test/garden_page_test.dart


### TESTS D’INTEGRACIÓ

Els tests d’integració serveixen per comprovar el funcionament conjunt de diferents parts del sistema.

Abans d’executar els tests d’integració, cal tenir el backend aixecat.

Des del projecte del backend:

   docker compose up -d

Després, des del projecte Flutter:

   flutter test integration_test/<NOM_TEST_INTEGRACIO>.dart

Exemple:

   flutter test integration_test/login_integration_test.dart


### COBERTURA DELS TESTS UNITARIS

Per executar els tests i generar la cobertura:

   flutter test --coverage

Aquesta comanda executa tots els tests i genera el fitxer:

   coverage/lcov.info

Aquest fitxer conté la informació de cobertura del projecte, és a dir, quines parts del codi han estat executades pels tests.


### VISUALITZAR LA COBERTURA A VISUAL STUDIO CODE

Es pot instal·lar l’extensió Flutter Coverage a Visual Studio Code.

Aquesta extensió permet llegir el fitxer coverage/lcov.info i mostrar visualment quines línies del codi estan cobertes pels tests.

Passos:

1. Executar:

   flutter test --coverage

2. Instal·lar l’extensió Flutter Coverage a Visual Studio Code.

3. Obrir el projecte a Visual Studio Code.

4. Visualitzar la cobertura generada sobre els fitxers del projecte.


### GENERAR UN INFORME HTML DE COBERTURA

Per obtenir un informe més complet i visual, es pot utilitzar lcov.

A Windows, es pot instal·lar amb Chocolatey.

Cal obrir PowerShell com a administrador i executar:

   choco install lcov

Després, des de l’arrel del projecte, generar l’informe HTML amb:

   genhtml coverage/lcov.info -o coverage/html

Finalment, obrir l’informe al navegador:

   start coverage/html/index.html

L’informe HTML permet veure la cobertura global del projecte i consultar fitxer per fitxer quines línies estan cobertes pels tests.


### COMANDES ÚTILS

Comprovar l’estat de Flutter:

   flutter doctor

Instal·lar dependències:

   flutter pub get

Executar l’aplicació:

   flutter run

Mostrar dispositius disponibles:

   flutter devices

Generar traduccions:

   flutter gen-l10n

Executar tests:

   flutter test

Executar tests amb cobertura:

   flutter test --coverage

Formatar el codi:

   dart format .

Analitzar el codi:

   dart analyze

Netejar fitxers generats:

   flutter clean

Tornar a instal·lar dependències després de netejar:

   flutter pub get



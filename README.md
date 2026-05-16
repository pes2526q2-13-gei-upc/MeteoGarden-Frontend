# MeteoGarden-Frontend

---

ARQUITECTURA

El projecte està organitzat en diferents carpetes:

* lib/screens/ → pantalles principals (GardenPage, CalendarPage…)
* lib/widgets/ → components reutilitzables (PotWidget, WeatherCard…)
* lib/models/ → models de dades
* lib/services/ → crides a l’API
* lib/l10n/ → traduccions

---

INTERNACIONALITZACIÓ

Per generar les traduccions:

flutter gen-l10n

Els fitxers es troben a:
lib/l10n/

---

EXECUCIÓ

1. Instal·lar dependències

flutter pub get

2. Executar l’app

flutter run

---

FORMAT DE CODI

Per mantenir consistència:

dart format .
dart analyze

---

GIT WORKFLOW

Branques:

* main → estable
* develop → integració
* feature/<nom> → noves funcionalitats
* fix/<nom> → errors
* docs/<nom> → documentació

Flux típic:

git checkout develop
git pull
git checkout -b feature/<nom>

git add .
git commit -m "feat: missatge"
git push -u origin feature/<nom>

---

EXECUCIÓ DE TESTS

Abans d’executar qualsevol test, cal instal·lar les dependències del projecte:

flutter pub get


TESTS UNITARIS

Els tests unitaris serveixen per comprovar components o funcions de manera aïllada.

Per executar tots els tests unitaris:

flutter test

Per executar un test unitari concret:

flutter test test/<NOM_TEST_UNITARI>.dart

TESTS D’INTEGRACIÓ

Abans d’executar els tests d’integració, cal tenir el backend aixecat.

Des del projecte del backend:

docker compose up -d

Després, des del projecte Flutter:

flutter test integration_test/<NOM_TEST_INTEGRACIO>.dart

## Cobertura dels test unitaris

flutter test --coverage

Aquesta comanda executa tots els tests i genera el fitxer:

coverage/lcov.info

Aquest fitxer conté la informació de cobertura del projecte, és a dir, quines parts del codi han estat executades pels tests.

Visualitzar la cobertura a VS Code

Es pot instal·lar l’extensió Flutter Coverage a VS Code. Aquesta extensió permet llegir el fitxer coverage/lcov.info i mostrar visualment quines línies del codi estan cobertes pels tests.

Passos:

Executar:
flutter test --coverage
Instal·lar l’extensió Flutter Coverage a VS Code.
Obrir el projecte a VS Code i visualitzar la cobertura generada.
Generar un informe HTML de cobertura

Per obtenir un informe més complet i visual, es pot utilitzar lcov.

A Windows, es pot instal·lar amb Chocolatey. Cal obrir PowerShell com a administrador i executar:

choco install lcov

Després, des de l’arrel del projecte, generar l’informe HTML amb:

genhtml coverage/lcov.info -o coverage/html

Finalment, obrir l’informe al navegador:

start coverage/html/index.html

L’informe HTML permet veure la cobertura global del projecte i consultar fitxer per fitxer quines línies estan cobertes pels tests.


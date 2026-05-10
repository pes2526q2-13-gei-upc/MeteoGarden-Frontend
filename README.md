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


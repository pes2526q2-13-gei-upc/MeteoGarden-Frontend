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

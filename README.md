# Bracelet intelligent de protection des enfants

Projet réalisé pendant l'**ARC Summer School 2026 (2ᵉ édition)**, The ARC Africa Research Center, formation IoT. Projet individuel.

Un bracelet connecté qui envoie une alerte aux parents lorsqu'une tentative de retrait est détectée. Ce dépôt contient la simulation Wokwi (ESP32, MQTT) et l'application mobile Flutter qui reçoit les alertes.

## Architecture

**Version réelle (prévue)** : le bracelet intégrerait une ESP32-CAM (microcontrôleur et caméra), un module GPS NEO-6M pour la localisation en temps réel, un capteur anti-arrachement qui détecte une tentative de retrait, un servo-moteur ou verrou qui empêche le retrait sans autorisation, et une batterie rechargeable.

**Simulation Wokwi (ce dépôt)** : pour valider la chaîne de communication, le projet utilise un ESP32, un DHT22 qui lit la température et l'humidité, un bouton qui simule une tentative de retrait, et une LED qui représente le déclenchement de l'alerte. Les messages de position et de photo sont des textes fixes, pas des données réelles.

```
ESP32 (Wokwi)                          Application Flutter
  DHT22 ──► ruth/iot/temperature ──┐
            ruth/iot/humidity ─────┤
  Bouton ─► ruth/iot/alerte ───────┼──► broker MQTT ──► tableau de bord, alertes
            ruth/iot/camera ───────┤    (test.mosquitto.org)
            ruth/iot/gps ──────────┘
  LED ◄── alerte
```

## Topics MQTT

| Topic | Contenu dans la simulation | Dans la version réelle |
|---|---|---|
| `ruth/iot/temperature` | Température lue par le DHT22 | Idem |
| `ruth/iot/humidity` | Humidité lue par le DHT22 | Idem |
| `ruth/iot/alerte` | Message d'alerte lors d'un appui sur le bouton | Déclenché par le capteur anti-arrachement |
| `ruth/iot/camera` | Message fixe de simulation | Photo de la personne prise par l'ESP32-CAM |
| `ruth/iot/gps` | Message fixe de simulation | Position fournie par le module GPS |

## Lancer la simulation

1. Ouvrir le projet Wokwi : [https://wokwi.com/projects/471454124411522049](https://wokwi.com/projects/471454124411522049)
2. Le code est dans `wokwi/bracelet.ino`, le schéma dans `wokwi/diagram.json`, les bibliothèques dans `wokwi/libraries.txt` (DHT sensor library, PubSubClient).
3. Lancer la simulation, puis cliquer sur le bouton pour déclencher une alerte : la LED s'allume et les messages apparaissent sur le moniteur série.

## Lancer l'application Flutter

```bash
cd flutter
flutter pub get
flutter run
```

L'application s'abonne aux cinq topics ci-dessus et affiche la température, l'humidité, la bannière d'alerte et l'historique des messages.

## Limites

- Le broker `test.mosquitto.org` est public : toute personne qui connaît les topics peut lire et publier. C'est acceptable pour une démonstration, mais pas pour un produit réel.
- Le GPS et la caméra ne sont pas simulés : leurs topics transmettent des messages fixes pour montrer le flux de l'alerte.
- La simulation n'a pas de batterie, de servo ni de capteur anti-arrachement.

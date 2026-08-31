# ZEFIR

**Moteur de compression vidéo locale haute précision pour Android & iOS.**

Conçu et développé par **Metoushael** (`com.metoushael.zefir`).

---

## 🎯 Présentation

Zefir est une application mobile Flutter épurée et performante dédiée à la réduction de volume de fichiers vidéo sur mobile sans sacrifier la netteté visuelle. Elle exécute l'intégralité des calculs en local grâce au moteur FFmpeg Core v6.0 GPL (libx264 + aac).

### ✨ Caractéristiques Principales
- **Traitement 100% Hors-Ligne (On-Device)** : Aucune donnée ou vidéo n'est envoyée vers des serveurs distants.
- **Profils d'Encodage Étalonnés** :
  - **Équilibré Standard** : CRF 26 • Scale 720p • AAC 128k (meilleur rapport qualité/taille).
  - **Distribution Rapide** : CRF 30 • Scale 540p • AAC 96k (poids plume pour messageries).
  - **Haute Fidélité** : CRF 22 • Résolution source • AAC 192k (préservation maximale de la dynamique).
  - **Archive Compacte** : CRF 33 • Scale 480p • AAC 64k (gain d'espace critique).
- **Rapport Comparatif Avant / Après** : Mesure précise de la taille initiale vs compressée, pourcentage d'économie et temps d'exécution.
- **Journal & Historique** : Consultation des vidéos compressées, lecture directe via lecteur système, partage instantané et gestion du stockage.
- **Interface Épurée & Précise** : Design architectural inspiré des outils de production vidéo avec typographie soignée et icônes officielles Material Design.

---

## 📁 Architecture du Projet (`lib/`)

```
lib/
├── app.dart                                # MaterialApp & configuration globale du thème
├── main.dart                               # Initialisation et cycle de démarrage
├── core/
│   ├── constants/
│   │   └── app_constants.dart              # Constantes, clés de stockage et métadonnées
│   ├── theme/
│   │   └── app_theme.dart                  # Palette architecturale sombre et composants
│   └── utils/
│       ├── file_helper.dart                # Gestionnaire de fichiers locaux et cache
│       └── formatters.dart                 # Formatage octets, temps et pourcentages
├── models/
│   ├── compression_preset.dart             # Définition des profils et arguments FFmpeg
│   ├── compression_result.dart             # Modèle de résultat et sérialisation JSON
│   └── video_item.dart                     # Entité vidéo et métadonnées techniques
├── services/
│   ├── ffmpeg_service.dart                 # Moteur d'exécution FFmpeg / FFprobe
│   ├── history_service.dart                # Persistance et gestion de l'historique
│   └── preferences_service.dart            # Gestion des réglages utilisateur
└── screens/
    ├── home_navigation_screen.dart         # Barre de navigation principale
    ├── compression/
    │   ├── compression_screen.dart         # Écran principal d'encodage
    │   └── widgets/
    │       ├── compression_progress_view.dart  # Télémétrie en temps réel (FPS, bitrate, progression)
    │       ├── compression_summary_card.dart   # Bilan comparatif et partage
    │       ├── file_selector_card.dart         # Sélecteur et inspecteur de métadonnées
    │       └── preset_selector.dart            # Sélecteur technique de profils
    ├── history/
    │   ├── history_screen.dart             # Journal des compressions & statistiques
    │   └── widgets/
    │       └── history_item_tile.dart      # Tuile d'enregistrement avec actions rapides
    └── settings/
        └── settings_screen.dart            # Préférences, purge de cache et crédits
```

---

## 🚀 Compilation & Build Automatisé (CI/CD)

Le projet intègre une pipeline GitHub Actions (`.github/workflows/build.yml`) qui compile automatiquement l'APK Android release à chaque push sur la branche `main`.

---

## 👨‍💻 Auteur
- **Metoushael**
- Package ID : `com.metoushael.zefir`

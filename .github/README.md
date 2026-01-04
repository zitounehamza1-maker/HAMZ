# Simulateur Promotion — APK (Flutter)

## Objectif
Une appli Android (APK) en étapes : Terrain → Surfaces → Coûts (standing) → Ventes → Résultats.

## Générer l’APK (le plus simple, sans installation Android Studio)
Méthode **GitHub Actions** (recommandée) :

1. Crée un dépôt GitHub (repo) vide
2. Upload tous les fichiers de ce dossier dans le repo
3. Va dans l’onglet **Actions**
4. Lance le workflow **Build Android APK** (bouton "Run workflow")
5. Télécharge l’artefact `simulateur_promotion_apk` → `app-release.apk`

## Installer l’APK sur ton téléphone
- Envoie le fichier `app-release.apk` sur ton Android
- Ouvre-le, accepte l’installation depuis "sources inconnues"

## Notes calcul
- Standings : ECO 2300 | MOYEN 3000 | HAUT 5000 (DH/m² construit)
- Vendable : App/RDC 85% ; Sous-sol 50% ; Mezzanine 50%
- Parking vendu seulement si "Parking titré" = ON

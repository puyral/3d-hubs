# 🛠️ Comment créer vos fichiers d'impression 3D à partir des fichiers `.scad`
(docuement généré par IA ✨)

Ce guide simple vous explique comment transformer les fichiers de conception `.scad` présents dans ce dossier en fichiers `.stl` prêts à être envoyés à votre imprimante 3D.

---

### 1. Télécharger OpenSCAD (Gratuit)
OpenSCAD est le logiciel gratuit qui permet de lire et de générer ces fichiers.
* **Téléchargez-le** sur le site officiel : [openscad.org/downloads.html](https://openscad.org/downloads.html)
* Installez-le sur votre ordinateur (Windows, Mac ou Linux).

### 2. Ouvrir le fichier de conception
* Double-cliquez sur le fichier `.scad` de votre choix (par exemple [ts-v2.scad](file:///Users/simon/Documents/3d-printing/meuble%20paul/ts-v2.scad) ou [ts-vibe.scad](file:///Users/simon/Documents/3d-printing/meuble%20paul/ts-vibe.scad)).
* Le logiciel s'ouvre avec une vue 3D à droite et du texte (le code) à gauche. *Ne vous préoccupez pas du texte !*

### 3. Ajuster les paramètres (Optionnel)
Si le modèle est personnalisable :
* Regardez le panneau à droite nommé **"Customizer"** (s'il n'apparaît pas, cochez-le dans le menu en haut : *View* -> *Customizer* ou *Fenêtre* -> *Customizer*).
* Vous pouvez y modifier les dimensions, le nombre de trous, etc. en changeant simplement les valeurs.

### 4. Calculer le modèle 3D (Le "Rendu")
Avant d'exporter, le logiciel doit calculer la forme finale en haute qualité.
* Cliquez sur le bouton **Rendu** (l'icône avec un cube et un sablier ⌛ dans la barre d'outils, ou appuyez sur la touche **F6** de votre clavier).
* Patientez quelques secondes pendant que le calcul s'effectue (une barre de chargement s'affiche en bas à droite).

### 5. Exporter pour l'impression (Fichier `.stl`)
* Une fois le rendu terminé, cliquez sur le bouton **Exporter en STL** (l'icône avec un cube et les lettres **STL** dans la barre d'outils, ou appuyez sur **F7**).
* Enregistrez votre fichier `.stl` sur votre ordinateur.

---

✨ **Et voilà !** Il ne vous reste plus qu'à ouvrir ce fichier `.stl` dans votre logiciel de découpe habituel (Slicer comme PrusaSlicer, Bambu Studio, Cura...) pour préparer votre impression.

J'utilise typiquement Orcaslicer. Les service d'impression 3d accptent directement les fichier stl.

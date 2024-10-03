# check-updates.sh

Ce script vérifie les mises à jour disponibles pour les paquets installés via `apt-get` sur les systèmes basés sur Debian. Il est conçu pour être exécuté à chaque ouverture de session afin de vous informer des mises à jour disponibles.
En l'état, ne fonctionne qu'avec un OS en version française.

## Fonctionnalités

- Vérifie les mises à jour disponibles via `apt-get`.
- Utilise `doas` si disponible, sinon utilise `sudo`.
- Vérifie les mises à jour à intervalles réguliers (nombre de jours défini par l'utilisateur).
- Affiche le nombre de mises à jour disponibles et les détails des paquets pouvant être mis à jour.

## Prérequis

- `apt-get` et `apt` doivent être installés sur votre système.
- `doas` ou `sudo` doivent être configurés pour permettre l'exécution de commandes en tant que superutilisateur.

## Installation

1. Clonez ce dépôt :

    ```sh
    git clone https://github.com/virgilejarrige/check-updates-debian-like.git
    
    cd check-updates-debian-like
    ```

2. Rendez le script exécutable :

    ```sh
    chmod +x check-updates.sh
    ```

3. Ajoutez un appel au script dans votre fichier de configuration de shell (`.bashrc`, `.zshrc`, etc.) :

    ```sh
    echo '~/chemin/vers/le-script/check-updates-debian-like/check-updates.sh' >> ~/.bashrc
    ```

    ou

    ```sh
    echo '~/chemin/vers/le-script/check-updates-debian-like/check-updates.sh' >> ~/.zshrc
    ```

    Remplacez `~/chemin/vers/votre-depot/check-updates.sh` par le chemin réel vers le script.

4. Rechargez votre fichier de configuration de shell :

    ```sh
    source ~/.bashrc
    ```

    ou

    ```sh
    source ~/.zshrc
    ```

## Utilisation

Le script sera exécuté automatiquement à chaque ouverture de session. Il vérifiera les mises à jour disponibles et affichera les résultats.

## Configuration

Lors de la première exécution, le script vous demandera de définir le nombre de jours entre chaque vérification. Cette configuration sera sauvegardée dans `~/.check-updates` pour les futures exécutions.

Vous pouvez choisir d'être rappelé ou non des mises à jour disponibles lors de chaque exécution du script.

Si vous souhaitez modifier le délais entre les vérifications de mises à jour, il faut effacer le fichier `~/.check-kupdates` et relancer le script manuellement :

   ```sh
   rm ~/.check-updates && source ~/.bashrc
   ```
    
   ou

   ```sh
   rm ~/.check-updates && source ~/.zshrc
   ```

## Remarques

- Le script nécessite les privilèges sudo ou doas pour effectuer les mises à jour.
- Il est conçu pour fonctionner avec apt-get et apt, donc principalement pour les systèmes Debian/Ubuntu.
- Si vous utilisez doas et que vous souhaitez éviter d'entrer votre mot de passe à chaque fois que la vérification est faite, vous pouvez éditer votre fichier /etc/doas.conf en ajoutant la ligne : 

```sh
permit nopass votre-utilisateur as root cmd apt-get update
```


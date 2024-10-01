# check-updates.sh

Ce script vérifie les mises à jour disponibles pour les paquets installés via `apt-get` sur les systèmes basés sur Debian. Il est conçu pour être exécuté à chaque ouverture de session afin de vous informer des mises à jour disponibles.
En l'état, ne fonctionne qu'avec un OS en version française.

## Fonctionnalités

- Vérifie les mises à jour disponibles via `apt-get`.
- Utilise `doas` si disponible, sinon utilise `sudo`.
- Vérifie les mises à jour à intervalles réguliers (par défaut tous les 3 jours).
- Affiche le nombre de mises à jour disponibles et les détails des paquets pouvant être mis à jour.

## Prérequis

- `apt-get` et `apt` doivent être installés sur votre système.
- `doas` ou `sudo` doivent être configurés pour permettre l'exécution de commandes en tant que superutilisateur.

## Installation

1. Clonez ce dépôt :

    ```sh
    git clone [https://github.com/votre-utilisateur/votre-depot.git](https://github.com/virgilejarrige/check-updates-debian-like.git)
    
    cd check-updates-debian-like
    ```

2. Rendez le script exécutable :

    ```sh
    chmod +x check-updates.sh
    ```

3. Ajoutez un appel au script dans votre fichier de configuration de shell (`.bashrc`, `.zshrc`, etc.) :

    ```sh
    echo '~/chemin/vers/votre-depot/check-updates.sh' >> ~/.bashrc
    ```

    ou

    ```sh
    echo '~/chemin/vers/votre-depot/check-updates.sh' >> ~/.zshrc
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

Vous pouvez modifier le délai de vérification des mises à jour en modifiant la variable `check_update_delay` dans le script. Par défaut, le délai est de 3 jours.

## Note sur "doas"

Si vous utilisez doas et que vous souhaitez éviter d'entrer votre mot de passe à chaque fois que la vérification est faite, vous pouvez éditer votre fichier /etc/doas.conf en ajoutant la ligne : 

```sh
permit nopass votre-utilisateur as root cmd apt-get update
```


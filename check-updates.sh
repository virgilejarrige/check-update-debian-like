#!/bin/bash

check_file="$HOME/.check-updates"
force_check=false
show_updates=false
install_updates_flag=false
delay_option=""
reset_flag=false

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -f, --force       Force la vérification des mises à jour."
    echo "  -s, --show        Affiche les mises à jour disponibles sans les installer."
    echo "  -i, --install     Force la vérification et installe les mises à jour lorsque le délai est écoulé."
    echo "  -d, --delay DAYS  Spécifie le délai en jours entre chaque vérification des mises à jour."
    echo "  -r, --reset       Réinitialise le fichier de configuration."
    echo "  -h, --help        Affiche ce message d'aide."
}

# Analyse des options de ligne de commande
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            force_check=true
            shift
            ;;
        -s|--show)
            show_updates=true
            shift
            ;;
        -i|--install)
            install_updates_flag=true
            shift
            ;;
        -d|--delay)
            if [ -z "$2" ]; then
                echo "Erreur : Veuillez spécifier le nombre de jours pour l'option -d."
                exit 1
            fi
            delay_option="$2"
            if [[ "$delay_option" =~ ^[0-9]+$ ]]; then
                echo "Mise à jour du délai entre chaque vérification effectuée."
                echo "$delay_option" > "$check_file"
                echo "1" >> "$check_file"  # Par défaut, installer automatiquement
                echo "0" >> "$check_file"  # 0 = ne pas rappeler
                exit 0
            else
                echo "Erreur : Le délai doit être un nombre entier."
                exit 1
            fi
            ;;
        -r|--reset)
            reset_flag=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

get_delay() {
    local delay=""
    local is_new=false

    if [ -f "$check_file" ]; then
        delay=$(sed -n '1p' "$check_file" 2>/dev/null)
        if ! [[ "$delay" =~ ^[0-9]+$ ]]; then
            delay=""
        fi
    fi

    if [ -z "$delay" ]; then
        while true; do
            read -p "Entrez le nombre de jours entre chaque vérification des mises à jour : " delay
            if [[ "$delay" =~ ^[0-9]+$ ]]; then
                echo "$delay" > "$check_file"
                is_new=true
                break
            else
                echo "Veuillez entrer un nombre entier valide."
            fi
        done
    fi

    echo "$delay:$is_new"
}

install_updates() {
    echo "Installation des mises à jour..."
    if command -v doas >/dev/null 2>&1; then
        if ! doas apt-get upgrade -y; then
            echo "Erreur lors de l'installation des mises à jour."
            return 1
        fi
    else
        if ! sudo apt-get upgrade -y; then
            echo "Erreur lors de l'installation des mises à jour."
            return 1
        fi
    fi
    echo "Mises à jour installées avec succès."

    echo "Nettoyage des paquets obsolètes..."
    if command -v doas >/dev/null 2>&1; then
        doas apt-get autoremove -y
    else
        sudo apt-get autoremove -y
    fi
    echo "Nettoyage terminé."

    return 0
}

check_updates() {
    echo "Vérification des mises à jour..."
    if command -v doas >/dev/null 2>&1; then
        if ! doas apt-get update -qq; then
            echo "Erreur lors de la mise à jour de la liste des paquets."
            return 1
        fi
    else
        if ! sudo apt-get update -qq; then
            echo "Erreur lors de la mise à jour de la liste des paquets."
            return 1
        fi
    fi

    updates_output=$(apt list --upgradable 2>/dev/null | grep -v 'En train de lister…')
    updates_available=$(echo "$updates_output" | grep -c 'pouvant')

    echo "Nombre de mises à jour disponibles : $updates_available"
    if [ "$updates_available" -gt 0 ]; then
        echo -e "\n$updates_available mise(s) à jour disponible(s) :"
        echo "$updates_output"

        if [ "$show_updates" = true ]; then
            return 0
        fi

        while true; do
            read -p "Appliquer les mises à jour O/N (N par défaut) ? " response
            case $response in
                [Oo]* )
                    if install_updates; then
                        touch "$check_file"
                        sed -i '3d' "$check_file" 2>/dev/null
                        echo "0" >> "$check_file"  # 0 = ne pas rappeler
                        return 0
                    else
                        return 1
                    fi
                    ;;
                [Nn]* | "" )
                    echo "Mises à jour non installées."
                    read -p "Souhaitez-vous être rappelé lors de la prochaine exécution du script O/N (O par défaut) ? " remind
                    case $remind in
                        [Nn]* )
                            touch "$check_file"
                            sed -i '3d' "$check_file" 2>/dev/null
                            echo "0" >> "$check_file"  # 0 = ne pas rappeler
                            ;;
                        * )
                            sed -i '3d' "$check_file" 2>/dev/null
                            echo "1" >> "$check_file"  # 1 = rappeler
                            ;;
                    esac
                    return 0
                    ;;
                * ) echo "Veuillez répondre par O ou N.";;
            esac
        done
    else
        echo "Aucune mise à jour disponible."
        touch "$check_file"
        sed -i '3d' "$check_file" 2>/dev/null
        echo "0" >> "$check_file"  # 0 = ne pas rappeler
    fi
}

check_file() {
    local delay_info=$(get_delay)
    local delay=$(echo $delay_info | cut -d':' -f1)
    local is_new=$(echo $delay_info | cut -d':' -f2)

    if [ "$is_new" = "true" ] || [ ! -f "$check_file" ] || [ $(wc -l < "$check_file") -lt 3 ]; then
        read -p "Souhaitez-vous que le script installe automatiquement les mises à jour lorsque le délai est écoulé ? (O/N, N par défaut) " auto_install
        case $auto_install in
            [Oo]* )
                echo "1" >> "$check_file"  # 1 = installer automatiquement
                ;;
            [Nn]* | "" )
                echo "0" >> "$check_file"  # 0 = ne pas installer automatiquement
                ;;
            * )
                echo "Veuillez répondre par O ou N."
                exit 1
                ;;
        esac
        echo "0" >> "$check_file"  # 0 = ne pas rappeler
        check_updates
    else
        local timestamp=$(date +%s)
        local delay_in_seconds=$(($delay * 24 * 60 * 60))
        local file_timestamp=$(stat -c %Y "$check_file")
        local next_check=$(($file_timestamp + $delay_in_seconds))
        local remind_flag=$(sed -n '3p' "$check_file")
        local auto_install_flag=$(sed -n '2p' "$check_file")

        if [ "$force_check" = true ] || [ "$timestamp" -ge "$next_check" ] || [ "$remind_flag" = "1" ]; then
            echo "Il est temps de vérifier les mises à jour."
            check_updates
            if [ "$install_updates_flag" = true ] && [ "$auto_install_flag" = "1" ]; then
                install_updates
            fi
        else
            local days_remaining=$(( ($next_check - $timestamp) / (24 * 60 * 60) + 1 ))
            echo "Les mises à jour seront vérifiées dans $days_remaining jour(s)."
        fi
    fi
}

if ! command -v apt-get >/dev/null 2>&1 || ! command -v apt >/dev/null 2>&1; then
    echo "Erreur : apt-get ou apt n'est pas disponible sur ce système."
    exit 1
fi

if [ "$reset_flag" = true ]; then
    rm -f "$check_file"
    echo "Fichier de configuration réinitialisé."
    exit 0
fi

check_file

#!/bin/bash

check_update_delay=3 #en nombre de jours. 
check_file="$HOME/.check-updates"

check_updates() {
    echo "Vérification des mises à jour..."
    if command -v doas >/dev/null 2>&1; then
        doas apt-get update -qq
    else
        sudo apt-get update -qq
    fi

    updates_output=$(apt list --upgradable 2>/dev/null | grep -v 'En train de lister…')
    updates_available=$(echo "$updates_output" | grep -c 'pouvant')

    echo "Nombre de mises à jour disponibles : $updates_available"
    if [ "$updates_available" -gt 0 ]; then
        echo -e "\n$updates_available mise(s) à jour disponible(s) :"
        echo "$updates_output"
    fi
}

check_file() {
#    echo "Vérification du fichier $check_file"
    local timestamp=$(date +%s)
    local delay_in_seconds=$(($check_update_delay * 24 * 60 * 60))

    if [ ! -f "$check_file" ]; then
 #       echo "Le fichier n'existe pas, création et vérification des mises à jour."
        check_updates
        touch "$check_file"
    else
        local file_timestamp=$(stat -c %Y "$check_file")
        local next_check=$(($file_timestamp + $delay_in_seconds))
 #       echo "Prochain contrôle prévu : $(date -d @$next_check)"
        
        if [ "$timestamp" -ge "$next_check" ]; then
            echo "Il est temps de vérifier les mises à jour."
            check_updates
            touch "$check_file"
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

check_file

#!/bin/bash

# ANSI Escape Codes für Farben
ORANGE='\033[0;33m'
NC='\033[0m' # Keine Farbe

# Funktion zur Anzeige des Menüs
show_menu() {
    echo -e "${ORANGE}==============================${NC}"
    echo -e "${ORANGE}  Interaktives Installationsmenü  ${NC}"
    echo -e "${ORANGE}==============================${NC}"
    echo "1) Programme installieren"
    echo "2) System neu starten"
    echo "3) Paketquellen erneuern"
    echo "4) Beenden"
    echo -n "Bitte wählen Sie eine Option: "
}

# Funktion zur Installation von Programmen
install_programs() {
    echo "Programme werden installiert..."
    # Hier können Sie Installationsbefehle hinzufügen
}

# Funktion zum Neustarten des Systems
restart_system() {
    echo "Das System wird neu gestartet..."
    # Hier können Sie den Neustart-Befehl hinzufügen
    # sudo reboot
}

# Funktion zum Erneuern der Paketquellen
refresh_sources() {
    echo "Paketquellen werden erneuert..."
    # Hier können Sie den Befehl zum Erneuern der Paketquellen hinzufügen
    # sudo apt update
}

# Hauptprogramm
while true; do
    show_menu
    read -r option
    case $option in
        1) install_programs ;;
        2) restart_system ;;
        3) refresh_sources ;;
        4) echo "Beenden..."; exit 0 ;;
        *) echo "Ungültige Option. Bitte versuchen Sie es erneut." ;;
    esac
done
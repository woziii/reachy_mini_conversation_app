#!/bin/bash
# Script pour lancer le démon Reachy Mini Lite (USB)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  Lancement du démon Reachy Mini"
echo "  (Version Lite - USB)"
echo "=========================================="
echo ""

# Vérifier si le démon est déjà en cours d'exécution
if pgrep -f "reachy-mini-daemon" > /dev/null; then
    echo -e "${YELLOW}⚠ Le démon Reachy Mini semble déjà être en cours d'exécution${NC}"
    echo "PID: $(pgrep -f 'reachy-mini-daemon')"
    read -p "Voulez-vous le relancer ? (o/N): " response
    if [ "$response" != "o" ]; then
        echo "Annulé."
        exit 0
    fi
    echo "Arrêt de l'ancien démon..."
    pkill -f "reachy-mini-daemon" || true
    sleep 2
fi

# Vérifier que la commande existe
if ! command -v reachy-mini-daemon &> /dev/null; then
    echo -e "${RED}✗ reachy-mini-daemon non trouvé${NC}"
    echo "Assurez-vous que le SDK Reachy Mini est installé:"
    echo "  pip install reachy-mini"
    exit 1
fi

# Détecter le port série (optionnel)
echo "Détection du port série USB..."
PORTS=$(ls /dev/tty.usb* /dev/ttyUSB* 2>/dev/null || true)

if [ -z "$PORTS" ]; then
    echo -e "${YELLOW}⚠ Aucun port série USB détecté${NC}"
    echo "Le démon tentera de détecter automatiquement le port"
    PORT_ARG=""
else
    echo -e "${GREEN}✓ Ports série détectés:${NC}"
    echo "$PORTS" | while read -r port; do
        echo "  - $port"
    done
    # Utiliser le premier port trouvé (ou laisser le démon auto-détecter)
    PORT_ARG=""
    echo ""
    echo "Le démon utilisera l'auto-détection du port"
fi

# Lancer le démon
echo ""
echo -e "${BLUE}Lancement du démon Reachy Mini...${NC}"
echo "Commande: reachy-mini-daemon $PORT_ARG"
echo ""

# Lancer en arrière-plan et capturer la sortie
reachy-mini-daemon $PORT_ARG > daemon.log 2>&1 &
DAEMON_PID=$!

# Attendre un peu pour voir si le démon démarre correctement
sleep 3

# Vérifier si le processus est toujours en cours
if ps -p $DAEMON_PID > /dev/null; then
    echo -e "${GREEN}✓ Démon lancé avec succès (PID: $DAEMON_PID)${NC}"
    echo ""
    echo "Le démon est en cours d'exécution en arrière-plan."
    echo "Logs disponibles dans: daemon.log"
    echo ""
    echo "Pour arrêter le démon:"
    echo "  pkill -f reachy-mini-daemon"
    echo "  ou: kill $DAEMON_PID"
    echo ""
    echo "Pour voir les logs en temps réel:"
    echo "  tail -f daemon.log"
else
    echo -e "${RED}✗ Le démon s'est arrêté immédiatement${NC}"
    echo "Vérifiez les logs:"
    echo "  cat daemon.log"
    exit 1
fi


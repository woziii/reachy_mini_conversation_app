#!/bin/bash
# Script pour lancer l'application de conversation Reachy Mini

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  Lancement de l'app de conversation"
echo "  Reachy Mini"
echo "=========================================="
echo ""

# Vérifier que l'environnement virtuel est activé
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${YELLOW}⚠ Environnement virtuel non activé${NC}"
    echo "Activation de l'environnement virtuel..."
    if [ -d ".venv" ]; then
        source .venv/bin/activate
        echo -e "${GREEN}✓ Environnement virtuel activé${NC}"
    else
        echo -e "${RED}✗ Environnement virtuel non trouvé${NC}"
        echo "Créez-le d'abord avec: ./scripts/setup_venv.sh"
        exit 1
    fi
fi

# Vérifier que le démon est en cours d'exécution
echo "1. Vérification du démon Reachy Mini..."
if ! pgrep -f "reachy-mini-daemon" > /dev/null; then
    echo -e "${YELLOW}⚠ Le démon Reachy Mini n'est pas en cours d'exécution${NC}"
    echo "Lancement du démon..."
    ./scripts/start_daemon.sh
    sleep 3
else
    echo -e "${GREEN}✓ Démon Reachy Mini détecté${NC}"
fi
echo ""

# Vérifier le fichier .env
echo "2. Vérification du fichier .env..."
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠ Fichier .env non trouvé${NC}"
    echo "Création du fichier .env..."
    python3 scripts/create_env.py || {
        echo -e "${RED}✗ Impossible de créer .env automatiquement${NC}"
        echo "Créez-le manuellement avec votre clé API OpenAI:"
        echo "  OPENAI_API_KEY=votre_clé_ici"
        exit 1
    }
else
    if grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null; then
        echo -e "${GREEN}✓ Fichier .env trouvé avec clé API${NC}"
    else
        echo -e "${YELLOW}⚠ Fichier .env trouvé mais clé API manquante ou invalide${NC}"
        echo "Vous devrez saisir la clé dans l'interface Gradio"
    fi
fi
echo ""

# Vérifier que l'app est installée
echo "3. Vérification de l'installation..."
if ! command -v reachy-mini-conversation-app &> /dev/null; then
    echo -e "${RED}✗ Commande reachy-mini-conversation-app non trouvée${NC}"
    echo "Installez l'app avec: pip install -e ."
    exit 1
fi
echo -e "${GREEN}✓ Application installée${NC}"
echo ""

# Lancer l'application
echo "4. Lancement de l'application..."
echo -e "${BLUE}L'interface web sera disponible sur: http://127.0.0.1:7860/${NC}"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter l'application"
echo ""

# Lancer avec --gradio
reachy-mini-conversation-app --gradio


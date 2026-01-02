#!/bin/bash
# Script pour créer un environnement virtuel propre avec Python 3.12.1

set -e

echo "=========================================="
echo "  Création de l'environnement virtuel"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Vérifier Python 3.12
echo "1. Vérification de Python 3.12..."
if command -v python3.12 &> /dev/null; then
    PYTHON_VERSION=$(python3.12 --version)
    echo -e "${GREEN}✓ $PYTHON_VERSION trouvé${NC}"
    PYTHON_CMD=python3.12
elif command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${YELLOW}⚠ $PYTHON_VERSION trouvé (3.12.1 recommandé)${NC}"
    PYTHON_CMD=python3
else
    echo -e "${RED}✗ Python 3 n'est pas installé${NC}"
    echo "Installez Python 3.12.1 avec: brew install python@3.12"
    exit 1
fi
echo ""

# Vérifier si uv est disponible
if command -v uv &> /dev/null; then
    echo "2. Utilisation de uv (recommandé)..."
    echo -e "${GREEN}✓ uv trouvé${NC}"
    USE_UV=true
else
    echo "2. Utilisation de venv standard..."
    USE_UV=false
fi
echo ""

# Supprimer l'ancien environnement virtuel s'il existe
if [ -d ".venv" ]; then
    echo "3. Suppression de l'ancien environnement virtuel..."
    rm -rf .venv
    echo -e "${GREEN}✓ Ancien environnement supprimé${NC}"
else
    echo "3. Aucun ancien environnement virtuel trouvé"
fi
echo ""

# Créer le nouvel environnement virtuel
echo "4. Création du nouvel environnement virtuel..."
if [ "$USE_UV" = true ]; then
    uv venv --python 3.12.1
    echo -e "${GREEN}✓ Environnement virtuel créé avec uv${NC}"
else
    $PYTHON_CMD -m venv .venv
    echo -e "${GREEN}✓ Environnement virtuel créé${NC}"
fi
echo ""

# Activer l'environnement virtuel
echo "5. Activation de l'environnement virtuel..."
source .venv/bin/activate

# Vérifier la version de Python dans le venv
PYTHON_VENV_VERSION=$(python --version)
echo -e "${GREEN}✓ Environnement activé: $PYTHON_VENV_VERSION${NC}"
echo ""

echo "=========================================="
echo -e "${GREEN}Environnement virtuel créé avec succès !${NC}"
echo "=========================================="
echo ""
echo "L'environnement est maintenant activé."
echo ""
echo "Prochaines étapes:"
echo "1. Installez les dépendances: ./scripts/install_dependencies.sh"
echo "   ou manuellement: uv sync (ou pip install -e .)"
echo ""
echo "Pour réactiver l'environnement plus tard:"
echo "  source .venv/bin/activate"


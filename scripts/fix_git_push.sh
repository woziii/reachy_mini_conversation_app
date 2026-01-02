#!/bin/bash
# Script pour résoudre le problème de push Git avec certificats SSL
# Change le remote de HTTPS à SSH

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "  Correction du problème de push Git"
echo "=========================================="
echo ""

# Vérifier si on est dans un repo git
if [ ! -d .git ]; then
    echo -e "${RED}✗ Ce n'est pas un répertoire Git${NC}"
    exit 1
fi

# Afficher l'URL actuelle
CURRENT_URL=$(git remote get-url origin 2>/dev/null || echo "")
echo "URL actuelle du remote 'origin':"
echo "  $CURRENT_URL"
echo ""

# Vérifier si c'est déjà en SSH
if [[ "$CURRENT_URL" == git@github.com:* ]]; then
    echo -e "${GREEN}✓ Le remote est déjà configuré en SSH${NC}"
    echo ""
    echo "Tentative de push..."
    git push origin develop && {
        echo -e "${GREEN}✓ Push réussi !${NC}"
        exit 0
    } || {
        echo -e "${YELLOW}⚠ Push échoué. Vérifiez votre authentification SSH${NC}"
        exit 1
    }
fi

# Vérifier si c'est HTTPS et extraire le nom du repo
if [[ "$CURRENT_URL" == https://github.com/* ]]; then
    REPO_PATH=$(echo "$CURRENT_URL" | sed 's|https://github.com/||' | sed 's|\.git$||')
    SSH_URL="git@github.com:${REPO_PATH}.git"
    
    echo "Changement vers SSH..."
    echo "  Ancien: $CURRENT_URL"
    echo "  Nouveau: $SSH_URL"
    echo ""
    
    read -p "Voulez-vous continuer ? (o/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "Annulé."
        exit 0
    fi
    
    git remote set-url origin "$SSH_URL"
    echo -e "${GREEN}✓ Remote changé vers SSH${NC}"
    echo ""
    
    echo "Test de connexion SSH..."
    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && {
        echo -e "${GREEN}✓ Connexion SSH réussie${NC}"
    } || {
        echo -e "${YELLOW}⚠ La connexion SSH a échoué ou n'est pas configurée${NC}"
        echo "Vérifiez que votre clé SSH est ajoutée à GitHub:"
        echo "  https://github.com/settings/keys"
        echo ""
        read -p "Voulez-vous quand même essayer le push ? (o/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Oo]$ ]]; then
            exit 1
        fi
    }
    
    echo ""
    echo "Tentative de push..."
    git push origin develop && {
        echo -e "${GREEN}✓ Push réussi !${NC}"
    } || {
        echo -e "${RED}✗ Push échoué${NC}"
        echo ""
        echo "Solutions alternatives:"
        echo "1. Vérifiez que votre clé SSH est ajoutée à GitHub"
        echo "2. Ou utilisez un Personal Access Token avec HTTPS:"
        echo "   git remote set-url origin https://USERNAME:TOKEN@github.com/${REPO_PATH}.git"
        exit 1
    }
else
    echo -e "${YELLOW}⚠ Format d'URL non reconnu${NC}"
    exit 1
fi



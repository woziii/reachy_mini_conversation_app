#!/bin/bash
# Script pour installer les prérequis système sur Mac M2 (Apple Silicon)

set -e  # Arrêter en cas d'erreur

echo "=========================================="
echo "  Configuration Mac M2 - Prérequis système"
echo "=========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Vérifier l'architecture
echo "1. Vérification de l'architecture..."
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    echo -e "${GREEN}✓ Architecture ARM64 détectée (Apple Silicon)${NC}"
else
    echo -e "${YELLOW}⚠ Architecture détectée: $ARCH (attendu: arm64)${NC}"
fi
echo ""

# 2. Installer Homebrew si nécessaire
echo "2. Vérification de Homebrew..."
if command_exists brew; then
    BREW_VERSION=$(brew --version | head -n 1)
    echo -e "${GREEN}✓ Homebrew installé: $BREW_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Homebrew n'est pas installé${NC}"
    echo "Installation de Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Ajouter Homebrew au PATH pour Apple Silicon
    if [ "$ARCH" = "arm64" ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi
echo ""

# 3. Installer CMake si nécessaire
echo "3. Vérification de CMake..."
if command_exists cmake; then
    CMAKE_VERSION=$(cmake --version | head -n 1)
    echo -e "${GREEN}✓ CMake installé: $CMAKE_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ CMake n'est pas installé${NC}"
    echo "Installation de CMake via Homebrew..."
    brew install cmake
fi
echo ""

# 4. Vérifier Xcode Command Line Tools
echo "4. Vérification de Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
    XCODE_PATH=$(xcode-select -p)
    echo -e "${GREEN}✓ Xcode Command Line Tools installés: $XCODE_PATH${NC}"
else
    echo -e "${YELLOW}⚠ Xcode Command Line Tools ne sont pas installés${NC}"
    echo "Installation de Xcode Command Line Tools..."
    xcode-select --install
    echo "⚠️  Suivez les instructions dans la fenêtre qui s'ouvre"
    echo "⚠️  Relancez ce script une fois l'installation terminée"
    exit 1
fi
echo ""

# 5. Vérifier pkg-config (souvent nécessaire pour fastRTC)
echo "5. Vérification de pkg-config..."
if command_exists pkg-config; then
    echo -e "${GREEN}✓ pkg-config installé${NC}"
else
    echo -e "${YELLOW}⚠ pkg-config n'est pas installé${NC}"
    echo "Installation de pkg-config via Homebrew..."
    brew install pkg-config
fi
echo ""

# Résumé
echo "=========================================="
echo -e "${GREEN}Tous les prérequis système sont installés !${NC}"
echo "=========================================="
echo ""
echo "Prochaines étapes:"
echo "1. Créez un environnement virtuel: python3.12 -m venv .venv"
echo "2. Activez-le: source .venv/bin/activate"
echo "3. Installez les dépendances Python"


#!/bin/bash
# Script pour corriger le problème de version LLVM avec llvmlite

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  Correction du problème LLVM/llvmlite"
echo "=========================================="
echo ""

# Vérifier la version LLVM installée
echo "1. Vérification de la version LLVM..."
if command -v llvm-config &> /dev/null; then
    LLVM_VERSION=$(llvm-config --version 2>/dev/null || echo "inconnue")
    echo "   Version LLVM détectée: $LLVM_VERSION"
    
    # Extraire le numéro de version majeur
    LLVM_MAJOR=$(echo $LLVM_VERSION | cut -d. -f1)
    
    if [ "$LLVM_MAJOR" -gt 20 ]; then
        echo -e "${YELLOW}⚠ LLVM version $LLVM_VERSION détectée${NC}"
        echo "   llvmlite 0.46.0 supporte officiellement LLVM 20"
        echo ""
        echo "Options:"
        echo "  A) Installer LLVM 20 (recommandé)"
        echo "  B) Essayer d'installer llvmlite avec les binaires précompilés (plus simple)"
        echo ""
        read -p "Choisissez une option (A/B) [B]: " choice
        choice=${choice:-B}
        
        if [ "$choice" = "A" ] || [ "$choice" = "a" ]; then
            echo ""
            echo "2. Installation de LLVM 20..."
            echo "   Désinstallation de LLVM actuel (si installé via Homebrew)..."
            brew uninstall llvm 2>/dev/null || echo "   LLVM non installé via Homebrew"
            
            echo "   Installation de LLVM 20..."
            brew install llvm@20
            
            echo ""
            echo "3. Configuration du PATH pour LLVM 20..."
            echo 'export PATH="/opt/homebrew/opt/llvm@20/bin:$PATH"' >> ~/.zshrc
            echo 'export LDFLAGS="-L/opt/homebrew/opt/llvm@20/lib"' >> ~/.zshrc
            echo 'export CPPFLAGS="-I/opt/homebrew/opt/llvm@20/include"' >> ~/.zshrc
            
            echo -e "${GREEN}✓ LLVM 20 installé${NC}"
            echo ""
            echo "⚠️  Rechargez votre shell ou exécutez:"
            echo "   source ~/.zshrc"
            echo ""
            echo "Puis réessayez l'installation de llvmlite"
        else
            echo ""
            echo "2. Installation de llvmlite avec binaires précompilés..."
            echo "   Cette méthode évite la compilation et devrait fonctionner"
            
            if [ -z "$VIRTUAL_ENV" ]; then
                echo -e "${YELLOW}⚠ Environnement virtuel non activé${NC}"
                if [ -d ".venv" ]; then
                    source .venv/bin/activate
                else
                    echo -e "${RED}✗ Environnement virtuel non trouvé${NC}"
                    exit 1
                fi
            fi
            
            # S'assurer que pip est disponible
            if ! command -v pip &> /dev/null; then
                python -m ensurepip --upgrade || curl -sS https://bootstrap.pypa.io/get-pip.py | python
            fi
            
            # Installer avec binaires précompilés
            pip install --only-binary :all: llvmlite || {
                echo -e "${YELLOW}⚠ Échec avec --only-binary, tentative normale...${NC}"
                pip install llvmlite
            }
            
            # Vérifier
            python -c "import llvmlite; print('✓ llvmlite installé avec succès')" && \
                echo -e "${GREEN}✓ llvmlite fonctionne correctement${NC}" || \
                echo -e "${RED}✗ llvmlite ne fonctionne toujours pas${NC}"
        fi
    else
        echo -e "${GREEN}✓ Version LLVM compatible (<= 20)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ llvm-config non trouvé${NC}"
    echo "   LLVM peut ne pas être installé ou pas dans le PATH"
    echo ""
    echo "   Essayons d'installer llvmlite avec les binaires précompilés..."
    
    if [ -z "$VIRTUAL_ENV" ]; then
        if [ -d ".venv" ]; then
            source .venv/bin/activate
        else
            echo -e "${RED}✗ Environnement virtuel non trouvé${NC}"
            exit 1
        fi
    fi
    
    if ! command -v pip &> /dev/null; then
        python -m ensurepip --upgrade || curl -sS https://bootstrap.pypa.io/get-pip.py | python
    fi
    
    pip install --only-binary :all: llvmlite || pip install llvmlite
    
    python -c "import llvmlite; print('✓ llvmlite installé')" && \
        echo -e "${GREEN}✓ llvmlite fonctionne${NC}" || \
        echo -e "${RED}✗ Problème avec llvmlite${NC}"
fi

echo ""
echo "=========================================="
echo "  Correction terminée"
echo "=========================================="


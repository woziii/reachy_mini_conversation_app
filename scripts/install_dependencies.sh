#!/bin/bash
# Script pour installer les dépendances dans l'ordre correct pour Mac M2

# Ne pas s'arrêter en cas d'erreur pour permettre les alternatives
set +e

echo "=========================================="
echo "  Installation des dépendances Python"
echo "  (Ordre optimisé pour Mac M2)"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Vérifier que l'environnement virtuel est activé
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${RED}✗ Environnement virtuel non activé${NC}"
    echo "Activez-le d'abord avec: source .venv/bin/activate"
    exit 1
fi

echo -e "${GREEN}✓ Environnement virtuel activé: $VIRTUAL_ENV${NC}"
echo ""

# Vérifier si uv est disponible
USE_UV=false
if command -v uv &> /dev/null; then
    USE_UV=true
    echo -e "${GREEN}✓ Utilisation de uv (recommandé)${NC}"
else
    echo "Utilisation de pip"
fi
echo ""

# Étape 1: Installer llvmlite (peut être problématique sur Mac M2)
echo "Étape 1: Installation de llvmlite..."
echo "   Note: Utilisation des binaires précompilés pour éviter les problèmes de compilation"

# Vérifier si pip est disponible, sinon l'installer
if ! command -v pip &> /dev/null && ! python -m pip --version &> /dev/null; then
    echo "   Installation de pip dans l'environnement virtuel..."
    python -m ensurepip --upgrade || {
        echo "   Téléchargement de get-pip.py..."
        curl -sS https://bootstrap.pypa.io/get-pip.py | python
    }
    # Ajouter pip au PATH
    export PATH="$VIRTUAL_ENV/bin:$PATH"
fi

# Vérifier la version actuelle de llvmlite
CURRENT_LLVM=$(python -c "import llvmlite; print(llvmlite.__version__)" 2>/dev/null || echo "none")
echo "   Version actuelle de llvmlite: $CURRENT_LLVM"

# numba accepte llvmlite<0.46,>=0.45.0dev0, donc 0.45.1 est suffisant
# Essayer d'installer avec binaires précompilés pour éviter la compilation
if [ "$CURRENT_LLVM" = "none" ] || [ "$CURRENT_LLVM" \< "0.45.0" ]; then
    echo "   Installation de llvmlite avec binaires précompilés..."
    python -m pip install --only-binary :all: "llvmlite>=0.45.0" || {
        echo -e "${YELLOW}⚠ Échec avec --only-binary, tentative avec upgrade...${NC}"
        python -m pip install --upgrade --only-binary :all: llvmlite || {
            echo -e "${YELLOW}⚠ Échec avec upgrade, tentative installation normale...${NC}"
            python -m pip install --upgrade llvmlite || {
                echo -e "${RED}✗ Échec d'installation de llvmlite${NC}"
                echo "Essayez: ./scripts/fix_llvm.sh"
                exit 1
            }
        }
    }
else
    echo "   llvmlite $CURRENT_LLVM déjà installé (compatible avec numba)"
fi

# Vérifier la version installée
INSTALLED_LLVM=$(python -c "import llvmlite; print(llvmlite.__version__)" 2>/dev/null || echo "none")
echo "   Version installée: $INSTALLED_LLVM"

# Vérifier l'import
python -c "import llvmlite; print('✓ llvmlite importé avec succès')" 2>/dev/null && \
    echo -e "${GREEN}✓ llvmlite installé et fonctionnel${NC}" || {
    echo -e "${RED}✗ llvmlite installé mais import échoué${NC}"
    echo "   Vérification de la version LLVM installée..."
    if command -v llvm-config &> /dev/null; then
        LLVM_VERSION=$(llvm-config --version 2>/dev/null || echo "inconnue")
        echo "   LLVM version détectée: $LLVM_VERSION"
        echo "   llvmlite 0.45.x supporte LLVM 20"
        echo "   Si vous avez LLVM 21, essayez:"
        echo "     ./scripts/fix_llvm.sh"
    fi
    exit 1
}
echo ""

# Étape 2: Installer fastRTC (dépend de CMake)
echo "Étape 2: Installation de fastRTC..."
# S'assurer que pip est disponible et dans le PATH
if ! command -v pip &> /dev/null && ! python -m pip --version &> /dev/null; then
    python -m ensurepip --upgrade || curl -sS https://bootstrap.pypa.io/get-pip.py | python
    export PATH="$VIRTUAL_ENV/bin:$PATH"
fi

# Installer setuptools (nécessaire pour certaines constructions)
echo "   Vérification de setuptools..."
python -c "import setuptools" 2>/dev/null || {
    echo "   Installation de setuptools..."
    python -m pip install setuptools
}

# Installer numba d'abord avec llvmlite déjà satisfait
# Cela évite que pip essaie de reconstruire llvmlite
echo "   Installation de numba (dépendance de fastRTC qui nécessite llvmlite)..."
python -m pip install --only-binary :all: "numba>=0.60.0" 2>/dev/null || {
    echo -e "${YELLOW}⚠ Binaires non disponibles pour numba, installation normale...${NC}"
    python -m pip install "numba>=0.60.0" || {
        echo -e "${YELLOW}⚠ Numba installation échouée, continuons...${NC}"
    }
}

# Installer fastRTC maintenant que numba (et donc llvmlite) est satisfait
echo "   Installation de fastRTC..."
# Utiliser --no-build-isolation pour éviter que pip reconstruise llvmlite dans un environnement isolé
# Cette approche a été testée et fonctionne (voir install_fastrtc_workaround.sh)
python -m pip install --no-build-isolation "fastrtc>=0.0.34" && {
    echo -e "${GREEN}✓ fastRTC installé avec succès${NC}"
} || {
    echo -e "${YELLOW}⚠ Avec --no-build-isolation échoué, tentative normale...${NC}"
    python -m pip install "fastrtc>=0.0.34" || {
        echo -e "${RED}✗ fastRTC installation échouée${NC}"
        echo ""
        echo "Le problème vient probablement de llvmlite qui essaie de se recompiler."
        echo "Solutions:"
        echo "1. Utilisez le script de contournement: ./scripts/install_fastrtc_workaround.sh"
        echo "2. Ou manuellement: python -m pip install fastrtc --no-build-isolation"
        echo "3. Vérifiez que llvmlite est installé: python -c 'import llvmlite; print(llvmlite.__version__)'"
        exit 1
    }
}

# Vérifier l'import
python -c "import fastrtc; print('✓ fastrtc importé avec succès')" 2>/dev/null && \
    echo -e "${GREEN}✓ fastRTC installé et fonctionnel${NC}" || {
    echo -e "${RED}✗ fastRTC installation échouée${NC}"
    echo "Vérifiez que CMake est installé: brew install cmake"
    echo "Ou essayez manuellement: python -m pip install fastrtc"
    exit 1
}
echo ""

# Étape 3: Installer toutes les autres dépendances
echo "Étape 3: Installation des autres dépendances..."
# Utiliser pip pour éviter que uv reconstruise llvmlite
# pip respectera les packages déjà installés
echo "   Utilisation de pip pour respecter llvmlite déjà installé..."
python -m pip install -e . || {
    echo -e "${YELLOW}⚠ pip install -e . a échoué${NC}"
    if [ "$USE_UV" = true ]; then
        echo "   Tentative avec uv sync (peut reconstruire llvmlite)..."
        uv sync || {
            echo -e "${RED}✗ Échec de l'installation des dépendances${NC}"
            exit 1
        }
    else
        echo -e "${RED}✗ Échec de l'installation des dépendances${NC}"
        exit 1
    fi
}
echo ""

# Vérifier les imports critiques
echo "Vérification des imports critiques..."
python -c "
import sys
errors = []

try:
    import fastrtc
    print('✓ fastrtc')
except ImportError as e:
    errors.append(f'fastrtc: {e}')

try:
    import llvmlite
    print('✓ llvmlite')
except ImportError as e:
    errors.append(f'llvmlite: {e}')

try:
    import reachy_mini
    print('✓ reachy_mini')
except ImportError as e:
    errors.append(f'reachy_mini: {e}')

try:
    import gradio
    print('✓ gradio')
except ImportError as e:
    errors.append(f'gradio: {e}')

try:
    import openai
    print('✓ openai')
except ImportError as e:
    errors.append(f'openai: {e}')

if errors:
    print('\nErreurs:')
    for err in errors:
        print(f'  ✗ {err}')
    sys.exit(1)
else:
    print('\n✓ Tous les imports critiques réussis')
" && echo -e "${GREEN}✓ Toutes les dépendances critiques sont fonctionnelles${NC}" || {
    echo -e "${RED}✗ Certaines dépendances ont des problèmes${NC}"
    echo ""
    echo "Si llvmlite a échoué à cause de LLVM 21, essayez:"
    echo "  ./scripts/fix_llvm.sh"
    echo ""
    echo "Ou manuellement:"
    echo "  pip install --only-binary :all: llvmlite"
    exit 1
}

echo ""
echo "=========================================="
echo -e "${GREEN}Installation terminée avec succès !${NC}"
echo "=========================================="
echo ""
echo "Vous pouvez maintenant:"
echo "1. Vérifier la configuration: python scripts/check_setup.py"
echo "2. Lancer l'app: reachy-mini-conversation-app --gradio"


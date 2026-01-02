#!/bin/bash
# Script de contournement pour installer fastRTC quand llvmlite pose problème

set +e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "  Contournement installation fastRTC"
echo "=========================================="
echo ""

if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${RED}✗ Environnement virtuel non activé${NC}"
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    else
        echo "Créez l'environnement d'abord: ./scripts/setup_venv.sh"
        exit 1
    fi
fi

# Vérifier llvmlite
echo "1. Vérification de llvmlite..."
LLVM_VERSION=$(python -c "import llvmlite; print(llvmlite.__version__)" 2>/dev/null || echo "none")
if [ "$LLVM_VERSION" = "none" ]; then
    echo -e "${RED}✗ llvmlite n'est pas installé${NC}"
    echo "Installez-le d'abord: python -m pip install --only-binary :all: 'llvmlite>=0.46.0'"
    exit 1
fi
echo -e "${GREEN}✓ llvmlite $LLVM_VERSION installé${NC}"
echo ""

# Installer setuptools si nécessaire
echo "2. Vérification de setuptools..."
python -c "import setuptools" 2>/dev/null || {
    echo "   Installation de setuptools..."
    python -m pip install setuptools
}
echo ""

# Installer numba d'abord
echo "3. Installation de numba..."
python -m pip install --only-binary :all: "numba>=0.60.0" 2>/dev/null || {
    echo "   Installation normale de numba..."
    python -m pip install "numba>=0.60.0"
}
echo ""

# Installer fastRTC avec --no-build-isolation
echo "4. Installation de fastRTC avec --no-build-isolation..."
python -m pip install --no-build-isolation "fastrtc>=0.0.34" && {
    echo -e "${GREEN}✓ fastRTC installé avec succès${NC}"
    exit 0
}

# Si échec, essayer sans --no-build-isolation mais avec constraint
echo "5. Tentative alternative..."
python -m pip install "fastrtc>=0.0.34" --constraint <(echo "llvmlite==$LLVM_VERSION") && {
    echo -e "${GREEN}✓ fastRTC installé avec succès${NC}"
    exit 0
}

echo -e "${RED}✗ Échec d'installation de fastRTC${NC}"
echo ""
echo "Essayez manuellement:"
echo "  python -m pip install fastrtc --no-build-isolation"
exit 1



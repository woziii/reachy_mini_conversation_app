# Guide d'installation détaillé pour Mac M2 (Apple Silicon)

Ce guide détaille l'installation et la configuration de l'application Reachy Mini Conversation App sur MacBook M2 (Apple Silicon), avec un focus particulier sur la résolution des problèmes courants avec fastRTC, CMake et llvmlite.

## Table des matières

1. [Prérequis système](#prérequis-système)
2. [Installation des dépendances](#installation-des-dépendances)
3. [Problèmes courants et solutions](#problèmes-courants-et-solutions)
4. [Historique des problèmes rencontrés](#historique-des-problèmes-rencontrés)

## Prérequis système

### 1. Vérifier l'architecture

Sur Mac M2, vous devez avoir l'architecture ARM64 :

```bash
uname -m
# Doit afficher: arm64
```

### 2. Installer Homebrew

Homebrew est le gestionnaire de paquets pour macOS. Il est essentiel pour installer CMake et autres dépendances système.

```bash
# Vérifier si Homebrew est installé
brew --version

# Si non installé, installer avec:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Pour Apple Silicon, ajouter au PATH:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 3. Installer CMake

CMake est **requis** pour compiler fastRTC :

```bash
brew install cmake

# Vérifier l'installation
cmake --version
```

### 4. Installer Xcode Command Line Tools

Les outils de compilation sont nécessaires pour certaines dépendances :

```bash
xcode-select --install

# Vérifier l'installation
xcode-select -p
```

### 5. Installer pkg-config

Souvent nécessaire pour fastRTC :

```bash
brew install pkg-config
```

## Installation des dépendances

### Ordre d'installation critique

Sur Mac M2, l'ordre d'installation est **crucial** pour éviter les conflits :

1. **llvmlite** (en premier)
2. **fastRTC** (ensuite, dépend de CMake)
3. **Reste des dépendances** (en dernier)

### Méthode recommandée : Scripts automatiques

Utilisez les scripts fournis qui gèrent l'ordre automatiquement :

```bash
# 1. Prérequis système
./scripts/setup_mac_m2.sh

# 2. Environnement virtuel
./scripts/setup_venv.sh

# 3. Dépendances (ordre correct géré automatiquement)
./scripts/install_dependencies.sh
```

### Méthode manuelle

Si vous préférez installer manuellement :

```bash
# Activer l'environnement virtuel
source .venv/bin/activate

# 1. Installer llvmlite
pip install llvmlite

# Vérifier
python -c "import llvmlite; print('OK')"

# 2. Installer fastRTC
pip install "fastrtc>=0.0.34"

# Vérifier
python -c "import fastrtc; print('OK')"

# 3. Installer le reste
pip install -e .
```

## Problèmes courants et solutions

### Problème 1 : fastRTC - Erreur de compilation

**Symptômes** :
```
error: failed to build fastrtc
CMake Error: ...
```

**Causes possibles** :
- CMake non installé ou version trop ancienne
- pkg-config manquant
- Bibliothèques système manquantes

**Solutions** :

1. **Vérifier CMake** :
```bash
cmake --version
# Doit être >= 3.10

# Si absent ou version trop ancienne:
brew install cmake
```

2. **Vérifier pkg-config** :
```bash
pkg-config --version

# Si absent:
brew install pkg-config
```

3. **Réinstaller fastRTC** :
```bash
pip uninstall fastrtc
pip install --no-cache-dir fastrtc
```

4. **Si le problème persiste, installer les dépendances système** :
```bash
brew install openssl libffi
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"
pip install --no-cache-dir fastrtc
```

### Problème 2 : llvmlite - Erreur de compilation LLVM version

**Symptômes** :
```
CMake Error: LLVM CMake export states LLVM version is 21, llvmlite only officially supports 20.
```

**Causes possibles** :
- LLVM version 21 installée alors que llvmlite 0.46.0 supporte seulement LLVM 20
- Tentative de compilation depuis les sources au lieu d'utiliser les binaires précompilés

**Solutions** :

1. **Solution recommandée : Utiliser les binaires précompilés** (évite la compilation) :
```bash
# S'assurer que pip est disponible
python -m ensurepip --upgrade

# Installer avec binaires précompilés uniquement
pip install --only-binary :all: llvmlite
```

2. **Si la solution 1 échoue, installer LLVM 20** :
```bash
# Désinstaller LLVM actuel
brew uninstall llvm

# Installer LLVM 20
brew install llvm@20

# Configurer le PATH
export PATH="/opt/homebrew/opt/llvm@20/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm@20/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm@20/include"

# Ajouter au ~/.zshrc pour persistance
echo 'export PATH="/opt/homebrew/opt/llvm@20/bin:$PATH"' >> ~/.zshrc
echo 'export LDFLAGS="-L/opt/homebrew/opt/llvm@20/lib"' >> ~/.zshrc
echo 'export CPPFLAGS="-I/opt/homebrew/opt/llvm@20/include"' >> ~/.zshrc

# Recharger le shell
source ~/.zshrc

# Réinstaller llvmlite
pip install llvmlite
```

3. **Utiliser le script de correction automatique** :
```bash
./scripts/fix_llvm.sh
```

4. **Vérifier la version LLVM installée** :
```bash
llvm-config --version
# Si > 20, utilisez la solution 1 ou 2
```

### Problème 2b : llvmlite - Import error

**Symptômes** :
```
ImportError: cannot import name '_llvm' from 'llvmlite'
```

**Causes possibles** :
- Binaires ARM64 non disponibles
- Conflit avec une installation précédente
- Version incompatible

**Solutions** :

1. **Réinstaller llvmlite avec binaires** :
```bash
pip uninstall llvmlite
pip install --only-binary :all: llvmlite
```

2. **Vérifier la version Python** :
```bash
python --version
# Doit être 3.10, 3.11, 3.12 ou 3.13
```

3. **Installer une version spécifique** :
```bash
pip install --only-binary :all: llvmlite==0.46.0
```

4. **Si le problème persiste, vérifier l'architecture** :
```bash
python -c "import platform; print(platform.machine())"
# Doit afficher: arm64
```

### Problème 3 : CMake - Command not found

**Symptômes** :
```
CMake Error: The source directory does not exist
sh: cmake: command not found
```

**Solutions** :

1. **Installer CMake via Homebrew** :
```bash
brew install cmake
```

2. **Vérifier le PATH** :
```bash
which cmake
# Doit afficher: /opt/homebrew/bin/cmake (Apple Silicon)
# ou: /usr/local/bin/cmake (Intel)
```

3. **Ajouter au PATH si nécessaire** :
```bash
export PATH="/opt/homebrew/bin:$PATH"
```

### Problème 3b : pip non trouvé dans l'environnement virtuel

**Symptômes** :
```
pip: command not found
```

**Causes possibles** :
- pip n'est pas installé dans l'environnement virtuel
- Environnement virtuel créé sans pip

**Solutions** :

1. **Installer pip dans l'environnement virtuel** :
```bash
python -m ensurepip --upgrade
```

2. **Si ensurepip échoue, utiliser get-pip.py** :
```bash
curl -sS https://bootstrap.pypa.io/get-pip.py | python
```

3. **Vérifier l'installation** :
```bash
pip --version
```

### Problème 4 : Conflits de dépendances

**Symptômes** :
```
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed
```

**Solutions** :

1. **Créer un environnement virtuel propre** :
```bash
# Supprimer l'ancien
rm -rf .venv

# Créer un nouveau
python3.12 -m venv .venv
source .venv/bin/activate
```

2. **Utiliser uv (plus rapide et meilleure résolution)** :
```bash
# Installer uv
pip install uv

# Créer l'environnement
uv venv --python 3.12.1

# Installer les dépendances
uv sync
```

### Problème 5 : Python version incorrecte

**Symptômes** :
```
ERROR: This package requires Python >=3.10
```

**Solutions** :

1. **Vérifier la version Python** :
```bash
python --version
python3 --version
```

2. **Installer Python 3.12.1** :
```bash
brew install python@3.12
```

3. **Créer l'environnement virtuel avec la bonne version** :
```bash
python3.12 -m venv .venv
source .venv/bin/activate
```

## Historique des problèmes rencontrés

### Problème : llvmlite avec LLVM 21

**Date** : 2025-01-XX  
**Système** : MacBook M2, Apple Silicon  
**Problème** : llvmlite 0.46.0 ne peut pas être compilé car LLVM 21.1.8 est installé alors que llvmlite supporte seulement LLVM 20

**Erreur** :
```
CMake Error: LLVM CMake export states LLVM version is 21, llvmlite only officially supports 20.
```

**Solutions appliquées** :
1. Utilisation de `--only-binary :all:` pour forcer l'utilisation des binaires précompilés (évite la compilation)
2. Installation de pip dans l'environnement virtuel si manquant
3. Création du script `fix_llvm.sh` pour automatiser la correction
4. Mise à jour de `install_dependencies.sh` pour gérer ce cas automatiquement

**Résultat** : ✅ Installation réussie avec binaires précompilés

### Problème initial : fastRTC, CMake et llvmlite

**Date** : 2025-01-XX  
**Système** : MacBook M2, Apple Silicon  
**Problème** : Échec d'installation de fastRTC, CMake et llvmlite dans l'environnement virtuel

**Causes identifiées** :
1. CMake non installé ou non dans le PATH
2. Ordre d'installation incorrect des dépendances
3. Environnement virtuel avec conflits d'installations précédentes
4. pkg-config manquant

**Solutions appliquées** :
1. Installation de CMake via Homebrew : `brew install cmake`
2. Installation de pkg-config : `brew install pkg-config`
3. Création d'un environnement virtuel propre
4. Installation dans l'ordre : llvmlite → fastRTC → reste
5. Utilisation de scripts automatisés pour garantir l'ordre correct

**Résultat** : ✅ Installation réussie avec environnement virtuel propre et ordre d'installation correct

### Leçons apprises

1. **Toujours créer un environnement virtuel propre** pour éviter les conflits
2. **Respecter l'ordre d'installation** est crucial sur Mac M2
3. **Vérifier les prérequis système** (CMake, pkg-config) avant d'installer les dépendances Python
4. **Utiliser les scripts automatisés** réduit les erreurs

## Commandes de diagnostic

### Vérifier l'environnement complet

```bash
python scripts/check_setup.py
```

### Vérifier les imports critiques

```bash
python -c "
import fastrtc
import llvmlite
import reachy_mini
import gradio
import openai
print('✅ Tous les imports réussis')
"
```

### Vérifier les versions

```bash
python -c "
import sys
print(f'Python: {sys.version}')
import platform
print(f'Architecture: {platform.machine()}')
print(f'Système: {platform.system()} {platform.release()}')
"
```

### Vérifier CMake

```bash
cmake --version
which cmake
```

## Configuration optimale

### Variables d'environnement recommandées

Ajoutez ces variables à votre `~/.zshrc` ou `~/.bash_profile` :

```bash
# Homebrew pour Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# pkg-config path
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"

# Python path (si nécessaire)
export PATH="/opt/homebrew/opt/python@3.12/bin:$PATH"
```

### Configuration Python

Utilisez Python 3.12.1 pour la meilleure compatibilité :

```bash
# Installer Python 3.12.1
brew install python@3.12

# Vérifier
python3.12 --version
```

## Ressources supplémentaires

- [Documentation Homebrew](https://docs.brew.sh/)
- [Documentation CMake](https://cmake.org/documentation/)
- [Documentation llvmlite](https://llvmlite.readthedocs.io/)
- [Documentation fastRTC](https://github.com/pollen-robotics/fastrtc)

## Support

Si vous rencontrez des problèmes non couverts dans ce guide :

1. Exécutez le diagnostic : `python scripts/check_setup.py`
2. Consultez les logs : `tail -f daemon.log`
3. Vérifiez les issues GitHub du projet
4. Contactez le support Pollen Robotics


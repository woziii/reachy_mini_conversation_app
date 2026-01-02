# Guide de démarrage rapide - Reachy Mini Conversation App

Ce guide vous permettra de configurer et lancer l'application de conversation Reachy Mini sur votre Mac M2 (Apple Silicon) en quelques étapes.

## Prérequis

- MacBook avec processeur Apple Silicon (M1, M2, M3, etc.)
- Python 3.12.1 (recommandé) ou Python 3.10+
- Robot Reachy Mini Lite connecté par câble USB
- Clé API OpenAI

## Installation rapide

### Étape 1 : Prérequis système

Exécutez le script d'installation des prérequis :

```bash
./scripts/setup_mac_m2.sh
```

Ce script installe automatiquement :
- Homebrew (si nécessaire)
- CMake (requis pour fastRTC)
- Xcode Command Line Tools
- pkg-config (souvent nécessaire)

### Étape 2 : Créer l'environnement virtuel

Créez un environnement virtuel propre avec Python 3.12.1 :

```bash
./scripts/setup_venv.sh
```

Ce script :
- Crée un nouvel environnement virtuel `.venv`
- L'active automatiquement
- Utilise `uv` si disponible (plus rapide) ou `venv` standard

### Étape 3 : Installer les dépendances

Installez toutes les dépendances Python dans l'ordre correct :

```bash
./scripts/install_dependencies.sh
```

Ce script installe les dépendances dans l'ordre optimal pour Mac M2 :
1. `llvmlite` (peut être problématique, installé en premier)
2. `fastRTC` (dépend de CMake)
3. Toutes les autres dépendances du projet

### Étape 4 : Configurer la clé API OpenAI

Créez le fichier `.env` avec votre clé API :

```bash
# Option 1 : Utiliser le script automatique
python3 scripts/create_env.py

# Option 2 : Créer manuellement
cat > .env << EOF
OPENAI_API_KEY=votre_clé_api_ici
EOF
```

**Important** : Remplacez `votre_clé_api_ici` par votre vraie clé API OpenAI.

### Étape 5 : Vérifier la configuration

Vérifiez que tout est correctement configuré :

```bash
python scripts/check_setup.py
```

Ce script vérifie :
- ✅ Version de Python
- ✅ Architecture système (ARM64)
- ✅ Prérequis système (Homebrew, CMake, etc.)
- ✅ Environnement virtuel
- ✅ Packages Python critiques
- ✅ Fichier .env avec clé API
- ✅ SDK Reachy Mini

### Étape 6 : Lancer le démon Reachy Mini

Le démon doit être lancé **avant** l'application de conversation :

```bash
./scripts/start_daemon.sh
```

Le démon :
- Détecte automatiquement le port série USB
- S'exécute en arrière-plan
- Écrit les logs dans `daemon.log`

### Étape 7 : Tester la connexion (optionnel)

Vérifiez que l'application peut se connecter au robot :

```bash
python scripts/test_connection.py
```

### Étape 8 : Lancer l'application

Lancez l'application de conversation avec l'interface web :

```bash
./scripts/start_app.sh
```

Ou manuellement :

```bash
source .venv/bin/activate
reachy-mini-conversation-app --gradio
```

L'interface web sera disponible sur : **http://127.0.0.1:7860/**

## Utilisation

1. **Ouvrez votre navigateur** et allez sur `http://127.0.0.1:7860/`
2. **Autorisez l'accès au microphone** quand le navigateur le demande
3. **Commencez à parler** avec le robot !

## Commandes utiles

### Arrêter le démon

```bash
pkill -f reachy-mini-daemon
```

### Voir les logs du démon

```bash
tail -f daemon.log
```

### Réactiver l'environnement virtuel

```bash
source .venv/bin/activate
```

## Dépannage rapide

### Problème : "fastRTC installation failed"

**Solution** :
1. Vérifiez que CMake est installé : `brew install cmake`
2. Vérifiez que pkg-config est installé : `brew install pkg-config`
3. Réinstallez fastRTC : `pip install --force-reinstall fastrtc`

### Problème : "llvmlite - LLVM version 21 not supported"

**Solution** :
1. Utilisez les binaires précompilés : `pip install --only-binary :all: llvmlite`
2. Ou utilisez le script de correction : `./scripts/fix_llvm.sh`
3. Si le problème persiste, consultez `docs/SETUP_MAC_M2.md`

### Problème : "pip: command not found"

**Solution** :
1. Installez pip dans l'environnement virtuel : `python -m ensurepip --upgrade`
2. Si ça échoue : `curl -sS https://bootstrap.pypa.io/get-pip.py | python`

### Problème : "Timeout while waiting for connection"

**Solution** :
1. Vérifiez que le démon est lancé : `pgrep -f reachy-mini-daemon`
2. Vérifiez que le robot est connecté par USB
3. Relancez le démon : `./scripts/start_daemon.sh`

### Problème : "OPENAI_API_KEY not found"

**Solution** :
1. Vérifiez que le fichier `.env` existe
2. Vérifiez que la clé commence par `sk-`
3. Vous pouvez aussi saisir la clé dans l'interface Gradio

## Section spécifique Mac M2

### Architecture Apple Silicon

Sur Mac M2, certaines dépendances nécessitent une attention particulière :

- **fastRTC** : Nécessite CMake et des bibliothèques système
- **llvmlite** : Les binaires ARM64 sont généralement disponibles via pip
- **Python** : Utilisez Python 3.12.1 pour la meilleure compatibilité

### Ordre d'installation important

L'ordre d'installation des dépendances est crucial sur Mac M2 :

1. **llvmlite** en premier (peut être problématique)
2. **fastRTC** ensuite (dépend de CMake)
3. **Reste des dépendances** en dernier

Le script `install_dependencies.sh` gère cet ordre automatiquement.

### Environnement virtuel propre

Il est **fortement recommandé** de créer un nouvel environnement virtuel pour éviter les conflits avec des installations précédentes :

```bash
# Supprimer l'ancien environnement
rm -rf .venv

# Créer un nouvel environnement
./scripts/setup_venv.sh
```

## Prochaines étapes

Une fois que l'application fonctionne :

1. **Explorez les profils** : L'interface Gradio permet de changer de personnalité
2. **Testez les outils** : Camera, dance, head tracking, etc.
3. **Personnalisez** : Créez vos propres profils et outils

## Documentation complète

Pour plus de détails, consultez :
- `docs/SETUP_MAC_M2.md` : Guide détaillé pour Mac M2
- `README.md` : Documentation complète du projet
- `scripts/check_setup.py` : Diagnostic complet de l'environnement

## Support

Si vous rencontrez des problèmes :

1. Exécutez le diagnostic : `python scripts/check_setup.py`
2. Consultez `docs/SETUP_MAC_M2.md` pour les problèmes spécifiques Mac M2
3. Vérifiez les logs du démon : `tail -f daemon.log`


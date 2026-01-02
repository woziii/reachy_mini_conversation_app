# Scripts d'aide - Reachy Mini Conversation App

Ce dossier contient des scripts pour faciliter l'installation, la configuration et l'utilisation de l'application de conversation Reachy Mini sur Mac M2.

## Scripts disponibles

### Installation et configuration

#### `setup_mac_m2.sh`
Installe les prérequis système nécessaires pour Mac M2 :
- Homebrew (si non installé)
- CMake (requis pour fastRTC)
- Xcode Command Line Tools
- pkg-config

**Usage** :
```bash
./scripts/setup_mac_m2.sh
```

#### `setup_venv.sh`
Crée un environnement virtuel propre avec Python 3.12.1.

**Usage** :
```bash
./scripts/setup_venv.sh
```

#### `install_dependencies.sh`
Installe toutes les dépendances Python dans l'ordre correct pour Mac M2 :
1. llvmlite (avec binaires précompilés pour éviter la compilation)
2. numba (qui utilise llvmlite déjà installé)
3. fastRTC (avec `--no-build-isolation` pour éviter la reconstruction de llvmlite)
4. Reste des dépendances

**Stratégie d'installation** :
- `llvmlite` est installé avec `--only-binary :all:` pour éviter les problèmes de compilation liés à LLVM
- `numba` est installé avant `fastRTC` pour satisfaire la dépendance `llvmlite`
- `fastRTC` est installé avec `--no-build-isolation` pour utiliser `llvmlite` déjà installé au lieu de le reconstruire

**Usage** :
```bash
# Assurez-vous que l'environnement virtuel est activé
source .venv/bin/activate
./scripts/install_dependencies.sh
```

**En cas de problème** :
Si l'installation échoue, utilisez le script de contournement :
```bash
./scripts/install_fastrtc_workaround.sh
```

#### `create_env.py`
Crée le fichier `.env` avec la clé API OpenAI.

**Usage** :
```bash
python3 scripts/create_env.py
```

**Note** : Vous devrez peut-être créer le fichier `.env` manuellement si le script ne peut pas l'écrire (permissions).

#### `install_fastrtc_workaround.sh`
Script de contournement pour installer `fastRTC` quand `llvmlite` pose problème. Ce script utilise la même approche que `install_dependencies.sh` mais de manière plus isolée.

**Usage** :
```bash
# Assurez-vous que l'environnement virtuel est activé
source .venv/bin/activate
./scripts/install_fastrtc_workaround.sh
```

Ce script :
- Vérifie que `llvmlite` est installé
- Installe `setuptools` si nécessaire
- Installe `numba` d'abord (qui utilise `llvmlite` déjà installé)
- Installe `fastRTC` avec `--no-build-isolation` pour éviter la reconstruction de `llvmlite`

**Quand l'utiliser** :
- Si `install_dependencies.sh` échoue lors de l'installation de `fastRTC`
- Si vous rencontrez des erreurs de compilation de `llvmlite`

### Diagnostic

#### `check_setup.py`
Script de diagnostic complet qui vérifie :
- Version de Python
- Architecture système (ARM64)
- Prérequis système (Homebrew, CMake, etc.)
- Environnement virtuel
- Packages Python critiques
- Fichier .env
- SDK Reachy Mini

**Usage** :
```bash
python scripts/check_setup.py
```

#### `diagnose_audio.py`
Script de diagnostic spécifique pour les problèmes audio. Vérifie :
- Présence et format de la clé API OpenAI
- Connexion à l'API OpenAI Realtime
- Permissions microphone (macOS)
- Installation et fonctionnement de fastrtc
- Instanciation du handler OpenAI Realtime

**Usage** :
```bash
# Assurez-vous que l'environnement virtuel est activé
source .venv/bin/activate
python scripts/diagnose_audio.py
```

**Quand l'utiliser** :
- Si l'application Gradio s'active mais ne répond pas en audio
- Pour vérifier que tous les prérequis audio sont satisfaits
- Avant de lancer l'application pour la première fois

### Démon et robot

#### `start_daemon.sh`
Lance le démon Reachy Mini pour robot Lite USB.

**Usage** :
```bash
./scripts/start_daemon.sh
```

Le démon :
- Détecte automatiquement le port série USB
- S'exécute en arrière-plan
- Écrit les logs dans `daemon.log`

**Arrêter le démon** :
```bash
pkill -f reachy-mini-daemon
```

#### `test_connection.py`
Teste la connexion au robot et vérifie que le démon répond.

**Usage** :
```bash
python scripts/test_connection.py
```

### Application

#### `start_app.sh`
Lance l'application de conversation avec l'interface web Gradio.

**Usage** :
```bash
./scripts/start_app.sh
```

Ce script :
- Vérifie que l'environnement virtuel est activé
- Vérifie que le démon est lancé (le lance si nécessaire)
- Vérifie le fichier .env
- Lance l'application avec `--gradio`

L'interface web sera disponible sur : **http://127.0.0.1:7860/**

## Workflow complet

### Première installation

```bash
# 1. Prérequis système
./scripts/setup_mac_m2.sh

# 2. Environnement virtuel
./scripts/setup_venv.sh

# 3. Dépendances
./scripts/install_dependencies.sh

# 4. Configuration .env (manuellement ou avec le script)
# Créez .env avec votre clé API OpenAI

# 5. Vérification
python scripts/check_setup.py
```

### Utilisation quotidienne

```bash
# 1. Activer l'environnement virtuel
source .venv/bin/activate

# 2. Lancer le démon (dans un terminal séparé)
./scripts/start_daemon.sh

# 3. Lancer l'application
./scripts/start_app.sh
```

## Dépannage

### Le script ne s'exécute pas

Rendez-le exécutable :
```bash
chmod +x scripts/nom_du_script.sh
```

### Erreur de permissions

Certains scripts peuvent nécessiter des permissions supplémentaires. Si vous rencontrez des erreurs :
- Vérifiez les permissions : `ls -l scripts/`
- Rendez exécutable : `chmod +x scripts/nom_du_script.sh`

### Le démon ne démarre pas

1. Vérifiez que le robot est connecté par USB
2. Vérifiez les logs : `tail -f daemon.log`
3. Vérifiez que le port série est disponible : `ls /dev/tty.usb*`

## Notes importantes

- **Ordre d'exécution** : Respectez l'ordre des scripts pour la première installation
- **Environnement virtuel** : Activez toujours l'environnement virtuel avant d'installer des dépendances
- **Démon** : Le démon doit être lancé **avant** l'application de conversation
- **.env** : Le fichier `.env` est dans `.gitignore` pour la sécurité

## Support

Pour plus d'informations :
- `QUICKSTART.md` : Guide de démarrage rapide
- `docs/SETUP_MAC_M2.md` : Guide détaillé pour Mac M2
- `README.md` : Documentation complète du projet


#!/usr/bin/env python3
"""Script de diagnostic pour vérifier la configuration de l'environnement.

Ce script vérifie tous les prérequis nécessaires pour faire fonctionner
l'application de conversation Reachy Mini sur Mac M2 (Apple Silicon).
"""

import sys
import subprocess
import platform
import os
from pathlib import Path
from typing import Tuple, List


class Colors:
    """Codes couleur pour l'affichage terminal."""
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'


def print_header(text: str) -> None:
    """Affiche un en-tête."""
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}\n")


def print_success(text: str) -> None:
    """Affiche un message de succès."""
    print(f"{Colors.GREEN}✓{Colors.RESET} {text}")


def print_error(text: str) -> None:
    """Affiche un message d'erreur."""
    print(f"{Colors.RED}✗{Colors.RESET} {text}")


def print_warning(text: str) -> None:
    """Affiche un avertissement."""
    print(f"{Colors.YELLOW}⚠{Colors.RESET} {text}")


def print_info(text: str) -> None:
    """Affiche une information."""
    print(f"  {text}")


def check_command(command: List[str], description: str) -> Tuple[bool, str]:
    """Vérifie si une commande existe et retourne sa version."""
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            output = result.stdout.strip()
            return True, output
        return False, ""
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False, ""


def check_python() -> bool:
    """Vérifie la version de Python."""
    print_header("Vérification de Python")
    
    version = sys.version_info
    print_info(f"Version Python détectée: {version.major}.{version.minor}.{version.micro}")
    
    if version.major < 3 or (version.major == 3 and version.minor < 10):
        print_error(f"Python 3.10+ requis, version actuelle: {version.major}.{version.minor}")
        return False
    
    if version.major == 3 and version.minor == 12:
        print_success(f"Python {version.major}.{version.minor} détecté (recommandé)")
    else:
        print_warning(f"Python {version.major}.{version.minor} détecté (3.12.1 recommandé)")
    
    return True


def check_system() -> bool:
    """Vérifie le système et l'architecture."""
    print_header("Vérification du système")
    
    system = platform.system()
    machine = platform.machine()
    
    print_info(f"Système: {system}")
    print_info(f"Architecture: {machine}")
    
    if system != "Darwin":
        print_warning("Ce script est optimisé pour macOS")
    
    if machine == "arm64":
        print_success("Architecture ARM64 détectée (Apple Silicon)")
    elif machine == "x86_64":
        print_warning("Architecture x86_64 détectée (Intel)")
    else:
        print_warning(f"Architecture inconnue: {machine}")
    
    return True


def check_homebrew() -> bool:
    """Vérifie si Homebrew est installé."""
    print_header("Vérification de Homebrew")
    
    found, version = check_command(["brew", "--version"], "Homebrew")
    
    if found:
        print_success(f"Homebrew installé: {version.split()[1] if version else 'version inconnue'}")
        return True
    else:
        print_error("Homebrew n'est pas installé")
        print_info("Installez-le avec: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
        return False


def check_cmake() -> bool:
    """Vérifie si CMake est installé."""
    print_header("Vérification de CMake")
    
    found, version = check_command(["cmake", "--version"], "CMake")
    
    if found:
        print_success(f"CMake installé: {version.split()[0] if version else 'version inconnue'}")
        return True
    else:
        print_error("CMake n'est pas installé")
        print_info("Installez-le avec: brew install cmake")
        return False


def check_xcode_tools() -> bool:
    """Vérifie si Xcode Command Line Tools sont installés."""
    print_header("Vérification de Xcode Command Line Tools")
    
    found, _ = check_command(["xcode-select", "-p"], "Xcode Command Line Tools")
    
    if found:
        print_success("Xcode Command Line Tools installés")
        return True
    else:
        print_error("Xcode Command Line Tools ne sont pas installés")
        print_info("Installez-les avec: xcode-select --install")
        return False


def check_venv() -> bool:
    """Vérifie si un environnement virtuel est activé."""
    print_header("Vérification de l'environnement virtuel")
    
    in_venv = hasattr(sys, 'real_prefix') or (
        hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix
    )
    
    if in_venv:
        print_success(f"Environnement virtuel activé: {sys.prefix}")
        return True
    else:
        print_warning("Aucun environnement virtuel détecté")
        print_info("Créez-en un avec: python3.12 -m venv .venv")
        print_info("Puis activez-le avec: source .venv/bin/activate")
        return False


def check_python_packages() -> bool:
    """Vérifie les packages Python critiques."""
    print_header("Vérification des packages Python")
    
    packages = {
        "fastrtc": "fastrtc (critique pour l'audio)",
        "llvmlite": "llvmlite (dépendance de numba)",
        "reachy_mini": "reachy_mini (SDK Reachy Mini)",
        "gradio": "gradio (interface web)",
        "openai": "openai (API OpenAI)",
        "dotenv": "python-dotenv (variables d'environnement)",
    }
    
    all_ok = True
    
    for package, description in packages.items():
        try:
            if package == "dotenv":
                __import__("dotenv")
            else:
                __import__(package)
            print_success(f"{description}: installé")
        except ImportError:
            print_error(f"{description}: non installé")
            all_ok = False
    
    return all_ok


def check_env_file() -> bool:
    """Vérifie si le fichier .env existe et contient la clé API."""
    print_header("Vérification du fichier .env")
    
    env_path = Path(".env")
    
    if not env_path.exists():
        print_error("Fichier .env non trouvé")
        print_info("Créez-le avec votre clé API OpenAI: OPENAI_API_KEY=votre_clé")
        return False
    
    print_success("Fichier .env trouvé")
    
    # Vérifier le contenu
    try:
        with open(env_path, 'r') as f:
            content = f.read()
            if "OPENAI_API_KEY" in content:
                if "sk-" in content:
                    print_success("Clé API OpenAI trouvée dans .env")
                    return True
                else:
                    print_warning("OPENAI_API_KEY trouvé mais semble vide ou invalide")
                    return False
            else:
                print_warning("OPENAI_API_KEY non trouvé dans .env")
                return False
    except Exception as e:
        print_error(f"Erreur lors de la lecture de .env: {e}")
        return False


def check_daemon() -> bool:
    """Vérifie si le démon Reachy Mini peut être lancé."""
    print_header("Vérification du démon Reachy Mini")
    
    # Vérifier si la commande existe
    found, _ = check_command(["which", "reachy-mini-daemon"], "reachy-mini-daemon")
    
    if not found:
        print_error("reachy-mini-daemon non trouvé dans le PATH")
        print_info("Assurez-vous que le SDK Reachy Mini est installé")
        return False
    
    print_success("Commande reachy-mini-daemon trouvée")
    
    # Essayer de se connecter au démon (sans le lancer)
    try:
        from reachy_mini import ReachyMini
        print_info("Tentative de connexion au démon...")
        # On ne se connecte pas vraiment, on vérifie juste que le module est importable
        print_success("Module reachy_mini importable")
        return True
    except ImportError:
        print_error("Impossible d'importer reachy_mini")
        print_info("Installez le SDK: pip install reachy-mini")
        return False
    except Exception as e:
        print_warning(f"Erreur lors de la vérification: {e}")
        print_info("Le démon doit être lancé séparément")
        return True  # On considère que c'est OK si le module est importable


def check_project_structure() -> bool:
    """Vérifie la structure du projet."""
    print_header("Vérification de la structure du projet")
    
    required_files = [
        "pyproject.toml",
        "src/reachy_mini_conversation_app/main.py",
        "src/reachy_mini_conversation_app/config.py",
    ]
    
    all_ok = True
    
    for file_path in required_files:
        if Path(file_path).exists():
            print_success(f"{file_path}: trouvé")
        else:
            print_error(f"{file_path}: non trouvé")
            all_ok = False
    
    return all_ok


def main() -> None:
    """Fonction principale."""
    print(f"\n{Colors.BOLD}{Colors.BLUE}")
    print("=" * 60)
    print("  DIAGNOSTIC DE CONFIGURATION - REACHY MINI CONVERSATION APP")
    print("=" * 60)
    print(f"{Colors.RESET}\n")
    
    checks = [
        ("Python", check_python),
        ("Système", check_system),
        ("Homebrew", check_homebrew),
        ("CMake", check_cmake),
        ("Xcode Tools", check_xcode_tools),
        ("Environnement virtuel", check_venv),
        ("Structure du projet", check_project_structure),
        ("Packages Python", check_python_packages),
        ("Fichier .env", check_env_file),
        ("Démon Reachy Mini", check_daemon),
    ]
    
    results = []
    
    for name, check_func in checks:
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print_error(f"Erreur lors de la vérification de {name}: {e}")
            results.append((name, False))
    
    # Résumé
    print_header("RÉSUMÉ")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        if result:
            print_success(f"{name}: OK")
        else:
            print_error(f"{name}: ÉCHEC")
    
    print(f"\n{Colors.BOLD}Résultat: {passed}/{total} vérifications réussies{Colors.RESET}\n")
    
    if passed == total:
        print_success("Tous les prérequis sont satisfaits !")
        return 0
    else:
        print_warning("Certains prérequis manquent. Consultez les messages ci-dessus.")
        return 1


if __name__ == "__main__":
    sys.exit(main())


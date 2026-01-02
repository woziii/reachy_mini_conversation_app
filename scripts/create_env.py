#!/usr/bin/env python3
"""Script pour créer le fichier .env avec la clé API OpenAI."""

import os
from pathlib import Path


def create_env_file() -> None:
    """Crée le fichier .env avec la configuration."""
    env_path = Path(".env")
    
    if env_path.exists():
        print("⚠️  Le fichier .env existe déjà.")
        response = input("Voulez-vous le remplacer ? (o/N): ")
        if response.lower() != 'o':
            print("Annulé.")
            return
    
    # Clé API fournie par l'utilisateur
    api_key = "..."
    
    content = f"""# Configuration pour Reachy Mini Conversation App
# Ce fichier contient les variables d'environnement sensibles
# Ne pas commiter ce fichier dans git (déjà dans .gitignore)

# Clé API OpenAI (requis)
OPENAI_API_KEY={api_key}

# Modèle OpenAI (optionnel, par défaut: gpt-realtime)
# MODEL_NAME=gpt-realtime

# Configuration Hugging Face (optionnel, pour vision locale)
# HF_HOME=./cache
# HF_TOKEN=
# LOCAL_VISION_MODEL=HuggingFaceTB/SmolVLM2-2.2B-Instruct

# Profil personnalisé (optionnel)
# REACHY_MINI_CUSTOM_PROFILE=default
"""
    
    try:
        env_path.write_text(content, encoding='utf-8')
        print(f"✅ Fichier .env créé avec succès à: {env_path.absolute()}")
        print("⚠️  Assurez-vous que ce fichier n'est pas committé dans git (déjà dans .gitignore)")
    except Exception as e:
        print(f"❌ Erreur lors de la création du fichier .env: {e}")


if __name__ == "__main__":
    # Changer vers le répertoire racine du projet
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    os.chdir(project_root)
    
    create_env_file()


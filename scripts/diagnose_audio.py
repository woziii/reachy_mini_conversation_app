#!/usr/bin/env python3
"""Script de diagnostic pour le problème audio dans l'application Reachy Mini Conversation."""

import sys
import os
import logging
import asyncio
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root / "src"))

logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)


def check_api_key():
    """Vérifier la présence et le format de la clé API OpenAI."""
    logger.info("=" * 60)
    logger.info("1. Vérification de la clé API OpenAI")
    logger.info("=" * 60)
    
    from reachy_mini_conversation_app.config import config
    
    api_key = config.OPENAI_API_KEY
    
    if not api_key or not api_key.strip():
        logger.error("   ❌ OPENAI_API_KEY non trouvée")
        logger.error("   Vérifiez que le fichier .env existe et contient OPENAI_API_KEY=...")
        return False
    
    if not api_key.startswith("sk-"):
        logger.warning("   ⚠️  La clé API ne commence pas par 'sk-' (format suspect)")
        logger.warning("   Clé trouvée: %s...", api_key[:10] if len(api_key) > 10 else "***")
        return False
    
    logger.info("   ✅ Clé API trouvée (longueur: %d, préfixe: %s)", len(api_key), api_key[:4])
    return True


async def test_openai_connection():
    """Tester la connexion à l'API OpenAI Realtime."""
    logger.info("")
    logger.info("=" * 60)
    logger.info("2. Test de connexion à l'API OpenAI Realtime")
    logger.info("=" * 60)
    
    try:
        from openai import AsyncOpenAI
        from reachy_mini_conversation_app.config import config
        
        if not config.OPENAI_API_KEY or not config.OPENAI_API_KEY.strip():
            logger.error("   ❌ Impossible de tester: clé API manquante")
            return False
        
        logger.info("   Tentative de connexion à OpenAI Realtime API...")
        client = AsyncOpenAI(api_key=config.OPENAI_API_KEY)
        
        # Test simple: récupérer les informations du modèle
        try:
            model_info = await client.models.retrieve(config.MODEL_NAME)
            logger.info("   ✅ Connexion réussie - Modèle: %s", model_info.id)
            return True
        except Exception as e:
            logger.error("   ❌ Erreur lors de la récupération du modèle: %s", e)
            return False
            
    except ImportError:
        logger.error("   ❌ Module 'openai' non installé")
        return False
    except Exception as e:
        logger.error("   ❌ Erreur lors du test de connexion: %s", e)
        return False


def check_microphone_permissions():
    """Vérifier les permissions microphone (macOS)."""
    logger.info("")
    logger.info("=" * 60)
    logger.info("3. Vérification des permissions microphone")
    logger.info("=" * 60)
    
    import platform
    
    if platform.system() != "Darwin":
        logger.info("   ℹ️  Vérification des permissions microphone non disponible sur %s", platform.system())
        logger.info("   Vérifiez manuellement dans les paramètres système")
        return True
    
    try:
        import sounddevice as sd
        devices = sd.query_devices()
        input_devices = [d for d in devices if d['max_input_channels'] > 0]
        
        if input_devices:
            logger.info("   ✅ Périphériques microphone détectés:")
            for dev in input_devices[:3]:  # Afficher les 3 premiers
                logger.info("      - %s (canaux: %d)", dev['name'], dev['max_input_channels'])
            return True
        else:
            logger.warning("   ⚠️  Aucun périphérique microphone détecté")
            return False
    except ImportError:
        logger.warning("   ⚠️  Module 'sounddevice' non disponible - impossible de vérifier")
        return None
    except Exception as e:
        logger.warning("   ⚠️  Erreur lors de la vérification: %s", e)
        return None


def check_fastrtc():
    """Vérifier que fastrtc est installé et fonctionnel."""
    logger.info("")
    logger.info("=" * 60)
    logger.info("4. Vérification de fastrtc")
    logger.info("=" * 60)
    
    try:
        import fastrtc
        logger.info("   ✅ fastrtc importé avec succès")
        
        # Vérifier les classes principales
        from fastrtc import Stream, AsyncStreamHandler
        logger.info("   ✅ Classes fastrtc disponibles: Stream, AsyncStreamHandler")
        return True
    except ImportError as e:
        logger.error("   ❌ fastrtc non installé ou erreur d'import: %s", e)
        return False
    except Exception as e:
        logger.error("   ❌ Erreur lors de la vérification de fastrtc: %s", e)
        return False


def check_openai_realtime_handler():
    """Vérifier que le handler OpenAI Realtime peut être instancié."""
    logger.info("")
    logger.info("=" * 60)
    logger.info("5. Vérification du handler OpenAI Realtime")
    logger.info("=" * 60)
    
    try:
        from reachy_mini_conversation_app.openai_realtime import OpenaiRealtimeHandler
        from reachy_mini_conversation_app.tools.core_tools import ToolDependencies
        
        # Créer des dépendances minimales (mock)
        class MockDeps:
            pass
        
        deps = MockDeps()
        deps.movement_manager = None
        deps.head_wobbler = None
        deps.camera_worker = None
        deps.vision_manager = None
        
        handler = OpenaiRealtimeHandler(deps, gradio_mode=True)
        logger.info("   ✅ OpenaiRealtimeHandler instancié avec succès")
        logger.info("   ✅ Sample rates: input=%d, output=%d", 
                   handler.input_sample_rate, handler.output_sample_rate)
        return True
    except Exception as e:
        logger.error("   ❌ Erreur lors de l'instanciation du handler: %s", e, exc_info=True)
        return False


def check_env_file():
    """Vérifier le fichier .env."""
    logger.info("")
    logger.info("=" * 60)
    logger.info("6. Vérification du fichier .env")
    logger.info("=" * 60)
    
    env_path = project_root / ".env"
    
    if not env_path.exists():
        logger.warning("   ⚠️  Fichier .env non trouvé à: %s", env_path)
        logger.warning("   Créez-le avec: OPENAI_API_KEY=votre_clé")
        return False
    
    logger.info("   ✅ Fichier .env trouvé: %s", env_path)
    
    # Lire et vérifier le contenu (sans afficher la clé complète)
    try:
        with open(env_path, "r") as f:
            content = f.read()
            if "OPENAI_API_KEY" in content:
                lines = [l for l in content.split("\n") if l.strip().startswith("OPENAI_API_KEY")]
                if lines:
                    key_line = lines[0]
                    if "=" in key_line:
                        key_value = key_line.split("=", 1)[1].strip()
                        if key_value:
                            logger.info("   ✅ OPENAI_API_KEY trouvée dans .env (longueur: %d)", len(key_value))
                            return True
                logger.warning("   ⚠️  OPENAI_API_KEY présente mais vide dans .env")
                return False
            else:
                logger.warning("   ⚠️  OPENAI_API_KEY non trouvée dans .env")
                return False
    except Exception as e:
        logger.error("   ❌ Erreur lors de la lecture de .env: %s", e)
        return False


async def main():
    """Exécuter tous les diagnostics."""
    logger.info("")
    logger.info("=" * 60)
    logger.info("  DIAGNOSTIC AUDIO - REACHY MINI CONVERSATION APP")
    logger.info("=" * 60)
    logger.info("")
    
    results = []
    
    # 1. Vérifier .env
    results.append(("Fichier .env", check_env_file()))
    
    # 2. Vérifier la clé API
    results.append(("Clé API OpenAI", check_api_key()))
    
    # 3. Tester la connexion OpenAI
    results.append(("Connexion OpenAI", await test_openai_connection()))
    
    # 4. Vérifier fastrtc
    results.append(("fastrtc", check_fastrtc()))
    
    # 5. Vérifier le handler
    results.append(("Handler OpenAI Realtime", check_openai_realtime_handler()))
    
    # 6. Vérifier les permissions microphone
    mic_result = check_microphone_permissions()
    if mic_result is not None:
        results.append(("Permissions microphone", mic_result))
    
    # Résumé
    logger.info("")
    logger.info("=" * 60)
    logger.info("  RÉSUMÉ")
    logger.info("=" * 60)
    logger.info("")
    
    passed = sum(1 for _, result in results if result is True)
    failed = sum(1 for _, result in results if result is False)
    warnings = sum(1 for _, result in results if result is None)
    
    for name, result in results:
        if result is True:
            logger.info("   ✅ %s", name)
        elif result is False:
            logger.error("   ❌ %s", name)
        else:
            logger.warning("   ⚠️  %s (non vérifié)", name)
    
    logger.info("")
    logger.info("Résultat: %d/%d vérifications réussies", passed, passed + failed)
    
    if failed > 0:
        logger.error("")
        logger.error("Des problèmes ont été détectés. Corrigez-les avant de lancer l'application.")
        return 1
    
    logger.info("")
    logger.info("✅ Tous les diagnostics sont passés !")
    logger.info("")
    logger.info("Si l'application ne répond toujours pas en audio, vérifiez les logs")
    logger.info("lors du lancement avec --debug pour plus de détails.")
    return 0


if __name__ == "__main__":
    try:
        exit_code = asyncio.run(main())
        sys.exit(exit_code)
    except KeyboardInterrupt:
        logger.info("\nDiagnostic interrompu par l'utilisateur.")
        sys.exit(1)
    except Exception as e:
        logger.error("Erreur fatale lors du diagnostic: %s", e, exc_info=True)
        sys.exit(1)



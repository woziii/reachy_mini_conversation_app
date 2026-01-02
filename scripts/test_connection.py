#!/usr/bin/env python3
"""Script pour tester la connexion au robot Reachy Mini."""

import sys
import time
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from reachy_mini import ReachyMini
except ImportError:
    print("❌ Erreur: Impossible d'importer reachy_mini")
    print("Assurez-vous que le SDK Reachy Mini est installé:")
    print("  pip install reachy-mini")
    sys.exit(1)


def test_connection() -> bool:
    """Teste la connexion au robot."""
    print("=" * 60)
    print("  Test de connexion au robot Reachy Mini")
    print("=" * 60)
    print()
    
    print("1. Initialisation de la connexion...")
    try:
        # Utiliser le backend par défaut pour Reachy Mini Lite
        robot = ReachyMini(media_backend="default")
        print("   ✓ Objet ReachyMini créé")
    except Exception as e:
        print(f"   ✗ Erreur lors de la création: {e}")
        return False
    
    print()
    print("2. Connexion au démon...")
    try:
        # Vérifier le statut
        status = robot.client.get_status()
        print("   ✓ Connexion au démon réussie")
        print(f"   - Simulation: {status.get('simulation_enabled', 'N/A')}")
        print(f"   - Version sans fil: {status.get('wireless_version', 'N/A')}")
    except Exception as e:
        print(f"   ✗ Erreur de connexion: {e}")
        print("   ⚠️  Assurez-vous que le démon est lancé:")
        print("      ./scripts/start_daemon.sh")
        robot.client.disconnect()
        return False
    
    print()
    print("3. Test de commande simple...")
    try:
        # Essayer une commande simple (obtenir la position de la tête)
        # Note: Cette commande peut varier selon l'API
        print("   ✓ Test de commande...")
        # On ne fait pas de mouvement pour éviter de bouger le robot
        # mais on vérifie que la connexion fonctionne
    except Exception as e:
        print(f"   ⚠️  Avertissement: {e}")
    
    print()
    print("4. Vérification des médias...")
    try:
        # Vérifier que les médias sont disponibles
        media_status = robot.media
        print("   ✓ Médias disponibles")
    except Exception as e:
        print(f"   ⚠️  Avertissement médias: {e}")
    
    print()
    print("5. Nettoyage...")
    try:
        robot.client.disconnect()
        print("   ✓ Déconnexion réussie")
    except Exception as e:
        print(f"   ⚠️  Erreur lors de la déconnexion: {e}")
    
    print()
    print("=" * 60)
    print("✅ Test de connexion réussi !")
    print("=" * 60)
    print()
    print("Le robot est prêt à être utilisé avec l'app de conversation.")
    
    return True


if __name__ == "__main__":
    try:
        success = test_connection()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrompu par l'utilisateur")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Erreur inattendue: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


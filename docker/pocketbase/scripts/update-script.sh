#!/bin/bash

# Script de mise à jour pour PocketBase - Pointage ALAE

echo "🔄 Mise à jour de PocketBase pour Pointage ALAE"
echo ""

# Récupérer la version actuelle
CURRENT_VERSION=$(docker inspect --format '{{.Config.Image}}' pointage-alae-pocketbase 2>/dev/null | cut -d':' -f2)
if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION="non installé"
fi

echo "Version actuelle: $CURRENT_VERSION"
echo ""

# Arrêter le conteneur
echo "⏹️  Arrêt du conteneur..."
docker-compose -f /docker/pointage-alae/docker-compose.yml down

# Reconstruire l'image
echo "📥 Reconstruction de l'image Docker..."
cd /docker/pointage-alae
sudo docker-compose build

# Redémarrer avec la nouvelle version
echo "▶️  Redémarrage avec la nouvelle version..."
docker-compose -f /docker/pointage-alae/docker-compose.yml up -d

# Vérifier la nouvelle version
NEW_VERSION=$(docker inspect --format '{{.Config.Image}}' pointage-alae-pocketbase | cut -d':' -f2)

echo ""
echo "✅ Mise à jour terminée !"
echo "Nouvelle version: $NEW_VERSION"
echo ""
echo "💡 Vérifiez les logs pour vous assurer que tout fonctionne:"
echo "   docker-compose -f /docker/pocketbase/docker-compose.yml logs -f"
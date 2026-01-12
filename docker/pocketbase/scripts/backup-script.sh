#!/bin/bash

# Script de sauvegarde pour PocketBase - Pointage ALAE
# Ce script crée une sauvegarde complète des données PocketBase

# Configuration
BACKUP_DIR="/docker/pointage-alae/pocketbase/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/pocketbase_backup_$DATE.tar.gz"
DATA_DIR="/docker/pointage-alae/pocketbase/pb_data"

# Créer le dossier de sauvegarde s'il n'existe pas
mkdir -p "$BACKUP_DIR"

echo "📦 Création d'une sauvegarde de PocketBase - $DATE"
echo ""

# Arrêter le conteneur pour une sauvegarde cohérente
echo "⏹️  Arrêt du conteneur PocketBase..."
docker-compose -f /docker/pointage-alae/docker-compose.yml down

# Créer l'archive
echo "🗄️  Sauvegarde des données..."
tar -czvf "$BACKUP_FILE" -C "$DATA_DIR" .

# Redémarrer le conteneur
echo "▶️  Redémarrage du conteneur PocketBase..."
docker-compose -f /docker/pointage-alae/docker-compose.yml up -d

echo "✅ Sauvegarde terminée: $BACKUP_FILE"
echo ""
echo "📊 Taille de la sauvegarde:"
du -h "$BACKUP_FILE"
echo ""

# Supprimer les sauvegardes anciennes (garder les 7 dernières)
echo "🧹 Nettoyage des anciennes sauvegardes..."
ls -t "$BACKUP_DIR"/pocketbase_backup_*.tar.gz | tail -n +8 | xargs rm -f 2>/dev/null

echo "🎉 Opération terminée !"
echo ""
echo "💡 Pour restaurer cette sauvegarde:"
echo "   1. Arrêtez le conteneur: docker-compose down"
echo "   2. Extrayez l'archive: tar -xzvf $BACKUP_FILE -C $DATA_DIR"
echo "   3. Redémarrez le conteneur: docker-compose up -d"
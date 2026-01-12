#!/bin/bash

# Script d'initialisation simplifié de PocketBase pour Pointage ALAE

echo "🚀 Initialisation de PocketBase pour Pointage ALAE"
echo ""

# Attendre que PocketBase soit prêt
echo "⏳ Attente du démarrage de PocketBase..."
for i in {1..30}; do
    if curl -s http://localhost:8090/api/health > /dev/null 2>&1; then
        echo "✅ PocketBase est prêt !"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Impossible de se connecter à PocketBase"
        exit 1
    fi
    sleep 1
done

# Créer un compte admin
echo "🔐 Création du compte administrateur..."
ADMIN_EMAIL="admin@alae.local"
ADMIN_PASSWORD="ALAE_2026_Admin"

# Vérifier si un admin existe déjà
RESPONSE=$(curl -s -w "%{http_code}" http://localhost:8090/api/admins/auth-with-password \
    -H "Content-Type: application/json" \
    -d '{"identity": "admin@alae.local", "password": "ALAE_2026_Admin"}')

HTTP_CODE=${RESPONSE: -3}

if [ "$HTTP_CODE" != "200" ]; then
    echo "🆕 Création d'un nouvel administrateur"
    curl -X POST http://localhost:8090/api/admins \
        -H "Content-Type: application/json" \
        -d '{"email": "admin@alae.local", "password": "ALAE_2026_Admin", "passwordConfirm": "ALAE_2026_Admin"}'
    echo "📝 Identifiants admin :"
    echo "    Email: admin@alae.local"
    echo "    Mot de passe: ALAE_2026_Admin"
else
    echo "ℹ️  Un administrateur existe déjà"
fi

# Importer le schéma
echo "📦 Import du schéma PocketBase..."
sleep 5  # Attente pour que le volume soit prêt

if [ -f "/pb_data/pocketbase_schema.json" ]; then
    echo "📄 Schéma trouvé, import en cours..."
    curl -X POST http://localhost:8090/api/collections/import \
        -H "Content-Type: application/json" \
        -d @/pb_data/pocketbase_schema.json
    echo "✅ Schéma importé avec succès"
else
    echo "⚠️  Fichier de schéma non trouvé: /pb_data/pocketbase_schema.json"
    echo "    Le schéma sera importé manuellement via l'interface admin"
fi

# Créer un utilisateur API
echo "🤖 Création d'un utilisateur API pour l'application..."

# Récupérer un token admin pour les opérations
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8090/api/admins/auth-with-password \
    -H "Content-Type: application/json" \
    -d '{"identity": "admin@alae.local", "password": "ALAE_2026_Admin"}' \
    | grep -o '"token"[^,]*' | cut -d':' -f2 | tr -d '" ')

if [ -n "$ADMIN_TOKEN" ]; then
    # Vérifier si l'utilisateur API existe
    API_USER_EXISTS=$(curl -s -H "Authorization: Admin $ADMIN_TOKEN" \
        http://localhost:8090/api/collections/users/records \
        | grep -c "pointage-app-user" || echo "0")
    
    if [ "$API_USER_EXISTS" -eq "0" ]; then
        curl -X POST http://localhost:8090/api/collections/users/records \
            -H "Content-Type: application/json" \
            -H "Authorization: Admin $ADMIN_TOKEN" \
            -d '{"username": "pointage-app-user", "email": "app@alae.local", "password": "ALAE_2026_App", "passwordConfirm": "ALAE_2026_App"}'
        echo "📝 Identifiants API pour l'application :"
        echo "    Username: pointage-app-user"
        echo "    Mot de passe: ALAE_2026_App"
    else
        echo "ℹ️  Utilisateur API existe déjà"
    fi
else
    echo "⚠️  Impossible de récupérer un token admin"
fi

# Récupérer l'IP du NAS
NAS_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "🎉 Initialisation terminée !"
echo ""
echo "📋 Résumé :"
echo "   - PocketBase est opérationnel sur le port 8090"
echo "   - Interface admin: http://$NAS_IP:8090/_/"
echo "   - Email admin: admin@alae.local"
echo "   - Mot de passe admin: ALAE_2026_Admin"
echo ""
echo "💡 Pour utiliser PocketBase dans votre application, configurez :"
echo "   const pb = new PocketBase('http://$NAS_IP:8090');"
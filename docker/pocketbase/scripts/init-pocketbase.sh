#!/bin/bash

# Script d'initialisation de PocketBase pour Pointage ALAE
# Ce script doit être exécuté après le premier démarrage du conteneur

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

# Créer un compte admin si ce n'est pas déjà fait
echo "🔐 Création du compte administrateur..."
ADMIN_EMAIL="admin@alae.local"
ADMIN_PASSWORD="ALAE_2026_Admin"

# Vérifier si un admin existe déjà
ADMIN_EXISTS=$(curl -s http://localhost:8090/api/admins/auth-with-password 
    -H "Content-Type: application/json" 
    -d '{"identity": "admin@alae.local", "password": "ALAE_2026_Admin"}' 
    | grep -c "token")

if [ $ADMIN_EXISTS -eq 0 ]; then
    echo "🆕 Création d'un nouvel administrateur"
    curl -X POST http://localhost:8090/api/admins 
        -H "Content-Type: application/json" 
        -d '{"email": "admin@alae.local", "password": "ALAE_2026_Admin", "passwordConfirm": "ALAE_2026_Admin"}'
    echo "📝 Identifiants admin :"
    echo "    Email: admin@alae.local"
    echo "    Mot de passe: ALAE_2026_Admin"
else
    echo "ℹ️  Un administrateur existe déjà"
fi

# Importer le schéma
echo "📦 Import du schéma PocketBase..."
echo "⏳ Attente de 5 secondes pour que le volume soit prêt..."
sleep 5
if [ -f "/pb_data/pocketbase_schema.json" ]; then
    echo "📄 Schéma trouvé, import en cours..."
    curl -X POST http://localhost:8090/api/collections/import 
        -H "Content-Type: application/json" 
        -d @/pb_data/pocketbase_schema.json
    echo "✅ Schéma importé avec succès"
else
    echo "⚠️  Fichier de schéma non trouvé: /pb_data/pocketbase_schema.json"
fi

# Créer un utilisateur API pour l'application
echo "🤖 Création d'un utilisateur API pour l'application..."
API_USER_EXISTS=$(curl -s http://localhost:8090/api/collections/users/records 
    -H "Content-Type: application/json" 
    -H "Authorization: Admin $(curl -s -X POST http://localhost:8090/api/admins/auth-with-password 
        -H "Content-Type: application/json" 
        -d '{"identity": "admin@alae.local", "password": "ALAE_2026_Admin"}' 
        | grep -o '"token"[^,]*' | cut -d':' -f2 | tr -d '" ')" 
    | grep -c "pointage-app-user")

if [ $API_USER_EXISTS -eq 0 ]; then
    API_TOKEN=$(curl -s -X POST http://localhost:8090/api/collections/users/records 
        -H "Content-Type: application/json" 
        -H "Authorization: Admin $(curl -s -X POST http://localhost:8090/api/admins/auth-with-password 
            -H "Content-Type: application/json" 
            -d '{"identity": "admin@alae.local", "password": "ALAE_2026_Admin"}' 
            | grep -o '"token"[^,]*' | cut -d':' -f2 | tr -d '" ')" 
        -d '{"username": "pointage-app-user", "email": "app@alae.local", "password": "ALAE_2026_App", "passwordConfirm": "ALAE_2026_App"}' 
        | grep -o '"token"[^,]*' | cut -d':' -f2 | tr -d '" ')
    
    echo "📝 Identifiants API pour l'application :"
    echo "    Username: pointage-app-user"
    echo "    Mot de passe: ALAE_2026_App"
    echo "    Token: $API_TOKEN"
fi

echo ""
echo "🎉 Initialisation terminée !"
echo ""
echo "📋 Résumé :"
echo "   - PocketBase est opérationnel sur le port 8090"
echo "   - Interface admin: http://$(hostname -I | awk '{print $1}'):8090/_/"
echo "   - Email admin: admin@alae.local"
echo "   - Mot de passe admin: ALAE_2026_Admin"
echo ""
echo "💡 Pour utiliser PocketBase dans votre application, configurez :"
echo "   const pb = new PocketBase('http://$(hostname -I | awk '{print $1}'):8090');"
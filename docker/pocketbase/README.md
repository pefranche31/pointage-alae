# Docker PocketBase pour Pointage ALAE

Ce dossier contient tout le nécessaire pour déployer PocketBase avec Docker pour votre application Pointage ALAE.

## Prérequis

- NAS Synology avec Container Manager installé
- Docker activé sur votre NAS
- Accès SSH ou File Station pour copier les fichiers

## Structure du dossier

```
docker/pocketbase/
├── docker-compose.yml      # Configuration Docker
├── README.md               # Ce fichier
├── pb_data/                # (Créé automatiquement) Données persistantes
└── pocketbase_schema.json   # Schéma de votre base de données
```

## Déploiement sur votre NAS

### Méthode 1: Via SSH (recommandé pour la première installation)

1. **Copiez l'ensemble du projet** sur votre NAS dans `/docker/pointage-alae/` (via File Station ou SSH)
   - Le fichier `docker-compose.yml` doit être à la racine de `/docker/pointage-alae/`
   - Le dossier `docker/pointage-alae/pocketbase/` contient les scripts et la configuration

2. **Construisez l'image Docker** (nécessaire une seule fois) :
   ```bash
   cd /docker/pointage-alae
   sudo docker-compose build
   ```
   Cette commande va télécharger l'image officielle de PocketBase et construire votre image personnalisée.

3. **Démarrez le conteneur** :
   ```bash
   sudo docker-compose up -d
   ```

4. **Vérifiez que tout fonctionne** :
   ```bash
   sudo docker-compose logs -f
   ```
   Ou testez directement dans votre navigateur : `http://<adresse-nas>:8090`

### Méthode 2: Via Container Manager (pour la gestion quotidienne)

Une fois l'image construite, vous pouvez utiliser Container Manager :

1. **Ouvrez Container Manager**
2. **Importez le compose** :
   - Cliquez sur "Projet" → "Créer"
   - Sélectionnez le fichier `/docker/pointage-alae/docker-compose.yml`
   - Cliquez sur "Suivant" puis "Terminer"
3. **Démarrez le projet** :
   - Sélectionnez le projet "pointage-alae-pocketbase"
   - Cliquez sur "Démarrer"

⚠️ **Note importante** : La première construction peut prendre quelques minutes car Docker doit télécharger l'image de base de PocketBase depuis GitHub Container Registry. Utilisez la méthode SSH pour cette étape.

### Méthode 2: Via SSH

```bash
# Copiez le projet sur votre NAS (si ce n'est pas déjà fait)
scp -r /chemin/vers/Pointage_ALAE/docker/pocketbase admin@votre-nas:/docker/

# Connectez-vous à votre NAS
ssh admin@votre-nas

# Allez dans le dossier
cd /docker/pocketbase

# Lancez le conteneur
sudo docker-compose up -d
```

## Configuration initiale

1. **Accédez à l'interface admin** :
   - URL: `http://<adresse-nas>:8090/_/`
   - Créez votre compte administrateur

2. **Importez le schéma** :
   - Le schéma est déjà monté dans le conteneur
   - Vous pouvez l'importer via l'interface ou utiliser ce script :

```bash
# Exécutez cette commande pour importer le schéma
curl -X POST http://localhost:8090/api/collections/import \
  -H "Content-Type: application/json" \
  -d @/docker/pocketbase/pocketbase_schema.json
```

## Commandes utiles

### Démarrer/Arrêter
```bash
# Démarrer
cd /docker/pointage-alae
sudo docker-compose up -d

# Arrêter
cd /docker/pointage-alae
sudo docker-compose down

# Redémarrer
cd /docker/pointage-alae
sudo docker-compose restart
```

### Mise à jour
```bash
# Reconstruire et redémarrer
cd /docker/pointage-alae
sudo docker-compose build
sudo docker-compose up -d --force-recreate
```

### Sauvegarde
```bash
# Les données sont dans pb_data/
# Il suffit de copier ce dossier
tar -czvf pocketbase_backup_$(date +%Y%m%d).tar.gz pb_data/
```

### Logs
```bash
# Voir les logs
sudo docker-compose logs -f

# Voir les logs d'un service spécifique
sudo docker-compose logs -f pocketbase
```

## Configuration pour votre application

Modifiez votre `www/index.html` pour utiliser PocketBase :

```javascript
// Ajoutez cette ligne au début de votre code React
const pb = new PocketBase('http://<adresse-nas>:8090');

// Exemple d'utilisation pour charger les enfants
const fetchChildren = async () => {
    const records = await pb.collection('children').getFullList({
        sort: 'nom'
    });
    return records.map(r => ({...r, id: r.id}));
};
```

## Dépannage

### Le conteneur ne démarre pas
- Vérifiez les logs avec `sudo docker-compose logs`
- Assurez-vous que le port 8090 n'est pas utilisé
- Vérifiez les permissions sur le dossier `pb_data`

### Problème de connexion
- Vérifiez que le pare-feu du NAS autorise le port 8090
- Essayez d'accéder depuis le NAS lui-même avec `http://localhost:8090`

### Problème de performances
- Augmentez la mémoire allouée à Docker dans Container Manager
- Vérifiez que votre NAS a assez de ressources

## Sécurité

- Changez le port par défaut (8090) si votre NAS est exposé sur Internet
- Configurez un reverse proxy avec HTTPS si nécessaire
- Limitez l'accès à l'interface admin

## Prochaines étapes

1. [ ] Déployer le conteneur sur votre NAS
2. [ ] Importer le schéma de base de données
3. [ ] Configurer votre application pour utiliser PocketBase
4. [ ] Tester la synchronisation des données
5. [ ] Configurer les sauvegardes automatiques
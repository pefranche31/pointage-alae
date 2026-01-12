# Migration ALAE vers PocketBase - Guide Technique

## Introduction

Ce guide explique comment migrer l'application ALAE de son stockage local vers PocketBase pour un déploiement sur NAS.

## Architecture PocketBase Proposée

### Collections Principales

1. **children** : Base des données enfants
2. **attendance** : Présences et horaires
3. **locks** : Verrous de sessions
4. **comments** : Commentaires et notes
5. **initialized_dates** : Dates déjà initialisées

### Avantages de cette structure

- **Relations natives** : Utilisation des relations PocketBase entre enfants et présences
- **Indexation optimisée** : Requêtes rapides par date, classe, créneau
- **Validation des données** : Types stricts et champs requis
- **Évolutivité** : Conçu pour gérer des centaines d'enfants et des années de données

## Étapes de Migration

### 1. Installation de PocketBase sur NAS

```bash
# Télécharger PocketBase
wget https://github.com/pocketbase/pocketbase/releases/download/v0.20.0/pocketbase_0.20.0_linux_amd64.zip
unzip pocketbase_0.20.0_linux_amd64.zip

# Créer un service systemd pour PocketBase
sudo nano /etc/systemd/system/pocketbase.service
```

Fichier `pocketbase.service` :
```ini
[Unit]
Description=PocketBase Server
After=network.target

[Service]
User=pocketbase
WorkingDirectory=/opt/pocketbase
ExecStart=/opt/pocketbase/pocketbase serve --http=0.0.0.0:8090
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
# Activer et démarrer le service
sudo systemctl daemon-reload
sudo systemctl enable pocketbase
sudo systemctl start pocketbase
```

### 2. Configuration du schéma

Importer le schéma depuis `pocketbase_schema.json` :

```bash
# Via l'interface admin ou l'API
curl -X POST http://localhost:8090/api/collections/import \
  -H "Content-Type: application/json" \
  -d @pocketbase_schema.json
```

### 3. Script de migration des données

Créer un script Node.js pour migrer les données existantes :

```javascript
// migration_script.js
const fs = require('fs');
const PocketBase = require('pocketbase');

async function migrate() {
    // Connexion à PocketBase
    const pb = new PocketBase('http://localhost:8090');
    
    // Authentification admin
    await pb.admins.authWithPassword('admin@example.com', 'password');
    
    // Charger les données existantes
    const backupData = JSON.parse(fs.readFileSync('alae_backup.json', 'utf8'));
    
    // Migration des enfants
    for (const child of backupData.children) {
        await pb.collection('children').create({
            nom: child.nom,
            prenom: child.prenom,
            classe: child.classe,
            niveau: child.niveau,
            planning: child.planning
        });
    }
    
    // Migration des présences
    for (const [key, status] of Object.entries(backupData.attendance)) {
        if (status === 'present') {
            const [date, childId, creneau] = key.split('-');
            const child = backupData.children.find(c => c.id === childId);
            if (child) {
                await pb.collection('attendance').create({
                    child: child.id,
                    date: new Date(date.split('/').reverse().join('-')),
                    creneau: creneau,
                    status: 'present'
                });
            }
        }
    }
    
    console.log('Migration terminée avec succès !');
}

migrate().catch(console.error);
```

### 4. Adaptation du code React

Modifier `www/index.html` pour utiliser PocketBase SDK :

```javascript
// Ajouter PocketBase SDK
const pb = new PocketBase('http://votre-nas:8090');

// Remplacer les appels useState par des appels API
const fetchChildren = async () => {
    const records = await pb.collection('children').getFullList({
        sort: 'nom'
    });
    return records.map(r => ({...r, id: r.id}));
};

const fetchAttendance = async (date, childId, creneau) => {
    const record = await pb.collection('attendance').getFirstListItem(
        `child = "${childId}" && date = "${date}" && creneau = "${creneau}"`
    );
    return record ? record.status : null;
};
```

### 5. Sécurité et Authentification

Configurer les règles d'accès dans PocketBase :

```json
{
  "children": {
    "create": "admin || user != null",
    "read": "admin || user != null",
    "update": "admin",
    "delete": "admin"
  },
  "attendance": {
    "create": "admin || user != null",
    "read": "admin || user != null",
    "update": "admin || user != null",
    "delete": "admin"
  }
}
```

## Optimisations pour NAS

### 1. Sauvegardes automatiques

```bash
# Script de sauvegarde quotidien
#!/bin/bash
DATE=$(date +%Y-%m-%d)
pocketbase export --dir /backup/pocketbase/$DATE
```

### 2. Monitoring

```bash
# Vérification de l'état du service
systemctl status pocketbase
journalctl -u pocketbase -f
```

### 3. Mise à jour

```bash
# Procédure de mise à jour
systemctl stop pocketbase
wget https://github.com/pocketbase/pocketbase/releases/latest/download/pocketbase_linux_amd64.zip
unzip pocketbase_linux_amd64.zip -d /opt/pocketbase/
systemctl start pocketbase
```

## Résolution des problèmes courants

### Problème : Connexion refusée
- Vérifier que le port 8090 est ouvert sur le NAS
- Vérifier les règles de pare-feu
- Vérifier que PocketBase est en cours d'exécution

### Problème : Performances lentes
- Ajouter des index supplémentaires
- Optimiser les requêtes avec des filtres
- Limiter le nombre d'enregistrements retournés

### Problème : Données corrompues
- Restaurer depuis une sauvegarde
- Vérifier l'intégrité des données avec des scripts de validation

## Prochaines étapes

1. [ ] Tester la migration avec des données de test
2. [ ] Adapter l'interface utilisateur pour les erreurs réseau
3. [ ] Implémenter la synchronisation hors ligne
4. [ ] Configurer les sauvegardes automatiques
5. [ ] Documenter les procédures pour les utilisateurs finaux
# Pointage ALAE - Système de Suivi Dynamique & Cloud

Ce projet est une solution web complète pour la gestion des présences en Accueil de Loisirs Associé à l'École (ALAE). Il permet un suivi en temps réel sur plusieurs appareils, une gestion prévisionnelle automatisée et une résilience totale en cas de perte de connexion internet.

## 🚀 Fonctionnalités Clés

- Synchronisation Cloud Temps Réel : Utilise Firebase Firestore pour synchroniser instantanément les pointages entre toutes les tablettes de l'équipe.
- Mode "Photo" Hors-Ligne : En cas de coupure réseau, l'application fige les données locales. La liste des enfants présents reste accessible (aspect critique pour la sécurité), tandis que les modifications sont bloquées pour éviter les conflits.
- Gestion Prévisionnelle : Pré-remplissage automatique des listes d'appel basé sur les plannings parents (Semaines Paires/Impaires).
- Convertisseur de Données : Outil dédié pour transformer vos exports Excel (CSV 26 colonnes) en JSON prêt pour l'application.
- Exports Administratifs :
    - Sauvegarde totale du système (Backup complet pour restauration).
    - Rapport de facturation mensuel au format CSV compatible Excel.
- Sécurisation : Accès aux fonctions d'importation protégé par le mot de passe : ALAE_2026.

## 📁 Structure du Projet

- pointage.html : L'application principale utilisée par les animateurs sur le terrain.
- csv_to_json.html : L'outil utilitaire pour préparer la base de données à partir d'un export tableur.


## 🛠️ Configuration Technique (Firebase)

Pour activer la synchronisation, vous devez configurer votre propre projet Firebase :
1. Créez un projet sur la Console Firebase.
1. Activez l'Authentification Anonyme dans l'onglet Authentication > Sign-in method.
1. Créez une base de données Cloud Firestore (commencez en "mode test").
1. Enregistrez une Application Web `(`</>)` pour obtenir votre objet firebaseConfig.
1. Collez cet objet dans le fichier pointage.html à l'emplacement prévu :

````
const firebaseConfig = {
    apiKey: "VOTRE_API_KEY",
    authDomain: "VOTRE_PROJET.firebaseapp.com",
    projectId: "VOTRE_PROJET_ID",
    storageBucket: "VOTRE_PROJET.appspot.com",
    messagingSenderId: "VOTRE_SENDER_ID",
    appId: "VOTRE_APP_ID"
};
````

**Règles de Sécurité Firestore**

Pour que l'application puisse lire et écrire les données, copiez ces règles dans l'onglet Rules de votre console Firestore :
````
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /artifacts/{appId}/public/data/{collectionName}/{documentId} {
      allow read, write: if true;
    }
  }
}
````

## 📋 Mode Opératoire

### 1. Préparation des données (Rentrée ou changement de période)

- Ouvrez l'outil csv_to_json.html.
- Exportez votre tableau Excel au format CSV (26 colonnes avec les en-têtes exacts p-lun-ma, i-ven-so, etc.).
- Glissez le fichier dans le convertisseur et téléchargez le fichier généré enfants_alae.json.

### 2. Importation dans l'application

- Sur pointage.html, cliquez sur l'icône Dossier (Import) située en haut à gauche.
- Saisissez le mot de passe : ALAE_2026.
- Sélectionnez votre fichier JSON. La base de données est alors mise à jour instantanément sur tous les appareils connectés.

### 3. Utilisation Quotidienne

- Onglet Appel : Cochez les enfants présents. Les présences théoriques (midi/soir) sont pré-remplies automatiquement lors de la première ouverture de chaque journée.
- Onglet Entrées / Sorties : Utilisez cet espace pour le pointage fin des flux (arrivées matin, départs soir) avec horodatage automatique.
- Dashboard : Consultez en un coup d'œil l'effectif total présent pour les procédures de sécurité.

### 4. Facturation (Fin de mois)

- Cliquez sur l'icône Téléchargement (Export).
- Sélectionnez le mois et l'année souhaités.
- Générez le rapport CSV. Ce fichier liste tous les enfants et leurs présences réelles ('x') pour chaque créneau du mois.

⚠️ Sécurité & Niveaux Scolaires

L'application applique une règle de filtrage automatique basée sur le préfixe du nom de la classe :

- Classes commençant par 1 ou 2 : Classées en "Maternelle".
- Classes commençant par 3, 4 ou 5 : Classées en "Élémentaire".

Développé pour garantir la sécurité des enfants et la réactivité des équipes ALAE, même en conditions réseau dégradées.
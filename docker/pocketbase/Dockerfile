# Dockerfile pour PocketBase - Pointage ALAE
# Utilise l'image officielle de PocketBase depuis Docker Hub

FROM pocketbase/pocketbase:latest

# Configuration par défaut
ENV PB_PUBLIC_DIR=/pb_data/public

# Créer le répertoire de données
RUN mkdir -p /pb_data

# Copier le schéma par défaut (sera écrasé par le volume)
COPY pocketbase_schema.json /pb_data/pocketbase_schema.json

# Exposer le port
EXPOSE 8090

# Commande de démarrage
CMD ["serve", "--http=0.0.0.0:8090"]
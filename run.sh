#!/bin/bash
# Define directories
GITFOLDER="../cosplaygif_app"
LOCALFOLDER=$(pwd)

# Load environment variables from .env
source "$LOCALFOLDER/.env"

echo "***Pulling repo.";

# Change to the GIT folder, exit if fails
cd "$GITFOLDER" || exit 1

# Pull latest changes
git pull

# Return to local folder
cd "$LOCALFOLDER" || exit 1

echo "***Copying files";
# Copy compose.yml from git, overwriting local
cp -f "${GITFOLDER}/docker-compose.yaml" "$LOCALFOLDER/docker-compose.yaml"
cp -f "${LOCALFOLDER}/.env" "${GITFOLDER}/.env.${APP_ENV}"

# Ensure folders are owned by user 82
sudo chown -R 82:82 .storage
sudo chown -R 999:999 .redis .mysql-db

echo "***Builidng docker";
# Launch Docker containers with rebuild
docker compose build && \
  docker compose up -d --force-recreate && \
  # Change ownership of /app inside container as root
  docker compose exec -u root cosplaygif_app_web_${APP_ENV} chown -R www-data: /app && \
  # Run Laravel optimize command inside container
  docker compose exec cosplaygif_app_web_${APP_ENV} php artisan optimize

# Play terminal bell
echo -en "\007"

# Send notification about deployment
#curl -d "cosplaygif.app Deployed ${APP_ENV}" https://ntfy update url 
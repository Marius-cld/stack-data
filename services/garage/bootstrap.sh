#!/bin/sh
# Garage — bootstrap idempotent du nœud unique : layout, import de la clé S3 du .env, bucket.
# À lancer une fois Garage démarré, depuis la racine du repo :
#   docker compose --env-file .env -f services/garage/compose.yaml up -d
#   sh services/garage/bootstrap.sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
set -a
. "$ROOT_DIR/.env"
set +a

garage() {
  docker compose -f "$ROOT_DIR/services/garage/compose.yaml" exec -T -e RUST_LOG=warn garage /garage "$@"
}

# 1. Layout : un seul rôle pour l'unique nœud (la capacité ne sert qu'à répartir les partitions)
if garage layout show | grep -q "No nodes currently have a role"; then
  NODE_ID="$(garage node id -q | cut -d@ -f1)"
  garage layout assign -z dc1 -c 1G "$NODE_ID"
  garage layout apply --version 1
fi

# 2. Clé S3 : celle du .env, pour que le pipeline (LAKE_*) s'authentifie sans étape manuelle
if ! garage key info "$GARAGE_ACCESS_KEY_ID" >/dev/null 2>&1; then
  # stdout masqué : la sortie de l'import peut contenir la clé secrète
  garage key import --yes -n stack-data "$GARAGE_ACCESS_KEY_ID" "$GARAGE_SECRET_ACCESS_KEY" >/dev/null
  echo "Clé S3 importée : $GARAGE_ACCESS_KEY_ID"
fi

# 3. Bucket du data lake + droits de la clé
if ! garage bucket info "$GARAGE_BUCKET" >/dev/null 2>&1; then
  garage bucket create "$GARAGE_BUCKET"
fi
garage bucket allow --read --write --owner "$GARAGE_BUCKET" --key "$GARAGE_ACCESS_KEY_ID"

# stack-data

Stack data minimaliste pour apprendre l'ELT de bout en bout sur le jeu de données e-commerce
[Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

```text
data/raw/*.csv ──extract (dlt)──> Garage S3 ──load (dlt)──> PostgreSQL raw ──dbt──> staging ─> intermediate ─> marts
   fichiers                        data lake                 data warehouse
```

| Étape     | Outil              | Code                             |
| --------- | ------------------ | -------------------------------- |
| Extract   | dlt                | `src/extract/extract_to_lake.py` |
| Load      | dlt                | `src/load/load_to_warehouse.py`  |
| Transform | dbt                | `src/transform/olist_analytics/` |
| Stockage  | Garage, PostgreSQL | `services/`                      |

## Démarrage

Prérequis : Docker, Python 3.13 et les CSV Olist décompressés dans `data/raw/`.

```sh
# 1. Environnement Python et configuration
python3.13 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # puis remplacer les change_me
ln -s ../../../.env src/transform/olist_analytics/.env  # pour dbt Fusion / l'extension VS Code

# 2. Services : data lake + data warehouse
docker compose --env-file .env -f services/garage/compose.yaml up -d
docker compose --env-file .env -f services/postgres/compose.yaml up -d
sh services/garage/bootstrap.sh

# 3. Extract & Load (depuis la racine du repo)
python -m src.extract.extract_to_lake
python -m src.load.load_to_warehouse

# 4. Transform : dbt lit les variables WAREHOUSE_* depuis l'environnement
set -a && source .env && set +a
cd src/transform/olist_analytics
dbt deps
dbt build
```

Détail des modèles dbt : [src/transform/olist_analytics/README.md](src/transform/olist_analytics/README.md).

## Structure

```text
.
├── data/raw/          # CSV sources (non versionnés)
├── services/          # infra Docker : garage/ (data lake), postgres/ (data warehouse)
├── setting/           # config partagée : .env, chemins, catalogue des sources
└── src/
    ├── extract/       # CSV -> data lake
    ├── load/          # data lake -> schéma raw
    └── transform/     # projet dbt
```

## Conventions

- Python : PEP 8, vérifié par `ruff check . && ruff format .` (config dans `pyproject.toml`).
- SQL : minuscules, snake_case, CTE nommées d'après leur rôle (voir le README dbt).
- Secrets : uniquement dans `.env` (jamais versionné), modèle dans `.env.example`.

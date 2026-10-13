# olist_analytics

Projet dbt qui transforme les données brutes Olist (schéma `raw`, chargé par dlt) en un modèle en
étoile prêt pour l'analyse.

## Couches

Un dossier de `models/` = un schéma PostgreSQL.

| Dossier        | Matérialisation | Rôle                                                              |
| -------------- | --------------- | ----------------------------------------------------------------- |
| `staging`      | view            | 1 modèle par table source : renommage, typage, nettoyage léger    |
| `intermediate` | table           | jointures et agrégations réutilisées par plusieurs marts          |
| `marts`        | table           | modèle en étoile : faits (`fct_`) et dimensions (`dim_`)          |

```text
raw.orders ─> stg_olist__orders ─> int_orders_enriched ─┬─> fct_orders
                                                        ├─> fct_order_items
                                                        └─> dim_customers
```

## Conventions

- Modèles : `stg_<source>__<entité>`, `int_<entité>_<verbe>`, `fct_<processus>`, `dim_<entité>`.
- Chaque dossier a un fichier `_<dossier>__models.yml` (description + tests de chaque modèle).
- SQL : une CTE par `ref` / `source`, puis des CTE nommées d'après leur rôle (`renamed`,
  `aggregated`, `final`...), et un dernier `select *` sur la CTE finale.
- Colonnes : `_id` clé, `_at` horodatage, `_date` date, `is_` booléen, `_count` comptage.
- Tests : clé primaire `unique` + `not_null` sur chaque modèle, `relationships` sur les clés étrangères.

## Commandes

Deux moteurs dbt cohabitent, tous deux lisent les variables `WAREHOUSE_*` du `.env` :

- **dbt-core** (`venv/bin/dbt`, installé par `requirements.txt`) exécute le projet. Il ne lit pas
  le `.env` : lancer `set -a && source ../../../.env && set +a` avant.
- **dbt Fusion** (`~/.local/bin/dbt`, utilisé par l'extension VS Code) charge le `.env` du dossier
  courant, d'où le lien symbolique `.env -> ../../../.env` (non versionné). Son adaptateur
  postgres est expérimental : parfait dans l'éditeur (erreurs, lineage, compilation), mais en
  2.0.8 il plante dès qu'il exécute une requête (`show`, `run`, `build`).

À lancer depuis ce dossier, avec le `dbt` du venv :

```sh
dbt deps                              # installe les packages (dbt_utils)
dbt build                             # run + test de tout le projet, dans l'ordre du DAG
dbt build -s +fct_orders              # fct_orders et tout ce dont il dépend
dbt show -s dim_customers             # aperçu des données d'un modèle
dbt compile -s fct_order_items        # SQL généré dans target/compiled/
dbt docs generate && dbt docs serve   # documentation et lineage dans le navigateur
```

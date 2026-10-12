"""Load : charge les fichiers bruts du data lake S3 dans le schéma raw de PostgreSQL (dlt)."""

import logging
from collections.abc import Iterable, Iterator

import dlt
import pandas as pd
from dlt.common.storages.fsspec_filesystem import fsspec_filesystem
from dlt.sources import DltResource
from dlt.sources.filesystem import FileItemDict, filesystem

from setting.config import LAKE, WAREHOUSE
from setting.sources import LAKE_PREFIX, SOURCES

logger = logging.getLogger(__name__)

LAKE_SOURCE_URL = f"{LAKE.url}/{LAKE_PREFIX}"


@dlt.transformer
def read_csv_as_text(items: Iterable[FileItemDict], chunksize: int = 100_000) -> Iterator[pd.DataFrame]:
    """Lit chaque CSV par blocs, toutes colonnes en texte et cellules vides en NULL.

    La couche raw reste une copie fidèle de la source : le typage est fait dans dbt (staging).
    On évite ainsi les conversions implicites, ex. le code postal "01037" qui deviendrait 1037.
    """
    for item in items:
        with item.open() as file:
            yield from pd.read_csv(file, dtype=str, keep_default_na=False, na_values=[""], chunksize=chunksize)


def raw_tables() -> list[DltResource]:
    """Une ressource dlt par fichier du catalogue, nommée d'après sa table raw."""
    return [
        (
            filesystem(bucket_url=LAKE_SOURCE_URL, credentials=LAKE.credentials, file_glob=file_name)
            | read_csv_as_text()
        ).with_name(table_name)
        for file_name, table_name in SOURCES.items()
    ]


def load_to_warehouse() -> None:
    # Sans ce garde-fou, un fichier absent du lake donnerait une table manquante sans erreur
    lake_fs, _ = fsspec_filesystem(LAKE.url, LAKE.credentials)
    missing = [file_name for file_name in SOURCES if not lake_fs.exists(f"{LAKE_SOURCE_URL}/{file_name}")]
    if missing:
        raise FileNotFoundError(f"Absents du data lake (lancer l'extract d'abord) : {', '.join(missing)}")

    pipeline = dlt.pipeline(
        pipeline_name="load_to_warehouse",
        destination=dlt.destinations.postgres(credentials=WAREHOUSE.credentials),
        dataset_name=WAREHOUSE.raw_schema,
    )
    # replace : rechargement complet, rejouable sans doublons ; csv : chargement par COPY plutôt qu'INSERT
    load_info = pipeline.run(raw_tables(), write_disposition="replace", loader_file_format="csv")
    logger.info(load_info)

    row_counts = pipeline.last_trace.last_normalize_info.row_counts
    for table_name in SOURCES.values():
        logger.info("%s.%s : %s lignes", WAREHOUSE.raw_schema, table_name, row_counts.get(table_name, 0))


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    load_to_warehouse()

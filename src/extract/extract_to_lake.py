"""Extract : dépose les CSV de data/raw/ tels quels dans le data lake Garage S3 (dlt)."""

import logging

from dlt.common.storages.fsspec_filesystem import fsspec_filesystem

from setting.config import LAKE
from setting.paths import RAW_DATA_DIR
from setting.sources import LAKE_PREFIX, SOURCES

logger = logging.getLogger(__name__)


def extract_to_lake() -> None:
    """Copie chaque fichier du catalogue à l'identique dans s3://<bucket>/<LAKE_PREFIX>/."""
    # Le 1er argument est une URL de bucket (le protocole en est déduit), pas un nom de protocole
    lake_fs, _ = fsspec_filesystem(LAKE.url, LAKE.credentials)

    for file_name in SOURCES:
        local_path = RAW_DATA_DIR / file_name
        lake_url = f"{LAKE.url}/{LAKE_PREFIX}/{file_name}"
        lake_fs.put_file(str(local_path), lake_url)
        logger.info("%s -> %s (%.1f Mo)", file_name, lake_url, local_path.stat().st_size / 1e6)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    extract_to_lake()

"""Chargement du .env et exposition de la configuration (data lake, data warehouse)."""

import os
from dataclasses import dataclass, field

from dlt.destinations.impl.postgres.configuration import PostgresCredentials
from dlt.sources.credentials import AwsCredentials
from dotenv import load_dotenv

from setting.paths import ENV_FILE

# Sans effet si le .env est absent (conteneur) : les variables viennent alors de l'environnement
load_dotenv(ENV_FILE)


def _require(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"{name} manquant dans .env")
    return value


@dataclass(frozen=True)
class LakeConfig:
    endpoint_url: str
    region: str
    bucket: str
    access_key_id: str
    secret_access_key: str = field(repr=False)

    @property
    def url(self) -> str:
        return f"s3://{self.bucket}"

    @property
    def credentials(self) -> AwsCredentials:
        """Credentials dlt (s3fs) du data lake S3."""
        return AwsCredentials(
            aws_access_key_id=self.access_key_id,
            aws_secret_access_key=self.secret_access_key,
            region_name=self.region,
            endpoint_url=self.endpoint_url,
        )


@dataclass(frozen=True)
class WarehouseConfig:
    host: str
    port: int
    database: str
    user: str
    password: str = field(repr=False)
    raw_schema: str

    @property
    def credentials(self) -> PostgresCredentials:
        """Credentials dlt du data warehouse PostgreSQL."""
        return PostgresCredentials(
            {
                "host": self.host,
                "port": self.port,
                "database": self.database,
                "username": self.user,
                "password": self.password,
            }
        )


LAKE = LakeConfig(
    endpoint_url=_require("LAKE_ENDPOINT_URL"),
    region=_require("LAKE_REGION"),
    bucket=_require("LAKE_BUCKET"),
    access_key_id=_require("LAKE_ACCESS_KEY_ID"),
    secret_access_key=_require("LAKE_SECRET_ACCESS_KEY"),
)

WAREHOUSE = WarehouseConfig(
    host=_require("WAREHOUSE_HOST"),
    port=int(_require("WAREHOUSE_PORT")),
    database=_require("WAREHOUSE_DB"),
    user=_require("WAREHOUSE_USER"),
    password=_require("WAREHOUSE_PASSWORD"),
    raw_schema=_require("WAREHOUSE_RAW_SCHEMA"),
)

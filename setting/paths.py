"""Chemins absolus du projet (racine, données brutes, projet dbt...)."""

from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
ENV_FILE = ROOT_DIR / ".env"
RAW_DATA_DIR = ROOT_DIR / "data" / "raw"
DBT_PROJECT_DIR = ROOT_DIR / "src" / "transform" / "olist_analytics"

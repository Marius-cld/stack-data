"""Chemins absolus du projet (racine, .env, données brutes)."""

from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
ENV_FILE = ROOT_DIR / ".env"
RAW_DATA_DIR = ROOT_DIR / "data" / "raw"

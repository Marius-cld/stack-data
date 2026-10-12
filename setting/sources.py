"""Catalogue des sources : fichiers CSV bruts et nom de table associé."""

# Dossier du bucket où sont déposés les fichiers Olist dans le data lake
LAKE_PREFIX = "olist"

# Fichier CSV (data/raw/ puis data lake) -> table du schéma raw
SOURCES: dict[str, str] = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "product_category_name_translation",
}

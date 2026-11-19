"""Load the Olist CSV files from data/ into the raw tables of the database.

Existing rows are truncated first, so the script can be re-run safely.
All tables are loaded in one transaction: either everything loads or nothing does.
"""

import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv
from psycopg import sql

DATA_DIR = Path(__file__).resolve().parents[1] / "data"

TABLES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "product_category_name_translation": "product_category_name_translation.csv",
}


def main() -> None:
    load_dotenv()
    with (
        psycopg.connect(
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
        ) as conn,
        conn.cursor() as cur,
    ):
        for table, filename in TABLES.items():
            name = sql.Identifier(table)
            cur.execute(sql.SQL("TRUNCATE {}").format(name))

            # COPY streams the whole file at once, much faster than row-by-row INSERTs
            copy_query = sql.SQL(
                "COPY {} FROM STDIN WITH (FORMAT csv, HEADER true)"
            ).format(name)
            with (
                cur.copy(copy_query) as copy,
                open(DATA_DIR / filename, "rb") as file,
            ):
                while chunk := file.read(65536):
                    copy.write(chunk)

            cur.execute(sql.SQL("SELECT count(*) FROM {}").format(name))
            row = cur.fetchone()
            if row is None:
                raise RuntimeError(f"No row count returned for {table}")
            print(f"{table}: {row[0]} rows")


if __name__ == "__main__":
    main()
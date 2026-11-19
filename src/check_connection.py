"""Verify that the database from .env is reachable and print its version."""

import os

import psycopg
from dotenv import load_dotenv

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
    cur.execute("SELECT version();")
    row = cur.fetchone()
    if row is None:
        raise RuntimeError("The server returned no result")
    print(row[0])
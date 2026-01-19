#!/usr/bin/env python3
"""Batch ETL: PostgreSQL -> ClickHouse (append-only)."""

import argparse
import csv
import os
from typing import Iterable, List

import psycopg2
from clickhouse_driver import Client


COLUMNS = [
    "client_id",
    "month",
    "turnover_apteki",
    "turnover_restaurants",
    "turnover_clothes",
    "turnover_auto",
    "turnover_supermarkets",
    "turnover_taxi",
    "turnover_beauty",
    "turnover_entertainment",
    "turnover_rail",
    "turnover_education",
    "turnover_home",
    "turnover_sport",
    "turnover_pets",
    "turnover_flowers",
    "turnover_fastfood",
    "turnover_carsharing",
    "turnover_rent",
    "activated_apteki",
    "activated_restaurants",
    "activated_clothes",
    "activated_auto",
    "activated_supermarkets",
    "activated_taxi",
    "activated_beauty",
    "activated_entertainment",
    "activated_rail",
    "activated_education",
    "activated_home",
    "activated_sport",
    "activated_pets",
    "activated_flowers",
    "activated_fastfood",
    "activated_carsharing",
    "activated_rent",
    "cashback_apteki",
    "cashback_restaurants",
    "cashback_clothes",
    "cashback_auto",
    "cashback_supermarkets",
    "cashback_taxi",
    "cashback_beauty",
    "cashback_entertainment",
    "cashback_rail",
    "cashback_education",
    "cashback_home",
    "cashback_sport",
    "cashback_pets",
    "cashback_flowers",
    "cashback_fastfood",
    "cashback_carsharing",
    "cashback_rent",
]


def fetch_rows(conn, since_date: str | None) -> Iterable[List]:
    with conn.cursor() as cur:
        base_query = f"SELECT {', '.join(COLUMNS)} FROM cashback.fact_cashback"
        if since_date:
            # Инкрементальная выгрузка: берем только свежие месяцы.
            query = base_query + " WHERE month >= %s"
            cur.execute(query, (since_date,))
        else:
            cur.execute(base_query)
        for row in cur:
            yield list(row)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pg-dsn", default=os.getenv("PG_DSN"))
    parser.add_argument("--ch-host", default=os.getenv("CH_HOST", "localhost"))
    parser.add_argument("--ch-database", default=os.getenv("CH_DATABASE", "cashback"))
    parser.add_argument("--since-date", help="YYYY-MM-01, to export only recent months")
    args = parser.parse_args()

    if not args.pg_dsn:
        raise SystemExit("PG_DSN is required (e.g. postgresql://user:pass@host:5432/db)")

    pg_conn = psycopg2.connect(args.pg_dsn)
    ch_client = Client(host=args.ch_host, database=args.ch_database)

    # Забираем данные из Postgres и грузим в ClickHouse батчем.
    rows = list(fetch_rows(pg_conn, args.since_date))
    if not rows:
        print("No rows to export")
        return

    # Append-only загрузка в витрину ClickHouse.
    insert_query = f"INSERT INTO {args.ch_database}.fact_cashback ({', '.join(COLUMNS)}) VALUES"
    ch_client.execute(insert_query, rows)
    print(f"Inserted {len(rows)} rows into ClickHouse")


if __name__ == "__main__":
    main()

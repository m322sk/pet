# Pipeline design (concept)

## Цель
Собрать поток данных из сырых файлов в аналитическое хранилище и вывести в BI.

## Архитектура
1. **Источник**: CSV/операционная БД.
2. **Staging**: сырой слой в PostgreSQL (`cashback.cashback_staging`).
3. **Transform**: SQL-скрипты очистки в PostgreSQL (`sql/postgres_02_cleaning.sql`).
4. **Batch ETL**: Python-скрипт `scripts/etl_postgres_to_clickhouse.py` читает PostgreSQL и пишет в ClickHouse.
5. **Data Mart**: витрина `cashback.fact_cashback` в ClickHouse.
6. **BI**: Superset/Redash для дашбордов.

## Оркестрация (cron/Airflow)
- Планировщик: cron или Airflow.
- Частота: раз в N минут/часов.
- Задачи:
  - `extract_csv` → загрузка файла в PostgreSQL.
  - `transform` → запуск SQL очистки в PostgreSQL.
  - `etl_to_ch` → `python scripts/etl_postgres_to_clickhouse.py`.
  - `refresh_bi` → обновление витрин и графиков.

## Мониторинг качества
- отдельная задача `data_quality` для отчета по пропускам и дублям,
- результаты отправляются в Telegram (см. `docs/alerts.md`).

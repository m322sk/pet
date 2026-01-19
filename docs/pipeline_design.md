# Pipeline design (concept)

## Цель
Собрать поток данных из сырых файлов в аналитическое хранилище и вывести в BI.

## Архитектура
1. **Источник**: CSV/операционная БД.
2. **Staging**: сырой слой в PostgreSQL (`cashback.cashback_staging`).
3. **Transform**: SQL-скрипты очистки в PostgreSQL (`sql/postgres_02_cleaning.sql`).
4. **Data Mart**: `fact_cashback_category` (long) + `mart_client_month` с QC-метриками.
5. **BI**: Superset/Redash для дашбордов напрямую к PostgreSQL.

## Оркестрация (cron/Airflow)
- Планировщик: cron или Airflow.
- Частота: раз в N минут/часов.
- Задачи:
  - `extract_csv` → загрузка файла в PostgreSQL.
  - `transform` → запуск SQL очистки в PostgreSQL.
  - `refresh_bi` → обновление витрин и графиков.

## Мониторинг качества
- отдельная задача `data_quality` для отчета по пропускам и дублям,
- результаты отправляются в Telegram (см. `docs/alerts.md`).

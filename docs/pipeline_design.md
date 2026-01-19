# Pipeline design (concept)

## Цель
Собрать поток данных из сырых файлов в аналитическое хранилище и вывести в BI.

## Архитектура
1. **Источник**: CSV/операционная БД.
2. **Staging**: сырой слой в ClickHouse (`cashback_staging`).
3. **Transform**: SQL-скрипты очистки (`sql/02_cleaning.sql`).
4. **Data Mart**: витрина `fact_cashback` + `dim_clients`.
5. **BI**: Superset/Redash для дашбордов.

## Оркестрация (Airflow)
- DAG с ежедневным расписанием.
- Задачи:
  - `extract_csv` → загрузка файла.
  - `load_staging` → вставка в ClickHouse.
  - `transform` → запуск SQL очистки.
  - `refresh_bi` → обновление витрин и графиков.

## Мониторинг качества
- отдельная задача `data_quality` для отчета по пропускам и дублям,
- результаты отправляются в Telegram (см. `docs/alerts.md`).

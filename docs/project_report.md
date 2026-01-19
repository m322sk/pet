# Пет-проект: аналитика кэшбэка Tinkoff Black

## 0. Входные данные

**Источник**: `tinkoff2_cashback.csv` + описание полей из `T_cashback_Описание_датасета.pdf`.

Ключевые особенности датасета:
- Месячная агрегация (апрель–сентябрь), в строке — клиент и месяц покупок.
- Для каждой категории есть три группы полей: **оборот**, **активация кэшбэка** и **полученный кэшбэк**.
- В полях активации встречаются пропуски (категория недоступна), 0 (доступна, но не выбрана), 1 (доступна и выбрана).

Эта специфика важна для очистки и интерпретации данных: значения `NULL` нельзя смешивать с `0` — это разные состояния выбора категории.

## 1. Работа с данными (SQL + немного Python)

### 1.1. Подготовка схемы
- **Staging-таблица** хранит сырые значения строками, чтобы не терять пропуски и избежать ошибок парсинга.
- **Нормализованная модель**:
  - `dim_clients` — уникальные клиенты.
  - `dim_months` — справочник месяцев.
  - `fact_cashback` — фактические обороты/активации/кэшбэк по клиенту и месяцу.

PostgreSQL-скрипт схемы находится в `sql/postgres_01_schema.sql`.

### 1.2. Очистка
Цели очистки:
- привести типы (даты, целые, float),
- корректно отличить `NULL` от `0` в активациях,
- убрать дубликаты по ключу `(client_id, month)`

SQL очистки для PostgreSQL находится в `sql/postgres_02_cleaning.sql`.

### 1.3. Python-скрипт для выгрузки/проверок
`scripts/profile_data.py`:
- читает CSV стандартным модулем `csv`,
- считает базовые показатели качества (доля пропусков, дубликаты ключей),
- сохраняет сводку в `docs/data_quality_report.md`.

## 2. Дашборды (ClickHouse как аналитическая витрина)

Поскольку данные агрегированы по месяцам, я использую **MAU** вместо DAU/WAU.
Ключевые метрики:
- MAU по месяцам (активные клиенты с оборотом > 0)
- средний оборот по клиенту
- доля клиентов, активировавших кэшбэк в категории
- распределение оборотов по категориям

SQL для витрины в ClickHouse — `sql/clickhouse_02_metrics.sql`.

## 3. A/B тест (SQL + немного Python)

**Гипотеза**: клиенты, получившие категории с повышенным кэшбэком, увеличат оборот в этих категориях.

### 3.1. План эксперимента
- Сплит по `hashtext(client_id)` для стабильного разбиения в PostgreSQL.
- Контроль/тест с равными долями.
- Метрика: средний оборот в «активированных» категориях.

### 3.2. Подготовка данных (SQL)
- Расчет пользовательских метрик по месяцу.
- Выгрузка в CSV для t-теста.

SQL для PostgreSQL — `sql/postgres_04_ab_test.sql`.

### 3.3. Статтест (Python)
`scripts/ab_test.py`:
- принимает CSV с метрикой,
- считает t-статистику и p-value (нормальная аппроксимация),
- выводит интерпретацию.

## 4. Пайплайн (PostgreSQL → ClickHouse, batch/cron)

Цель — показать, как выстроить поток данных:
1. **Источник**: CSV загружается в PostgreSQL (основная БД).
2. **Transform**: очистка в PostgreSQL (`sql/postgres_02_cleaning.sql`).
3. **Batch ETL**: Python-скрипт раз в N минут/часов читает PostgreSQL и пишет в ClickHouse.
4. **BI**: Superset/Redash подключаются к ClickHouse.

Подробности в `docs/pipeline_design.md`.

## 5. Система алертов

- ежедневные алерты по провалам MAU и оборота,
- правило «3σ» для поиска аномалий,
- отправка в Telegram через cron/Airflow (описание и пример SQL).

SQL и правила для PostgreSQL — `sql/postgres_05_alerts.sql`, описание — `docs/alerts.md`.

---

## Как запустить

### Что понадобится
- **PostgreSQL** (основная БД), доступ через `psql` или DBeaver.
- **ClickHouse** (аналитическая витрина), доступ через `clickhouse-client` или DBeaver.
- **Python 3.10+**.
- Python-пакеты: `psycopg2-binary`, `clickhouse-driver` (см. `requirements.txt`).
- (Опционально) **cron** или **Airflow** для регулярного запуска ETL.

### PostgreSQL (основная БД)
1. Создать таблицы:
```sql
source sql/postgres_01_schema.sql
```
2. Загрузить CSV в staging (пример через `psql`):
```sql
\\copy cashback.cashback_staging FROM 'tinkoff2_cashback.csv' WITH (FORMAT csv, HEADER true)
```
3. Установить зависимости Python:
```bash
python -m pip install -r requirements.txt
```
4. Очистить и наполнить модель:
```sql
source sql/postgres_02_cleaning.sql
```
5. Метрики и дашборды — `sql/postgres_03_metrics.sql`.
6. A/B тест — `sql/postgres_04_ab_test.sql` + `python scripts/ab_test.py --input ab_export.csv`.

### ClickHouse (витрина)
1. Создать таблицы витрины:
```sql
source sql/clickhouse_01_schema.sql
```
2. ETL из PostgreSQL в ClickHouse:
```bash
python scripts/etl_postgres_to_clickhouse.py --pg-dsn \"postgresql://user:pass@host:5432/db\" \\
  --ch-host localhost --ch-database cashback --since-date 2023-04-01
```
3. Метрики для витрины — `sql/clickhouse_02_metrics.sql`.

### Пример cron (раз в час)
```cron
0 * * * * /usr/bin/python /path/to/project/scripts/etl_postgres_to_clickhouse.py --pg-dsn \"postgresql://user:pass@host:5432/db\" --ch-host localhost --ch-database cashback >> /var/log/cashback_etl.log 2>&1
```

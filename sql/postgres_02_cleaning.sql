-- PostgreSQL: очистка и наполнение витрин.

INSERT INTO cashback.dim_clients (client_id, region, city, age, gender)
SELECT DISTINCT
    ключ_клиента::BIGINT AS client_id,
    NULLIF(регион_проживания, '') AS region,
    NULLIF(город_проживания, '') AS city,
    NULLIF(возраст, '')::SMALLINT AS age,
    NULLIF(пол, '') AS gender
FROM cashback.cashback_staging
ON CONFLICT (client_id) DO NOTHING;

INSERT INTO cashback.dim_months (month)
SELECT DISTINCT
    месяц_покупок::DATE AS month
FROM cashback.cashback_staging
ON CONFLICT (month) DO NOTHING;

INSERT INTO cashback.fact_cashback (
    client_id,
    month,
    turnover_apteki,
    turnover_restaurants,
    turnover_clothes,
    turnover_auto,
    turnover_supermarkets,
    turnover_taxi,
    turnover_beauty,
    turnover_entertainment,
    turnover_rail,
    turnover_education,
    turnover_home,
    turnover_sport,
    turnover_pets,
    turnover_flowers,
    turnover_fastfood,
    turnover_carsharing,
    turnover_rent,
    activated_apteki,
    activated_restaurants,
    activated_clothes,
    activated_auto,
    activated_supermarkets,
    activated_taxi,
    activated_beauty,
    activated_entertainment,
    activated_rail,
    activated_education,
    activated_home,
    activated_sport,
    activated_pets,
    activated_flowers,
    activated_fastfood,
    activated_carsharing,
    activated_rent,
    cashback_apteki,
    cashback_restaurants,
    cashback_clothes,
    cashback_auto,
    cashback_supermarkets,
    cashback_taxi,
    cashback_beauty,
    cashback_entertainment,
    cashback_rail,
    cashback_education,
    cashback_home,
    cashback_sport,
    cashback_pets,
    cashback_flowers,
    cashback_fastfood,
    cashback_carsharing,
    cashback_rent
)
SELECT
    ключ_клиента::BIGINT AS client_id,
    месяц_покупок::DATE AS month,
    COALESCE(NULLIF(оборот_аптеки, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_рестораны, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_одежда_и_обувь, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_автоуслуги, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_супермаркеты, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_такси, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_красота, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_развлечения, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_жд_билеты, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_образование, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_дом_и_ремонт, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_спорттовары, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_животные, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_цветы, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_фастфуд, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_каршеринг, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(оборот_аренда_авто, '')::DOUBLE PRECISION, 0),
    NULLIF(активация_кэшбэка_аптеки, '')::SMALLINT,
    NULLIF(активация_кэшбэка_рестораны, '')::SMALLINT,
    NULLIF(активация_кэшбэка_одежда_и_обувь, '')::SMALLINT,
    NULLIF(активация_кэшбэка_автоуслуги, '')::SMALLINT,
    NULLIF(активация_кэшбэка_супермаркеты, '')::SMALLINT,
    NULLIF(активация_кэшбэка_такси, '')::SMALLINT,
    NULLIF(активация_кэшбэка_красота, '')::SMALLINT,
    NULLIF(активация_кэшбэка_развлечения, '')::SMALLINT,
    NULLIF(активация_кэшбэка_жд_билеты, '')::SMALLINT,
    NULLIF(активация_кэшбэка_образование, '')::SMALLINT,
    NULLIF(активация_кэшбэка_дом_и_ремонт, '')::SMALLINT,
    NULLIF(активация_кэшбэка_спорттовары, '')::SMALLINT,
    NULLIF(активация_кэшбэка_животные, '')::SMALLINT,
    NULLIF(активация_кэшбэка_цветы, '')::SMALLINT,
    NULLIF(активация_кэшбэка_фастфуд, '')::SMALLINT,
    NULLIF(активация_кэшбэка_каршеринг, '')::SMALLINT,
    NULLIF(активация_кэшбэка_аренда_авто, '')::SMALLINT,
    COALESCE(NULLIF(кэшбэк_аптеки, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_рестораны, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_одежда_и_обувь, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_автоуслуги, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_супермаркеты, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_такси, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_красота, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_развлечения, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_жд_билеты, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_образование, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_дом_и_ремонт, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_спорттовары, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_животные, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_цветы, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_фастфуд, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_каршеринг, '')::DOUBLE PRECISION, 0),
    COALESCE(NULLIF(кэшбэк_аренда_авто, '')::DOUBLE PRECISION, 0)
FROM cashback.cashback_staging
ON CONFLICT (client_id, month) DO NOTHING;

-- Наполняем нормализованный факт по категориям и activation_state.
INSERT INTO cashback.fact_cashback_category (
    client_id,
    month,
    category,
    turnover,
    cashback,
    activation_state
)
SELECT
    base.client_id,
    base.month,
    base.category,
    base.turnover,
    base.cashback,
    CASE
        WHEN base.activation IS NULL THEN 'not_offered'
        WHEN base.activation = 0 THEN 'offered_not_chosen'
        WHEN base.activation = 1 THEN 'chosen'
        ELSE 'unknown'
    END AS activation_state
FROM (
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'apteki' AS category,
        COALESCE(NULLIF(оборот_аптеки, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_аптеки, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_аптеки, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'restaurants' AS category,
        COALESCE(NULLIF(оборот_рестораны, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_рестораны, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_рестораны, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'clothes' AS category,
        COALESCE(NULLIF(оборот_одежда_и_обувь, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_одежда_и_обувь, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_одежда_и_обувь, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'auto' AS category,
        COALESCE(NULLIF(оборот_автоуслуги, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_автоуслуги, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_автоуслуги, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'supermarkets' AS category,
        COALESCE(NULLIF(оборот_супермаркеты, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_супермаркеты, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_супермаркеты, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'taxi' AS category,
        COALESCE(NULLIF(оборот_такси, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_такси, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_такси, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'beauty' AS category,
        COALESCE(NULLIF(оборот_красота, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_красота, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_красота, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'entertainment' AS category,
        COALESCE(NULLIF(оборот_развлечения, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_развлечения, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_развлечения, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'rail' AS category,
        COALESCE(NULLIF(оборот_жд_билеты, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_жд_билеты, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_жд_билеты, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'education' AS category,
        COALESCE(NULLIF(оборот_образование, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_образование, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_образование, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'home' AS category,
        COALESCE(NULLIF(оборот_дом_и_ремонт, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_дом_и_ремонт, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_дом_и_ремонт, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'sport' AS category,
        COALESCE(NULLIF(оборот_спорттовары, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_спорттовары, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_спорттовары, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'pets' AS category,
        COALESCE(NULLIF(оборот_животные, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_животные, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_животные, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'flowers' AS category,
        COALESCE(NULLIF(оборот_цветы, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_цветы, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_цветы, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'fastfood' AS category,
        COALESCE(NULLIF(оборот_фастфуд, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_фастфуд, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_фастфуд, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'carsharing' AS category,
        COALESCE(NULLIF(оборот_каршеринг, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_каршеринг, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_каршеринг, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
    UNION ALL
    SELECT
        ключ_клиента::BIGINT AS client_id,
        месяц_покупок::DATE AS month,
        'rent' AS category,
        COALESCE(NULLIF(оборот_аренда_авто, '')::DOUBLE PRECISION, 0) AS turnover,
        COALESCE(NULLIF(кэшбэк_аренда_авто, '')::DOUBLE PRECISION, 0) AS cashback,
        NULLIF(активация_кэшбэка_аренда_авто, '')::SMALLINT AS activation
    FROM cashback.cashback_staging
) AS base
ON CONFLICT (client_id, month, category) DO NOTHING;

-- Витрина клиент-месяц с QC: eligible_cnt должен быть 7 или 8.
INSERT INTO cashback.mart_client_month (
    client_id,
    month,
    total_turnover,
    total_cashback,
    eligible_cnt,
    chosen_cnt,
    has_subscription_guess
)
SELECT
    client_id,
    month,
    SUM(turnover) AS total_turnover,
    SUM(cashback) AS total_cashback,
    SUM(CASE WHEN activation_state != 'not_offered' THEN 1 ELSE 0 END)::SMALLINT AS eligible_cnt,
    SUM(CASE WHEN activation_state = 'chosen' THEN 1 ELSE 0 END)::SMALLINT AS chosen_cnt,
    SUM(CASE WHEN activation_state != 'not_offered' THEN 1 ELSE 0 END) = 8 AS has_subscription_guess
FROM cashback.fact_cashback_category
GROUP BY client_id, month
ON CONFLICT (client_id, month) DO NOTHING;

-- QC-проверка: допустимые значения 7 или 8.
SELECT eligible_cnt, COUNT(*) AS rows
FROM cashback.mart_client_month
GROUP BY eligible_cnt
ORDER BY eligible_cnt;

SELECT COUNT(DISTINCT client_id) AS clients, COUNT(*) AS rows
FROM cashback.fact_cashback;

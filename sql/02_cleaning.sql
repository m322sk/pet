-- Очистка данных и наполнение витрин.

INSERT INTO cashback.dim_clients
SELECT
    toUInt64(ключ_клиента) AS client_id,
    region,
    city,
    age,
    gender
FROM (
    SELECT DISTINCT
        ключ_клиента,
        `регион_проживания` AS region,
        `город_проживания` AS city,
        toUInt8OrNull(nullIf(`возраст`, '')) AS age,
        nullIf(`пол`, '') AS gender
    FROM cashback.cashback_staging
) AS dedup
WHERE client_id NOT IN (SELECT client_id FROM cashback.dim_clients);

INSERT INTO cashback.dim_months
SELECT DISTINCT toDate(месяц_покупок) AS month
FROM cashback.cashback_staging
WHERE month NOT IN (SELECT month FROM cashback.dim_months);

-- Заполняем фактовую таблицу.
INSERT INTO cashback.fact_cashback
SELECT
    toUInt64(ключ_клиента) AS client_id,
    toDate(месяц_покупок) AS month,
    -- Приводим обороты к числам, пропуски -> 0 для удобства агрегаций.
    coalesce(toFloat64OrNull(nullIf(`оборот_аптеки`, '')), 0) AS turnover_apteki,
    coalesce(toFloat64OrNull(nullIf(`оборот_рестораны`, '')), 0) AS turnover_restaurants,
    coalesce(toFloat64OrNull(nullIf(`оборот_одежда_и_обувь`, '')), 0) AS turnover_clothes,
    coalesce(toFloat64OrNull(nullIf(`оборот_автоуслуги`, '')), 0) AS turnover_auto,
    coalesce(toFloat64OrNull(nullIf(`оборот_супермаркеты`, '')), 0) AS turnover_supermarkets,
    coalesce(toFloat64OrNull(nullIf(`оборот_такси`, '')), 0) AS turnover_taxi,
    coalesce(toFloat64OrNull(nullIf(`оборот_красота`, '')), 0) AS turnover_beauty,
    coalesce(toFloat64OrNull(nullIf(`оборот_развлечения`, '')), 0) AS turnover_entertainment,
    coalesce(toFloat64OrNull(nullIf(`оборот_жд_билеты`, '')), 0) AS turnover_rail,
    coalesce(toFloat64OrNull(nullIf(`оборот_образование`, '')), 0) AS turnover_education,
    coalesce(toFloat64OrNull(nullIf(`оборот_дом_и_ремонт`, '')), 0) AS turnover_home,
    coalesce(toFloat64OrNull(nullIf(`оборот_спорттовары`, '')), 0) AS turnover_sport,
    coalesce(toFloat64OrNull(nullIf(`оборот_животные`, '')), 0) AS turnover_pets,
    coalesce(toFloat64OrNull(nullIf(`оборот_цветы`, '')), 0) AS turnover_flowers,
    coalesce(toFloat64OrNull(nullIf(`оборот_фастфуд`, '')), 0) AS turnover_fastfood,
    coalesce(toFloat64OrNull(nullIf(`оборот_каршеринг`, '')), 0) AS turnover_carsharing,
    coalesce(toFloat64OrNull(nullIf(`оборот_аренда_авто`, '')), 0) AS turnover_rent,
    -- Активации: NULL означает «категория недоступна», 0/1 — доступна.
    toUInt8OrNull(nullIf(`активация_кэшбэка_аптеки`, '')) AS activated_apteki,
    toUInt8OrNull(nullIf(`активация_кэшбэка_рестораны`, '')) AS activated_restaurants,
    toUInt8OrNull(nullIf(`активация_кэшбэка_одежда_и_обувь`, '')) AS activated_clothes,
    toUInt8OrNull(nullIf(`активация_кэшбэка_автоуслуги`, '')) AS activated_auto,
    toUInt8OrNull(nullIf(`активация_кэшбэка_супермаркеты`, '')) AS activated_supermarkets,
    toUInt8OrNull(nullIf(`активация_кэшбэка_такси`, '')) AS activated_taxi,
    toUInt8OrNull(nullIf(`активация_кэшбэка_красота`, '')) AS activated_beauty,
    toUInt8OrNull(nullIf(`активация_кэшбэка_развлечения`, '')) AS activated_entertainment,
    toUInt8OrNull(nullIf(`активация_кэшбэка_жд_билеты`, '')) AS activated_rail,
    toUInt8OrNull(nullIf(`активация_кэшбэка_образование`, '')) AS activated_education,
    toUInt8OrNull(nullIf(`активация_кэшбэка_дом_и_ремонт`, '')) AS activated_home,
    toUInt8OrNull(nullIf(`активация_кэшбэка_спорттовары`, '')) AS activated_sport,
    toUInt8OrNull(nullIf(`активация_кэшбэка_животные`, '')) AS activated_pets,
    toUInt8OrNull(nullIf(`активация_кэшбэка_цветы`, '')) AS activated_flowers,
    toUInt8OrNull(nullIf(`активация_кэшбэка_фастфуд`, '')) AS activated_fastfood,
    toUInt8OrNull(nullIf(`активация_кэшбэка_каршеринг`, '')) AS activated_carsharing,
    toUInt8OrNull(nullIf(`активация_кэшбэка_аренда_авто`, '')) AS activated_rent,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_аптеки`, '')), 0) AS cashback_apteki,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_рестораны`, '')), 0) AS cashback_restaurants,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_одежда_и_обувь`, '')), 0) AS cashback_clothes,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_автоуслуги`, '')), 0) AS cashback_auto,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_супермаркеты`, '')), 0) AS cashback_supermarkets,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_такси`, '')), 0) AS cashback_taxi,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_красота`, '')), 0) AS cashback_beauty,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_развлечения`, '')), 0) AS cashback_entertainment,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_жд_билеты`, '')), 0) AS cashback_rail,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_образование`, '')), 0) AS cashback_education,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_дом_и_ремонт`, '')), 0) AS cashback_home,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_спорттовары`, '')), 0) AS cashback_sport,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_животные`, '')), 0) AS cashback_pets,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_цветы`, '')), 0) AS cashback_flowers,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_фастфуд`, '')), 0) AS cashback_fastfood,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_каршеринг`, '')), 0) AS cashback_carsharing,
    coalesce(toFloat64OrNull(nullIf(`кэшбэк_аренда_авто`, '')), 0) AS cashback_rent
FROM cashback.cashback_staging;

-- Контроль качества: количество клиентов и строк.
SELECT countDistinct(client_id) AS clients, count() AS rows
FROM cashback.fact_cashback;

-- PostgreSQL: подготовка данных для A/B теста.

-- Стабильный сплит по клиенту.
WITH ab_split AS (
    SELECT
        client_id,
        CASE WHEN (ABS(hashtext(client_id::TEXT)) % 2) = 0 THEN 'control' ELSE 'test' END AS ab_group
    FROM cashback.fact_cashback
)
SELECT
    ab_split.ab_group AS group,
    f.month,
    f.client_id,
    (
        CASE WHEN f.activated_apteki = 1 THEN f.turnover_apteki ELSE 0 END
        + CASE WHEN f.activated_restaurants = 1 THEN f.turnover_restaurants ELSE 0 END
        + CASE WHEN f.activated_clothes = 1 THEN f.turnover_clothes ELSE 0 END
        + CASE WHEN f.activated_auto = 1 THEN f.turnover_auto ELSE 0 END
        + CASE WHEN f.activated_supermarkets = 1 THEN f.turnover_supermarkets ELSE 0 END
        + CASE WHEN f.activated_taxi = 1 THEN f.turnover_taxi ELSE 0 END
        + CASE WHEN f.activated_beauty = 1 THEN f.turnover_beauty ELSE 0 END
        + CASE WHEN f.activated_entertainment = 1 THEN f.turnover_entertainment ELSE 0 END
        + CASE WHEN f.activated_rail = 1 THEN f.turnover_rail ELSE 0 END
        + CASE WHEN f.activated_education = 1 THEN f.turnover_education ELSE 0 END
        + CASE WHEN f.activated_home = 1 THEN f.turnover_home ELSE 0 END
        + CASE WHEN f.activated_sport = 1 THEN f.turnover_sport ELSE 0 END
        + CASE WHEN f.activated_pets = 1 THEN f.turnover_pets ELSE 0 END
        + CASE WHEN f.activated_flowers = 1 THEN f.turnover_flowers ELSE 0 END
        + CASE WHEN f.activated_fastfood = 1 THEN f.turnover_fastfood ELSE 0 END
        + CASE WHEN f.activated_carsharing = 1 THEN f.turnover_carsharing ELSE 0 END
        + CASE WHEN f.activated_rent = 1 THEN f.turnover_rent ELSE 0 END
    ) AS metric
FROM cashback.fact_cashback AS f
JOIN ab_split ON ab_split.client_id = f.client_id
WHERE f.month = DATE '2023-06-01';

-- Итоговые агрегаты для sanity-check.
WITH ab_split AS (
    SELECT
        client_id,
        CASE WHEN (ABS(hashtext(client_id::TEXT)) % 2) = 0 THEN 'control' ELSE 'test' END AS ab_group
    FROM cashback.fact_cashback
)
SELECT
    ab_split.ab_group,
    COUNT(*) AS users,
    AVG(metric) AS avg_metric
FROM (
    SELECT
        f.client_id,
        (
            CASE WHEN f.activated_apteki = 1 THEN f.turnover_apteki ELSE 0 END
            + CASE WHEN f.activated_restaurants = 1 THEN f.turnover_restaurants ELSE 0 END
            + CASE WHEN f.activated_clothes = 1 THEN f.turnover_clothes ELSE 0 END
            + CASE WHEN f.activated_auto = 1 THEN f.turnover_auto ELSE 0 END
            + CASE WHEN f.activated_supermarkets = 1 THEN f.turnover_supermarkets ELSE 0 END
            + CASE WHEN f.activated_taxi = 1 THEN f.turnover_taxi ELSE 0 END
            + CASE WHEN f.activated_beauty = 1 THEN f.turnover_beauty ELSE 0 END
            + CASE WHEN f.activated_entertainment = 1 THEN f.turnover_entertainment ELSE 0 END
            + CASE WHEN f.activated_rail = 1 THEN f.turnover_rail ELSE 0 END
            + CASE WHEN f.activated_education = 1 THEN f.turnover_education ELSE 0 END
            + CASE WHEN f.activated_home = 1 THEN f.turnover_home ELSE 0 END
            + CASE WHEN f.activated_sport = 1 THEN f.turnover_sport ELSE 0 END
            + CASE WHEN f.activated_pets = 1 THEN f.turnover_pets ELSE 0 END
            + CASE WHEN f.activated_flowers = 1 THEN f.turnover_flowers ELSE 0 END
            + CASE WHEN f.activated_fastfood = 1 THEN f.turnover_fastfood ELSE 0 END
            + CASE WHEN f.activated_carsharing = 1 THEN f.turnover_carsharing ELSE 0 END
            + CASE WHEN f.activated_rent = 1 THEN f.turnover_rent ELSE 0 END
        ) AS metric
    FROM cashback.fact_cashback AS f
    WHERE f.month = DATE '2023-06-01'
) AS metrics
JOIN ab_split ON ab_split.client_id = metrics.client_id
GROUP BY ab_split.ab_group;

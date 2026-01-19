-- PostgreSQL: метрики для дашбордов.

-- MAU: активные клиенты с оборотом > 0.
SELECT
    month,
    COUNT(DISTINCT CASE WHEN turnover_total > 0 THEN client_id END) AS mau
FROM (
    SELECT
        month,
        client_id,
        turnover_apteki
        + turnover_restaurants
        + turnover_clothes
        + turnover_auto
        + turnover_supermarkets
        + turnover_taxi
        + turnover_beauty
        + turnover_entertainment
        + turnover_rail
        + turnover_education
        + turnover_home
        + turnover_sport
        + turnover_pets
        + turnover_flowers
        + turnover_fastfood
        + turnover_carsharing
        + turnover_rent AS turnover_total
    FROM cashback.fact_cashback
) AS totals
GROUP BY month
ORDER BY month;

-- Средний оборот по клиенту.
SELECT
    month,
    AVG(turnover_total) AS avg_turnover
FROM (
    SELECT
        month,
        client_id,
        turnover_apteki
        + turnover_restaurants
        + turnover_clothes
        + turnover_auto
        + turnover_supermarkets
        + turnover_taxi
        + turnover_beauty
        + turnover_entertainment
        + turnover_rail
        + turnover_education
        + turnover_home
        + turnover_sport
        + turnover_pets
        + turnover_flowers
        + turnover_fastfood
        + turnover_carsharing
        + turnover_rent AS turnover_total
    FROM cashback.fact_cashback
) AS totals
GROUP BY month
ORDER BY month;

-- Доля активаций по категориям (учитываем только доступные категории).
SELECT
    month,
    SUM(CASE WHEN activated_apteki = 1 THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN activated_apteki IS NOT NULL THEN 1 ELSE 0 END), 0) AS share_apteki,
    SUM(CASE WHEN activated_restaurants = 1 THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN activated_restaurants IS NOT NULL THEN 1 ELSE 0 END), 0) AS share_restaurants,
    SUM(CASE WHEN activated_clothes = 1 THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN activated_clothes IS NOT NULL THEN 1 ELSE 0 END), 0) AS share_clothes,
    SUM(CASE WHEN activated_auto = 1 THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN activated_auto IS NOT NULL THEN 1 ELSE 0 END), 0) AS share_auto,
    SUM(CASE WHEN activated_supermarkets = 1 THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN activated_supermarkets IS NOT NULL THEN 1 ELSE 0 END), 0) AS share_supermarkets
FROM cashback.fact_cashback
GROUP BY month
ORDER BY month;

-- Топ категорий по обороту.
SELECT
    month,
    category,
    turnover
FROM (
    SELECT month, 'apteki' AS category, SUM(turnover_apteki) AS turnover FROM cashback.fact_cashback GROUP BY month
    UNION ALL
    SELECT month, 'restaurants' AS category, SUM(turnover_restaurants) AS turnover FROM cashback.fact_cashback GROUP BY month
    UNION ALL
    SELECT month, 'clothes' AS category, SUM(turnover_clothes) AS turnover FROM cashback.fact_cashback GROUP BY month
    UNION ALL
    SELECT month, 'supermarkets' AS category, SUM(turnover_supermarkets) AS turnover FROM cashback.fact_cashback GROUP BY month
) AS categories
ORDER BY month, turnover DESC;

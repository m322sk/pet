-- Основные метрики для дашбордов.

-- MAU: активные клиенты с оборотом > 0.
SELECT
    month,
    countDistinctIf(client_id, turnover_total > 0) AS mau
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
)
GROUP BY month
ORDER BY month;

-- Средний оборот по клиенту.
SELECT
    month,
    avg(turnover_total) AS avg_turnover
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
)
GROUP BY month
ORDER BY month;

-- Доля активаций по категориям (учитываем только доступные категории).
SELECT
    month,
    sum(activated_apteki = 1) / sum(activated_apteki IS NOT NULL) AS share_apteki,
    sum(activated_restaurants = 1) / sum(activated_restaurants IS NOT NULL) AS share_restaurants,
    sum(activated_clothes = 1) / sum(activated_clothes IS NOT NULL) AS share_clothes,
    sum(activated_auto = 1) / sum(activated_auto IS NOT NULL) AS share_auto,
    sum(activated_supermarkets = 1) / sum(activated_supermarkets IS NOT NULL) AS share_supermarkets
FROM cashback.fact_cashback
GROUP BY month
ORDER BY month;

-- Топ категорий по обороту.
SELECT
    month,
    arraySort(groupArray((category, turnover))) AS turnover_by_category
FROM (
    SELECT month, 'apteki' AS category, sum(turnover_apteki) AS turnover FROM cashback.fact_cashback GROUP BY month
    UNION ALL
    SELECT month, 'restaurants' AS category, sum(turnover_restaurants) AS turnover FROM cashback.fact_cashback GROUP BY month
    UNION ALL
    SELECT month, 'clothes' AS category, sum(turnover_clothes) AS turnover FROM cashback.fact_cashback GROUP BY month
    UNION ALL
    SELECT month, 'supermarkets' AS category, sum(turnover_supermarkets) AS turnover FROM cashback.fact_cashback GROUP BY month
)
GROUP BY month
ORDER BY month;

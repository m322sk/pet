-- ClickHouse: метрики для витрины.

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

-- Подготовка данных для A/B теста.

-- Стабильный сплит по клиенту.
WITH
    cityHash64(toString(client_id)) AS hash,
    if(hash % 2 = 0, 'control', 'test') AS ab_group
SELECT
    ab_group AS group,
    month,
    client_id,
    -- Метрика: оборот в активированных категориях.
    (
        if(activated_apteki = 1, turnover_apteki, 0)
        + if(activated_restaurants = 1, turnover_restaurants, 0)
        + if(activated_clothes = 1, turnover_clothes, 0)
        + if(activated_auto = 1, turnover_auto, 0)
        + if(activated_supermarkets = 1, turnover_supermarkets, 0)
        + if(activated_taxi = 1, turnover_taxi, 0)
        + if(activated_beauty = 1, turnover_beauty, 0)
        + if(activated_entertainment = 1, turnover_entertainment, 0)
        + if(activated_rail = 1, turnover_rail, 0)
        + if(activated_education = 1, turnover_education, 0)
        + if(activated_home = 1, turnover_home, 0)
        + if(activated_sport = 1, turnover_sport, 0)
        + if(activated_pets = 1, turnover_pets, 0)
        + if(activated_flowers = 1, turnover_flowers, 0)
        + if(activated_fastfood = 1, turnover_fastfood, 0)
        + if(activated_carsharing = 1, turnover_carsharing, 0)
        + if(activated_rent = 1, turnover_rent, 0)
    ) AS metric
FROM cashback.fact_cashback
WHERE month = toDate('2023-06-01');

-- Итоговые агрегаты для sanity-check.
WITH
    cityHash64(toString(client_id)) AS hash,
    if(hash % 2 = 0, 'control', 'test') AS ab_group
SELECT
    ab_group,
    count() AS users,
    avg(metric) AS avg_metric
FROM (
    SELECT
        client_id,
        (
            if(activated_apteki = 1, turnover_apteki, 0)
            + if(activated_restaurants = 1, turnover_restaurants, 0)
            + if(activated_clothes = 1, turnover_clothes, 0)
            + if(activated_auto = 1, turnover_auto, 0)
            + if(activated_supermarkets = 1, turnover_supermarkets, 0)
            + if(activated_taxi = 1, turnover_taxi, 0)
            + if(activated_beauty = 1, turnover_beauty, 0)
            + if(activated_entertainment = 1, turnover_entertainment, 0)
            + if(activated_rail = 1, turnover_rail, 0)
            + if(activated_education = 1, turnover_education, 0)
            + if(activated_home = 1, turnover_home, 0)
            + if(activated_sport = 1, turnover_sport, 0)
            + if(activated_pets = 1, turnover_pets, 0)
            + if(activated_flowers = 1, turnover_flowers, 0)
            + if(activated_fastfood = 1, turnover_fastfood, 0)
            + if(activated_carsharing = 1, turnover_carsharing, 0)
            + if(activated_rent = 1, turnover_rent, 0)
        ) AS metric
    FROM cashback.fact_cashback
    WHERE month = toDate('2023-06-01')
)
GROUP BY ab_group;

-- PostgreSQL: метрики для дашбордов.

-- MAU: активные клиенты с оборотом > 0.
SELECT
    month,
    COUNT(DISTINCT CASE WHEN total_turnover > 0 THEN client_id END) AS mau
FROM cashback.mart_client_month
GROUP BY month
ORDER BY month;

-- Средний оборот по клиенту.
SELECT
    month,
    AVG(total_turnover) AS avg_turnover
FROM cashback.mart_client_month
GROUP BY month
ORDER BY month;

-- Доля активаций по категориям (учитываем только доступные категории).
SELECT
    month,
    SUM(CASE WHEN category = 'apteki' AND activation_state = 'chosen' THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN category = 'apteki' AND activation_state != 'not_offered' THEN 1 ELSE 0 END), 0)
        AS share_apteki,
    SUM(CASE WHEN category = 'restaurants' AND activation_state = 'chosen' THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN category = 'restaurants' AND activation_state != 'not_offered' THEN 1 ELSE 0 END), 0)
        AS share_restaurants,
    SUM(CASE WHEN category = 'clothes' AND activation_state = 'chosen' THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN category = 'clothes' AND activation_state != 'not_offered' THEN 1 ELSE 0 END), 0)
        AS share_clothes,
    SUM(CASE WHEN category = 'auto' AND activation_state = 'chosen' THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN category = 'auto' AND activation_state != 'not_offered' THEN 1 ELSE 0 END), 0)
        AS share_auto,
    SUM(CASE WHEN category = 'supermarkets' AND activation_state = 'chosen' THEN 1 ELSE 0 END)::DECIMAL
        / NULLIF(SUM(CASE WHEN category = 'supermarkets' AND activation_state != 'not_offered' THEN 1 ELSE 0 END), 0)
        AS share_supermarkets
FROM cashback.fact_cashback_category
GROUP BY month
ORDER BY month;

-- Топ категорий по обороту.
SELECT
    month,
    category,
    SUM(turnover) AS turnover
FROM cashback.fact_cashback_category
GROUP BY month, category
ORDER BY month, turnover DESC;

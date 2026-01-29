-- PostgreSQL: observational / quasi-experiment analysis.

-- 1) Within-user: сравнение оборота в выбранных категориях до/после выбора.
WITH chosen_categories AS (
    SELECT
        client_id,
        month,
        category
    FROM cashback.fact_cashback_category
    WHERE activation_state = 'chosen'
),
category_turnover AS (
    SELECT
        f.client_id,
        f.month,
        f.category,
        f.turnover
    FROM cashback.fact_cashback_category AS f
    WHERE f.category IN (SELECT category FROM chosen_categories)
),
turnover_with_lag AS (
    SELECT
        c.client_id,
        c.category,
        c.month,
        c.turnover,
        LAG(c.turnover) OVER (PARTITION BY c.client_id, c.category ORDER BY c.month) AS prev_turnover
    FROM category_turnover AS c
)
SELECT
    month,
    AVG(turnover - COALESCE(prev_turnover, 0)) AS avg_delta_turnover
FROM turnover_with_lag
GROUP BY month
ORDER BY month;

-- 2) Контроль на базовую активность: нормируем оборот категории на общий оборот месяца.
WITH base AS (
    SELECT
        f.client_id,
        f.month,
        f.category,
        f.turnover,
        m.total_turnover,
        f.activation_state
    FROM cashback.fact_cashback_category AS f
    JOIN cashback.mart_client_month AS m
        ON m.client_id = f.client_id AND m.month = f.month
)
SELECT
    month,
    category,
    AVG(CASE WHEN activation_state = 'chosen' THEN turnover / NULLIF(total_turnover, 0) END) AS share_turnover_chosen,
    AVG(CASE WHEN activation_state = 'offered_not_chosen' THEN turnover / NULLIF(total_turnover, 0) END) AS share_turnover_not_chosen
FROM base
GROUP BY month, category
ORDER BY month, category;


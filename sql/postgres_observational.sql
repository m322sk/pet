Контроль на базовую активность: нормируем оборот категории на общий оборот месяца.
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


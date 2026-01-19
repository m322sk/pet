-- PostgreSQL: алерты по ключевым метрикам.

WITH metrics AS (
    SELECT
        month,
        COUNT(DISTINCT CASE WHEN total_turnover > 0 THEN client_id END) AS mau,
        SUM(total_turnover) AS total_turnover
    FROM (
        SELECT
            month,
            client_id,
            total_turnover
        FROM cashback.mart_client_month
    ) AS totals
    GROUP BY month
),
rolling AS (
    SELECT
        month,
        mau,
        total_turnover,
        AVG(mau) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS mau_avg,
        STDDEV_POP(mau) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS mau_std,
        AVG(total_turnover) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS turnover_avg,
        STDDEV_POP(total_turnover) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS turnover_std
    FROM metrics
)
SELECT
    month,
    mau,
    total_turnover,
    mau_avg,
    mau_std,
    turnover_avg,
    turnover_std,
    (mau < mau_avg - 3 * mau_std) AS mau_alert,
    (total_turnover < turnover_avg - 3 * turnover_std) AS turnover_alert
FROM rolling
ORDER BY month;

-- Алерты по ключевым метрикам.

WITH metrics AS (
    SELECT
        month,
        countDistinctIf(client_id, total_turnover > 0) AS mau,
        sum(total_turnover) AS total_turnover
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
            + turnover_rent AS total_turnover
        FROM cashback.fact_cashback
    )
    GROUP BY month
),
rolling AS (
    SELECT
        month,
        mau,
        total_turnover,
        avg(mau) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS mau_avg,
        stddevPop(mau) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS mau_std,
        avg(total_turnover) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS turnover_avg,
        stddevPop(total_turnover) OVER (ORDER BY month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS turnover_std
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
    -- Правило 3σ: если значение упало ниже среднего - 3*std, сигналим.
    (mau < mau_avg - 3 * mau_std) AS mau_alert,
    (total_turnover < turnover_avg - 3 * turnover_std) AS turnover_alert
FROM rolling
ORDER BY month;

-- Q3. Monthly revenue with month-over-month growth %
--     [CTE + LAG() window function]
WITH monthly AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        ROUND(SUM(f.amount), 2) AS revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month, d.month_name
)
SELECT
    year,
    month,
    month_name,
    revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY year, month))
        / LAG(revenue) OVER (ORDER BY year, month), 1
    ) AS mom_growth_pct
FROM monthly
ORDER BY year, month;

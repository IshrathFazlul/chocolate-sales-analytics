-- Q7. Marketing efficiency by country: revenue earned per $1 of spend
--     [JOIN, GROUP BY, ratio, HAVING]
SELECT
    c.country_name,
    ROUND(SUM(f.amount), 2)          AS total_revenue,
    ROUND(SUM(f.marketing_spend), 2) AS total_marketing,
    ROUND(SUM(f.amount) / SUM(f.marketing_spend), 2) AS revenue_per_marketing_dollar
FROM fact_sales f
JOIN dim_country c ON f.country_id = c.country_id
GROUP BY c.country_name
HAVING SUM(f.marketing_spend) > 0
ORDER BY revenue_per_marketing_dollar DESC;

-- Q5. Channel comparison  [GROUP BY, multiple aggregates]
SELECT
    ch.channel_name,
    COUNT(*)                       AS orders,
    ROUND(SUM(f.amount), 2)        AS total_revenue,
    ROUND(AVG(f.amount), 2)        AS avg_order_value,
    ROUND(AVG(f.discount_pct), 2)  AS avg_discount_pct
FROM fact_sales f
JOIN dim_channel ch ON f.channel_id = ch.channel_id
GROUP BY ch.channel_name
ORDER BY total_revenue DESC;

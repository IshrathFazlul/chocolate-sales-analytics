-- Q1. Revenue, boxes and orders by country  [JOIN, GROUP BY, aggregation]
SELECT
    c.country_name,
    COUNT(*)                  AS orders,
    SUM(f.boxes_shipped)      AS total_boxes,
    ROUND(SUM(f.amount), 2)   AS total_revenue,
    ROUND(AVG(f.amount), 2)   AS avg_order_value
FROM fact_sales f
JOIN dim_country c ON f.country_id = c.country_id
GROUP BY c.country_name
ORDER BY total_revenue DESC;

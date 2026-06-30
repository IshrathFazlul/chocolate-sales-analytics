-- Q2. Top 10 products by revenue  [JOIN, GROUP BY, ORDER, LIMIT]
SELECT
    p.product_name,
    COUNT(*)                  AS orders,
    SUM(f.boxes_shipped)      AS total_boxes,
    ROUND(SUM(f.amount), 2)   AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 10;

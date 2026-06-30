-- Q4. Salesperson leaderboard  [RANK() window function]
SELECT
    s.salesperson_name,
    COUNT(*)                    AS orders,
    ROUND(SUM(f.amount), 2)     AS total_revenue,
    ROUND(AVG(f.discount_pct), 2) AS avg_discount_pct,
    RANK() OVER (ORDER BY SUM(f.amount) DESC) AS revenue_rank
FROM fact_sales f
JOIN dim_salesperson s ON f.salesperson_id = s.salesperson_id
GROUP BY s.salesperson_name
ORDER BY total_revenue DESC;

-- Google Standard SQL / BigQuery SQL | Run after 04.
-- Final segmentation after revenue cleanup. First matching CASE rule wins.
-- At Risk precedes Lost: high-value/repeat buyers can remain At Risk beyond 63 days.

CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.customer_segments` AS
SELECT r.*,
       CASE
           WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'VIP'
           WHEN r_score >= 3 AND f_score = 1 AND m_score >= 3 THEN 'New High Value'
           WHEN r_score <= 1 AND (f_score >= 2 OR m_score >= 3) THEN 'At Risk'
           WHEN r_score >= 2 AND f_score >= 2 AND m_score >= 2 THEN 'Loyal'
           WHEN r_score = 0 THEN 'Lost'
           WHEN f_score = 1 THEN 'One-Time Buyer'
           ELSE 'Active'
       END AS segment
FROM `YOUR_PROJECT_ID.analytics.rfm_scoring` AS r;

CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.segment_stats` AS
WITH totals AS (
    SELECT segment, COUNT(*) AS customers, SUM(revenue) AS revenue,
           AVG(revenue) AS avg_revenue
    FROM `YOUR_PROJECT_ID.analytics.customer_segments`
    GROUP BY segment
)
SELECT segment, customers,
       ROUND(100 * SAFE_DIVIDE(customers, SUM(customers) OVER ()), 2) AS customer_pct,
       revenue,
       ROUND(100 * SAFE_DIVIDE(revenue, SUM(revenue) OVER ()), 2) AS revenue_pct,
       ROUND(avg_revenue, 2) AS avg_revenue
FROM totals;

SELECT * FROM `YOUR_PROJECT_ID.analytics.segment_stats` ORDER BY revenue DESC;

-- Reconciliation with final analysis findings; assignments above are data-driven.
WITH expected AS (
    SELECT 'At Risk' AS segment, 20879 AS customers, 18.89 AS customer_pct,
           35.46 AS revenue_pct, 107.89 AS avg_revenue
    UNION ALL SELECT 'Lost', 44685, 40.43, 17.92, 25.47
    UNION ALL SELECT 'One-Time Buyer', 31911, 28.87, 15.25, 30.36
    UNION ALL SELECT 'Loyal', 7017, 6.35, 14.41, 130.46
    UNION ALL SELECT 'VIP', 3176, 2.87, 13.10, 261.92
    UNION ALL SELECT 'New High Value', 1661, 1.50, 3.40, 130.06
    UNION ALL SELECT 'Active', 1189, 1.08, 0.46, 24.38
)
SELECT e.segment,
       e.customers AS expected_customers, s.customers AS actual_customers,
       s.customers - e.customers AS customer_difference,
       ROUND(s.customer_pct - e.customer_pct, 2) AS customer_pct_difference,
       ROUND(s.revenue_pct - e.revenue_pct, 2) AS revenue_pct_difference,
       ROUND(s.avg_revenue - e.avg_revenue, 2) AS avg_revenue_difference
FROM expected AS e
LEFT JOIN `YOUR_PROJECT_ID.analytics.segment_stats` AS s USING (segment)
ORDER BY e.customers DESC;

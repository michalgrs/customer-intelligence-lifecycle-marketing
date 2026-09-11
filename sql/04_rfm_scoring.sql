-- Google Standard SQL / BigQuery SQL | Run after 03.
-- Historical snapshot: 2020-02-29. Revenue is the corrected Monetary value.
-- R and M: 0-4. F: 1-4 for buyers with a recorded purchase session.
-- Buyer / baza RFM: purchase_sessions > 0; purchased_items liczy eventy zakupowe.

CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.rfm_scoring` AS
WITH base AS (
    SELECT user_id, first_purchase, last_purchase, purchase_sessions, revenue,
           DATE '2020-02-29' AS analysis_date,
           DATE_DIFF(DATE '2020-02-29', DATE(last_purchase), DAY) AS recency_days
    FROM `YOUR_PROJECT_ID.analytics.customer_360`
    WHERE purchase_sessions > 0
)
SELECT *,
       CASE WHEN recency_days <= 6 THEN 4
            WHEN recency_days <= 18 THEN 3
            WHEN recency_days <= 37 THEN 2
            WHEN recency_days <= 63 THEN 1
            WHEN recency_days > 63 THEN 0
            ELSE NULL END AS r_score,
       CASE WHEN purchase_sessions = 1 THEN 1
            WHEN purchase_sessions = 2 THEN 2
            WHEN purchase_sessions BETWEEN 3 AND 4 THEN 3
            WHEN purchase_sessions >= 5 THEN 4
            ELSE NULL END AS f_score,
       CASE WHEN revenue >= 122.23 THEN 4
            WHEN revenue >= 61.44 THEN 3
            WHEN revenue >= 33.18 THEN 2
            WHEN revenue >= 16.22 THEN 1
            ELSE 0 END AS m_score
FROM base;

SELECT r_score, f_score, m_score, COUNT(*) AS customers, SUM(revenue) AS revenue
FROM `YOUR_PROJECT_ID.analytics.rfm_scoring`
GROUP BY r_score, f_score, m_score
ORDER BY r_score DESC, f_score DESC, m_score DESC;

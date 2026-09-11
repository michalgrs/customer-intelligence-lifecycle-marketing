-- Google Standard SQL / BigQuery SQL | Run after 01.
-- One row per user_id, including non-buyers.
-- purchase_sessions is a proxy for orders: no conventional order_id exists.
-- Non-positive purchase events remain in counts and purchase dates.
-- Filter price > 0 only inside value metrics; never filter the raw event set.

CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.customer_360` AS
SELECT user_id,
       MIN(IF(event_type = 'purchase', event_time, NULL)) AS first_purchase,
       MAX(IF(event_type = 'purchase', event_time, NULL)) AS last_purchase,
       COUNTIF(event_type = 'view') AS views,
       COUNTIF(event_type = 'cart') AS carts,
       COUNTIF(event_type = 'remove_from_cart') AS removes_from_cart,
       COUNTIF(event_type = 'purchase') AS purchased_items,
       COUNT(DISTINCT IF(event_type = 'purchase', user_session, NULL)) AS purchase_sessions,
       COUNT(DISTINCT user_session) AS total_sessions,
       SUM(IF(event_type = 'purchase' AND price > 0,
              CAST(price AS NUMERIC), NUMERIC '0')) AS revenue,
       AVG(IF(event_type = 'purchase' AND price > 0,
              CAST(price AS NUMERIC), NULL)) AS avg_purchased_item_price
FROM `YOUR_PROJECT_ID.analytics.events_all`
WHERE user_id IS NOT NULL
GROUP BY user_id;

-- Reduce item-level purchase events to sessions before measuring repeat timing.
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.purchase_sessions` AS
SELECT user_id, user_session, MIN(event_time) AS purchase_session_at
FROM `YOUR_PROJECT_ID.analytics.events_all`
WHERE event_type = 'purchase'
  AND user_id IS NOT NULL AND user_session IS NOT NULL
GROUP BY user_id, user_session;

CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.purchase_intervals` AS
WITH ordered AS (
    SELECT user_id, user_session, purchase_session_at,
           LAG(purchase_session_at) OVER (
               PARTITION BY user_id ORDER BY purchase_session_at, user_session
           ) AS previous_purchase_at
    FROM `YOUR_PROJECT_ID.analytics.purchase_sessions`
)
SELECT user_id, user_session, previous_purchase_at, purchase_session_at,
       DATE_DIFF(DATE(purchase_session_at), DATE(previous_purchase_at), DAY) AS gap_days
FROM ordered
WHERE previous_purchase_at IS NOT NULL AND purchase_session_at IS NOT NULL;

SELECT COUNT(*) AS unique_users,
       COUNTIF(purchase_sessions > 0) AS buyers,
       ROUND(100 * SAFE_DIVIDE(COUNTIF(purchase_sessions > 0), COUNT(*)), 2) AS buyer_rate_pct,
       ROUND(100 * SAFE_DIVIDE(
           COUNTIF(purchase_sessions = 1),
           COUNTIF(purchase_sessions > 0)), 1) AS one_purchase_session_buyer_pct
FROM `YOUR_PROJECT_ID.analytics.customer_360`;

-- Findings: p25=6, median=18, p75=37, p90=63 days.
-- BigQuery PERCENTILE_CONT is an analytic function, not WITHIN GROUP.
SELECT DISTINCT
       COUNT(*) OVER () AS observed_intervals,
       PERCENTILE_CONT(CAST(gap_days AS NUMERIC), 0.25) OVER () AS p25_days,
       PERCENTILE_CONT(CAST(gap_days AS NUMERIC), 0.50) OVER () AS median_days,
       PERCENTILE_CONT(CAST(gap_days AS NUMERIC), 0.75) OVER () AS p75_days,
       PERCENTILE_CONT(CAST(gap_days AS NUMERIC), 0.90) OVER () AS p90_days
FROM `YOUR_PROJECT_ID.analytics.purchase_intervals`;

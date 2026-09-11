-- Google Standard SQL / BigQuery SQL | Run after 02.
-- Negative purchases: 126 events, 108 users, total value -3825.42.
-- The dataset does not document these as refunds.
-- Preserve all raw prices. Only value metrics omit non-positive purchases.

WITH actual AS (
    SELECT COUNT(*) AS events, COUNT(DISTINCT user_id) AS unique_users,
           (SELECT COUNTIF(purchase_sessions > 0)
            FROM `YOUR_PROJECT_ID.analytics.customer_360`) AS buyers,
           COUNTIF(event_type = 'purchase' AND price < 0) AS negative_purchase_events,
           COUNT(DISTINCT IF(event_type = 'purchase' AND price < 0, user_id, NULL)) AS affected_users,
           SUM(IF(event_type = 'purchase' AND price < 0,
                  CAST(price AS NUMERIC), NUMERIC '0')) AS total_negative_value
    FROM `YOUR_PROJECT_ID.analytics.events_all`
)
SELECT *,
       events = 20692840 AS events_match,
       unique_users = 1639358 AS users_match,
       buyers = 110518 AS buyers_match,
       negative_purchase_events = 126 AS negative_events_match,
       affected_users = 108 AS affected_users_match,
       total_negative_value = NUMERIC '-3825.42' AS negative_value_match
FROM actual;

SELECT COUNTIF(user_id IS NULL) AS missing_user_events,
       COUNTIF(event_time IS NULL) AS missing_time_events,
       COUNTIF(event_type = 'purchase' AND user_session IS NULL) AS missing_purchase_session_events,
       COUNTIF(event_type = 'purchase' AND user_session = '') AS empty_purchase_session_events,
       COUNTIF(event_type = 'purchase' AND price = 0) AS zero_purchase_events,
       COUNTIF(event_type = 'purchase' AND price IS NULL) AS missing_purchase_price_events,
       SUM(IF(event_type = 'purchase', CAST(price AS NUMERIC), NUMERIC '0')) AS raw_purchase_value,
       SUM(IF(event_type = 'purchase' AND price > 0,
              CAST(price AS NUMERIC), NUMERIC '0')) AS corrected_revenue,
       AVG(IF(event_type = 'purchase' AND price > 0,
              CAST(price AS NUMERIC), NULL)) AS avg_positive_purchased_item_price,
       SUM(IF(event_type = 'purchase' AND price > 0 AND user_id IS NULL,
              CAST(price AS NUMERIC), NUMERIC '0')) AS positive_revenue_without_user,
       MIN(event_time) AS first_event, MAX(event_time) AS last_event,
       COUNTIF(DATE(event_time) > DATE '2020-02-29') AS events_after_analysis_date
FROM `YOUR_PROJECT_ID.analytics.events_all`;

-- Buyer: purchase_sessions > 0. Eventy bez zarejestrowanej sesji audytujemy osobno.
SELECT COUNT(*) - COUNT(DISTINCT user_id) AS duplicate_customer_rows,
       COUNTIF(purchased_items > 0 AND purchase_sessions = 0) AS users_with_purchase_events_without_session,
       COUNTIF(purchase_sessions > 0 AND last_purchase IS NULL) AS buyers_without_purchase_time,
       COUNTIF(purchase_sessions > 0 AND revenue = 0) AS buyers_without_positive_revenue,
       SUM(revenue) AS identified_customer_revenue
FROM `YOUR_PROJECT_ID.analytics.customer_360`;

-- Investigate identical full rows; do not automatically remove them.
-- Without an event_id, identical records alone do not prove duplication.
SELECT COUNT(*) AS repeated_event_groups,
       COALESCE(SUM(copies - 1), 0) AS extra_rows_in_repeated_groups
FROM (
    SELECT event_time, event_type, product_id, category_id, category_code,
           brand, price, user_id, user_session, COUNT(*) AS copies
    FROM `YOUR_PROJECT_ID.analytics.events_all`
    GROUP BY event_time, event_type, product_id, category_id, category_code,
             brand, price, user_id, user_session
    HAVING COUNT(*) > 1
);

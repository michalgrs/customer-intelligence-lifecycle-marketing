-- Google Standard SQL / BigQuery SQL
-- REES46 Cosmetics: five monthly source tables, full dataset.
-- Replace YOUR_PROJECT_ID and map events_month_01 ... events_month_05
-- to your imported monthly tables. Keep raw and analytics in the same location.
-- Input fields: event_time TIMESTAMP, event_type STRING, product_id INT64,
-- category_id INT64, category_code STRING, brand STRING, price NUMERIC/FLOAT64,
-- user_id INT64, user_session STRING.
-- UNION ALL preserves all raw events, including negative purchase prices.

CREATE SCHEMA IF NOT EXISTS `YOUR_PROJECT_ID.analytics`;

CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.events_all` AS
SELECT event_time, event_type, product_id, category_id, category_code,
       brand, price, user_id, user_session
FROM `YOUR_PROJECT_ID.raw.events_month_01`
UNION ALL
SELECT event_time, event_type, product_id, category_id, category_code,
       brand, price, user_id, user_session
FROM `YOUR_PROJECT_ID.raw.events_month_02`
UNION ALL
SELECT event_time, event_type, product_id, category_id, category_code,
       brand, price, user_id, user_session
FROM `YOUR_PROJECT_ID.raw.events_month_03`
UNION ALL
SELECT event_time, event_type, product_id, category_id, category_code,
       brand, price, user_id, user_session
FROM `YOUR_PROJECT_ID.raw.events_month_04`
UNION ALL
SELECT event_time, event_type, product_id, category_id, category_code,
       brand, price, user_id, user_session
FROM `YOUR_PROJECT_ID.raw.events_month_05`;

-- Source coverage check. Source labels are not added to events_all.
SELECT 'month_01' AS source_month, COUNT(*) AS events,
       MIN(event_time) AS first_event, MAX(event_time) AS last_event
FROM `YOUR_PROJECT_ID.raw.events_month_01`
UNION ALL
SELECT 'month_02', COUNT(*), MIN(event_time), MAX(event_time)
FROM `YOUR_PROJECT_ID.raw.events_month_02`
UNION ALL
SELECT 'month_03', COUNT(*), MIN(event_time), MAX(event_time)
FROM `YOUR_PROJECT_ID.raw.events_month_03`
UNION ALL
SELECT 'month_04', COUNT(*), MIN(event_time), MAX(event_time)
FROM `YOUR_PROJECT_ID.raw.events_month_04`
UNION ALL
SELECT 'month_05', COUNT(*), MIN(event_time), MAX(event_time)
FROM `YOUR_PROJECT_ID.raw.events_month_05`
ORDER BY source_month;

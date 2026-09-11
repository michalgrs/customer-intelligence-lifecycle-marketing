-- Google Standard SQL / BigQuery SQL | Run after 05.
-- Recommended strategy / experiment design, not executed campaigns.
-- Candidates use the completed analysis snapshot of 2020-02-29.
-- Future activation requires a refreshed snapshot, CRM consent, identity,
-- prior enrollment, contact limits and suppression checks.

CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.analytics.campaign_audiences` AS
WITH mapped AS (
    SELECT s.*,
           CASE segment WHEN 'At Risk' THEN 'at_risk'
                WHEN 'One-Time Buyer' THEN 'one_time_buyer'
                WHEN 'New High Value' THEN 'new_high_value'
                WHEN 'VIP' THEN 'vip_loyal'
                WHEN 'Loyal' THEN 'vip_loyal' END AS journey
    FROM `YOUR_PROJECT_ID.analytics.customer_segments` AS s
    WHERE revenue > 0
), eligible AS (
    SELECT * FROM mapped
    WHERE journey IS NOT NULL
      -- Recommended pilot entry window, not a segmentation rule.
      AND (journey <> 'one_time_buyer' OR recency_days BETWEEN 6 AND 37)
), bucketed AS (
    SELECT e.*,
           -- Stable allocation; excludes snapshot date. Freeze at CRM enrollment.
           -- Nested MOD handles signed INT64 fingerprints without ABS overflow.
           MOD(MOD(FARM_FINGERPRINT(CONCAT(CAST(user_id AS STRING), ':',
               journey, ':pilot_v1')), 10000) + 10000, 10000) AS allocation_bucket
    FROM eligible AS e
)
SELECT user_id, analysis_date, segment, journey,
       'pilot_v1' AS experiment_version,
       CASE WHEN allocation_bucket < 1000 THEN 'control'
            WHEN allocation_bucket < 5500 THEN 'A'
            ELSE 'B' END AS proposed_arm,
       recency_days, purchase_sessions, revenue,
       FALSE AS ready_to_send,
       'Requires current snapshot, CRM consent, identity, entry history and suppression checks'
           AS activation_requirement
FROM bucketed;

-- Candidate audience sizes only: no deliveries, campaign outcomes or uplift.
SELECT journey, segment, proposed_arm, COUNT(*) AS candidate_users
FROM `YOUR_PROJECT_ID.analytics.campaign_audiences`
GROUP BY journey, segment, proposed_arm
ORDER BY journey, segment, proposed_arm;

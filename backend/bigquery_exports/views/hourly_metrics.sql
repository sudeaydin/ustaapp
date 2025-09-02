-- Hourly Metrics View for ustam App
-- Provides hour-by-hour breakdown of key metrics

CREATE OR REPLACE VIEW `ustam-analytics.ustam_analytics.hourly_metrics` AS
WITH hourly_activity AS (
  SELECT
    DATETIME_TRUNC(DATETIME(timestamp, 'Europe/Istanbul'), HOUR) as hour_tr,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(*) as total_actions,
    AVG(duration_ms) as avg_response_time,
    SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*) as success_rate,
    COUNT(CASE WHEN action_category = 'auth' THEN 1 END) as auth_actions,
    COUNT(CASE WHEN action_category = 'job' THEN 1 END) as job_actions,
    COUNT(CASE WHEN action_category = 'payment' THEN 1 END) as payment_actions,
    COUNT(CASE WHEN action_category = 'message' THEN 1 END) as message_actions
  FROM `ustam-analytics.ustam_analytics.user_activity_logs`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  GROUP BY hour_tr
),

hourly_errors AS (
  SELECT
    DATETIME_TRUNC(DATETIME(timestamp, 'Europe/Istanbul'), HOUR) as hour_tr,
    COUNT(*) as error_count,
    COUNT(CASE WHEN error_level = 'CRITICAL' THEN 1 END) as critical_errors,
    COUNT(CASE WHEN error_level = 'ERROR' THEN 1 END) as errors,
    COUNT(CASE WHEN error_level = 'WARNING' THEN 1 END) as warnings
  FROM `ustam-analytics.ustam_analytics.error_logs`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  GROUP BY hour_tr
),

hourly_searches AS (
  SELECT
    DATETIME_TRUNC(DATETIME(timestamp, 'Europe/Istanbul'), HOUR) as hour_tr,
    COUNT(*) as search_count,
    AVG(results_count) as avg_results,
    AVG(response_time_ms) as avg_search_time,
    COUNT(CASE WHEN clicked_result_id IS NOT NULL THEN 1 END) / COUNT(*) as ctr
  FROM `ustam-analytics.ustam_analytics.search_analytics`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  GROUP BY hour_tr
),

hourly_payments AS (
  SELECT
    DATETIME_TRUNC(DATETIME(created_at, 'Europe/Istanbul'), HOUR) as hour_tr,
    COUNT(*) as payment_count,
    SUM(amount) as total_amount,
    SUM(platform_fee) as platform_fees,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_payments,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_payments
  FROM `ustam-analytics.ustam_analytics.payment_analytics`
  WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  GROUP BY hour_tr
)

SELECT
  ha.hour_tr,
  
  -- Activity metrics
  COALESCE(ha.unique_users, 0) as unique_users,
  COALESCE(ha.total_actions, 0) as total_actions,
  COALESCE(ha.avg_response_time, 0) as avg_response_time,
  COALESCE(ha.success_rate, 0) as success_rate,
  COALESCE(ha.auth_actions, 0) as auth_actions,
  COALESCE(ha.job_actions, 0) as job_actions,
  COALESCE(ha.payment_actions, 0) as payment_actions,
  COALESCE(ha.message_actions, 0) as message_actions,
  
  -- Error metrics
  COALESCE(he.error_count, 0) as error_count,
  COALESCE(he.critical_errors, 0) as critical_errors,
  COALESCE(he.errors, 0) as errors,
  COALESCE(he.warnings, 0) as warnings,
  
  -- Search metrics
  COALESCE(hs.search_count, 0) as search_count,
  COALESCE(hs.avg_results, 0) as avg_search_results,
  COALESCE(hs.avg_search_time, 0) as avg_search_time,
  COALESCE(hs.ctr, 0) as search_ctr,
  
  -- Payment metrics
  COALESCE(hp.payment_count, 0) as payment_count,
  COALESCE(hp.total_amount, 0) as total_revenue,
  COALESCE(hp.platform_fees, 0) as platform_fees,
  COALESCE(hp.successful_payments, 0) as successful_payments,
  COALESCE(hp.failed_payments, 0) as failed_payments,
  
  -- Calculated metrics
  CASE 
    WHEN COALESCE(ha.total_actions, 0) > 0 
    THEN COALESCE(he.error_count, 0) / ha.total_actions 
    ELSE 0 
  END as error_rate,
  
  CASE 
    WHEN COALESCE(hp.payment_count, 0) > 0 
    THEN COALESCE(hp.successful_payments, 0) / hp.payment_count 
    ELSE 0 
  END as payment_success_rate

FROM hourly_activity ha
FULL OUTER JOIN hourly_errors he ON ha.hour_tr = he.hour_tr
FULL OUTER JOIN hourly_searches hs ON COALESCE(ha.hour_tr, he.hour_tr) = hs.hour_tr
FULL OUTER JOIN hourly_payments hp ON COALESCE(ha.hour_tr, he.hour_tr, hs.hour_tr) = hp.hour_tr
WHERE COALESCE(ha.hour_tr, he.hour_tr, hs.hour_tr, hp.hour_tr) IS NOT NULL
ORDER BY COALESCE(ha.hour_tr, he.hour_tr, hs.hour_tr, hp.hour_tr) DESC;
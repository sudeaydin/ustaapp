-- Real-time Dashboard View for ustam App
-- Combines multiple data sources for live analytics

CREATE OR REPLACE VIEW `ustam-analytics.ustam_analytics.realtime_dashboard` AS
WITH 
-- Current metrics (last 24 hours)
current_metrics AS (
  SELECT
    'last_24h' as period,
    COUNT(DISTINCT user_id) as active_users,
    COUNT(*) as total_actions,
    AVG(duration_ms) as avg_response_time,
    SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*) as success_rate
  FROM `ustam-analytics.ustam_analytics.user_activity_logs`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
),

-- Error metrics (last 24 hours)
error_metrics AS (
  SELECT
    COUNT(*) as total_errors,
    COUNT(DISTINCT user_id) as affected_users,
    COUNT(CASE WHEN error_level = 'CRITICAL' THEN 1 END) as critical_errors,
    COUNT(CASE WHEN resolved = false THEN 1 END) as unresolved_errors
  FROM `ustam-analytics.ustam_analytics.error_logs`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
),

-- Payment metrics (today)
payment_metrics AS (
  SELECT
    COUNT(*) as total_transactions,
    SUM(amount) as total_revenue,
    SUM(platform_fee) as platform_fees,
    AVG(amount) as avg_transaction_value,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_payments,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_payments
  FROM `ustam-analytics.ustam_analytics.payment_analytics`
  WHERE DATE(created_at) = CURRENT_DATE()
),

-- Search metrics (last 24 hours)
search_metrics AS (
  SELECT
    COUNT(*) as total_searches,
    AVG(results_count) as avg_results_count,
    AVG(response_time_ms) as avg_search_time,
    COUNT(CASE WHEN clicked_result_id IS NOT NULL THEN 1 END) / COUNT(*) as click_through_rate
  FROM `ustam-analytics.ustam_analytics.search_analytics`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
),

-- Platform distribution (last 24 hours)
platform_stats AS (
  SELECT
    platform,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(*) as total_actions,
    AVG(duration_ms) as avg_response_time
  FROM `ustam-analytics.ustam_analytics.user_activity_logs`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  GROUP BY platform
)

SELECT
  CURRENT_TIMESTAMP() as last_updated,
  
  -- User metrics
  cm.active_users,
  cm.total_actions,
  cm.avg_response_time,
  cm.success_rate,
  
  -- Error metrics
  em.total_errors,
  em.affected_users,
  em.critical_errors,
  em.unresolved_errors,
  
  -- Payment metrics
  pm.total_transactions,
  pm.total_revenue,
  pm.platform_fees,
  pm.avg_transaction_value,
  pm.successful_payments,
  pm.failed_payments,
  
  -- Search metrics
  sm.total_searches,
  sm.avg_results_count,
  sm.avg_search_time,
  sm.click_through_rate,
  
  -- Platform breakdown
  ARRAY_AGG(STRUCT(
    ps.platform,
    ps.unique_users,
    ps.total_actions,
    ps.avg_response_time
  )) as platform_breakdown

FROM current_metrics cm
CROSS JOIN error_metrics em
CROSS JOIN payment_metrics pm
CROSS JOIN search_metrics sm
LEFT JOIN platform_stats ps ON true
GROUP BY 
  cm.active_users, cm.total_actions, cm.avg_response_time, cm.success_rate,
  em.total_errors, em.affected_users, em.critical_errors, em.unresolved_errors,
  pm.total_transactions, pm.total_revenue, pm.platform_fees, pm.avg_transaction_value, pm.successful_payments, pm.failed_payments,
  sm.total_searches, sm.avg_results_count, sm.avg_search_time, sm.click_through_rate;
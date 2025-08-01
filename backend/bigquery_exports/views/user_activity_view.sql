
        CREATE OR REPLACE VIEW `ustam_analytics.user_activity` AS
        SELECT 
            u.user_id,
            u.user_type,
            u.city,
            u.created_at as registration_date,
            u.last_login,
            CASE 
                WHEN u.last_login >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) THEN 'Active'
                WHEN u.last_login >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY) THEN 'Inactive'
                ELSE 'Dormant'
            END as activity_status,
            CASE 
                WHEN u.user_type = 'customer' THEN c.total_jobs
                WHEN u.user_type = 'craftsman' THEN cr.total_jobs
                ELSE 0
            END as total_jobs,
            CASE 
                WHEN u.user_type = 'customer' THEN c.total_spent
                WHEN u.user_type = 'craftsman' THEN cr.average_rating
                ELSE 0
            END as performance_metric
        FROM `ustam_analytics.users` u
        LEFT JOIN `ustam_analytics.customers` c ON u.user_id = c.user_id
        LEFT JOIN `ustam_analytics.craftsmen` cr ON u.user_id = cr.user_id
        WHERE u.is_active = true;
        
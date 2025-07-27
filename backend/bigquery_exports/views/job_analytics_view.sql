
        CREATE OR REPLACE VIEW `ustam_analytics.job_analytics` AS
        SELECT 
            j.job_id,
            j.category_id,
            cat.name as category_name,
            j.city,
            j.status,
            j.budget_min,
            j.budget_max,
            j.final_price,
            j.urgency,
            j.created_at,
            j.completed_at,
            DATETIME_DIFF(j.completed_at, j.created_at, HOUR) as completion_hours,
            j.quote_count,
            CASE 
                WHEN j.status = 'completed' THEN 'Success'
                WHEN j.status = 'cancelled' THEN 'Cancelled'
                WHEN j.status IN ('open', 'assigned', 'in_progress') THEN 'In Progress'
                ELSE 'Other'
            END as job_outcome
        FROM `ustam_analytics.jobs` j
        LEFT JOIN `ustam_analytics.categories` cat ON j.category_id = cat.category_id;
        
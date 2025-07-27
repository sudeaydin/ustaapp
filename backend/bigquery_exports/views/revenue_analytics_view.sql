
        CREATE OR REPLACE VIEW `ustam_analytics.revenue_analytics` AS
        SELECT 
            DATE(p.created_at) as payment_date,
            EXTRACT(YEAR FROM p.created_at) as year,
            EXTRACT(MONTH FROM p.created_at) as month,
            COUNT(*) as transaction_count,
            SUM(p.amount) as total_revenue,
            SUM(p.platform_fee) as platform_revenue,
            SUM(p.craftsman_amount) as craftsman_revenue,
            AVG(p.amount) as avg_transaction_amount,
            p.payment_method,
            p.status
        FROM `ustam_analytics.payments` p
        WHERE p.status = 'completed'
        GROUP BY 
            DATE(p.created_at),
            EXTRACT(YEAR FROM p.created_at),
            EXTRACT(MONTH FROM p.created_at),
            p.payment_method,
            p.status;
        
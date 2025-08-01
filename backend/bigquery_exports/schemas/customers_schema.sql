CREATE TABLE IF NOT EXISTS `ustam_analytics.customers` (
  customer_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  company_name STRING,
  tax_number STRING,
  preferred_contact_method STRING,
  total_jobs INTEGER,
  total_spent NUMERIC,
  average_rating NUMERIC,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
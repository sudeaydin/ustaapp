CREATE TABLE IF NOT EXISTS `ustam_analytics.payments` (
  payment_id INTEGER NOT NULL,
  transaction_id STRING NOT NULL,
  job_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  craftsman_id INTEGER NOT NULL,
  amount NUMERIC NOT NULL,
  platform_fee NUMERIC,
  craftsman_amount NUMERIC NOT NULL,
  payment_method STRING,
  payment_provider STRING,
  currency STRING,
  status STRING,
  created_at TIMESTAMP,
  completed_at TIMESTAMP
);
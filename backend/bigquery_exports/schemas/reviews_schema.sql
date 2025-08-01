CREATE TABLE IF NOT EXISTS `ustam_analytics.reviews` (
  review_id INTEGER NOT NULL,
  job_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  craftsman_id INTEGER NOT NULL,
  rating INTEGER NOT NULL,
  title STRING,
  comment STRING,
  quality_rating INTEGER,
  punctuality_rating INTEGER,
  communication_rating INTEGER,
  value_rating INTEGER,
  is_verified BOOLEAN,
  is_featured BOOLEAN,
  created_at TIMESTAMP
);
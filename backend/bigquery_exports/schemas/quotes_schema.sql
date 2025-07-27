CREATE TABLE IF NOT EXISTS `ustam_analytics.quotes` (
  quote_id INTEGER NOT NULL,
  job_id INTEGER NOT NULL,
  craftsman_id INTEGER NOT NULL,
  price NUMERIC NOT NULL,
  description STRING,
  estimated_duration INTEGER,
  materials_included BOOLEAN,
  warranty_period INTEGER,
  status STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  accepted_at TIMESTAMP
);
CREATE TABLE IF NOT EXISTS `ustam_analytics.categories` (
  category_id INTEGER NOT NULL,
  name STRING NOT NULL,
  name_en STRING,
  slug STRING,
  description STRING,
  icon STRING,
  color STRING,
  is_active BOOLEAN,
  is_featured BOOLEAN,
  sort_order INTEGER,
  total_jobs INTEGER,
  total_craftsmen INTEGER,
  created_at TIMESTAMP
);
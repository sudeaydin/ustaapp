CREATE TABLE IF NOT EXISTS `ustam_analytics.notifications` (
  notification_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  title STRING NOT NULL,
  type STRING,
  related_id INTEGER,
  related_type STRING,
  is_read BOOLEAN,
  is_sent BOOLEAN,
  created_at TIMESTAMP,
  read_at TIMESTAMP
);